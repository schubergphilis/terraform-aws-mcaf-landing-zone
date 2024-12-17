locals {
  aws_config_aggregators = flatten([
    for account in toset(try(var.aws_config.aggregator_account_ids, [])) : [
      for region in toset(try(var.allowed_regions, [])) : {
        account_id = account
        region     = region
      }
    ]
  ])
  aws_config_rules = setunion(
    try(var.aws_config.rule_identifiers, []),
    [
      "CLOUD_TRAIL_ENABLED",
      "ENCRYPTED_VOLUMES",
      "ROOT_ACCOUNT_MFA_ENABLED",
      "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
    ]
  )
  aws_config_s3_name = coalesce(
    var.aws_config.delivery_channel_s3_bucket_name,
    "aws-config-configuration-history-${var.control_tower_account_ids.logging}-${data.aws_region.current.name}"
  )
}

// AWS Config - Management account configuration
resource "aws_config_aggregate_authorization" "master" {
  for_each = { for aggregator in local.aws_config_aggregators : "${aggregator.account_id}-${aggregator.region}" => aggregator if aggregator.account_id != var.control_tower_account_ids.audit }

  account_id = each.value.account_id
  region     = each.value.region
  tags       = var.tags
}

resource "aws_config_aggregate_authorization" "master_to_audit" {
  for_each = toset(coalescelist(var.allowed_regions, [data.aws_region.current.name]))

  account_id = var.control_tower_account_ids.audit
  region     = each.value
  tags       = var.tags
}

resource "aws_iam_service_linked_role" "config" {
  aws_service_name = "config.amazonaws.com"
}

resource "aws_config_configuration_recorder" "default" {
  name     = "default"
  role_arn = aws_iam_service_linked_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_configuration_recorder_status" "default" {
  name       = aws_config_configuration_recorder.default.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.default]
}

resource "aws_config_delivery_channel" "default" {
  name           = "default"
  s3_bucket_name = module.aws_config_s3.name
  s3_key_prefix  = var.aws_config.delivery_channel_s3_key_prefix
  s3_kms_key_arn = module.kms_key_logging.arn
  sns_topic_arn  = data.aws_sns_topic.all_config_notifications.arn

  snapshot_delivery_properties {
    delivery_frequency = var.aws_config.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.default]
}

resource "aws_config_organization_managed_rule" "default" {
  for_each = toset(local.aws_config_rules)

  name            = each.value
  rule_identifier = each.value
}

// AWS Config - Audit account configuration
resource "aws_config_configuration_aggregator" "audit" {
  provider = aws.audit

  name = "audit"
  tags = var.tags

  account_aggregation_source {
    account_ids = [
      for account in data.aws_organizations_organization.default.accounts : account.id if account.id != var.control_tower_account_ids.audit
    ]
    all_regions = true
  }
}

resource "aws_config_aggregate_authorization" "audit" {
  for_each = { for aggregator in local.aws_config_aggregators : "${aggregator.account_id}-${aggregator.region}" => aggregator if aggregator.account_id != var.control_tower_account_ids.audit }
  provider = aws.audit

  account_id = each.value.account_id
  region     = each.value.region
  tags       = var.tags
}

resource "aws_sns_topic_subscription" "aws_config" {
  for_each = var.aws_config_sns_subscription
  provider = aws.audit

  endpoint               = each.value.endpoint
  endpoint_auto_confirms = length(regexall("http", each.value.protocol)) > 0
  protocol               = each.value.protocol
  topic_arn              = "arn:aws:sns:${data.aws_region.current.name}:${var.control_tower_account_ids.audit}:aws-controltower-AggregateSecurityNotifications"
}

// AWS Config - Logging account configuration
resource "aws_config_aggregate_authorization" "logging" {
  for_each = { for aggregator in local.aws_config_aggregators : "${aggregator.account_id}-${aggregator.region}" => aggregator if aggregator.account_id != var.control_tower_account_ids.audit }
  provider = aws.logging

  account_id = each.value.account_id
  region     = each.value.region
  tags       = var.tags
}

data "aws_iam_policy_document" "aws_config_s3" {
  statement {
    sid       = "AWSConfigBucketPermissionsCheck"
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${local.aws_config_s3_name}"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }

  statement {
    sid       = "AWSConfigBucketExistenceCheck"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${local.aws_config_s3_name}"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }

  statement {
    sid       = "AllowConfigWriteAccess"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.aws_config_s3_name}/*"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

module "aws_config_s3" {
  #checkov:skip=CKV_AWS_19: False positive, KMS key is used by default https://github.com/bridgecrewio/checkov/issues/3847
  #checkov:skip=CKV_AWS_145: False positive, KMS key is used by default https://github.com/bridgecrewio/checkov/issues/3847
  providers = { aws = aws.logging }

  source  = "schubergphilis/mcaf-s3/aws"
  version = "~> 0.14.1"

  name        = local.aws_config_s3_name
  kms_key_arn = module.kms_key_logging.arn
  policy      = data.aws_iam_policy_document.aws_config_s3.json
  versioning  = true
  tags        = var.tags

  lifecycle_rule = [
    {
      id      = "retention"
      enabled = true

      abort_incomplete_multipart_upload = {
        days_after_initiation = 7
      }

      expiration = {
        days = 365
      }

      noncurrent_version_expiration = {
        noncurrent_days = 365
      }

      noncurrent_version_transition = {
        noncurrent_days = 90
        storage_class   = "STANDARD_IA"
      }

      transition = {
        days          = 90
        storage_class = "STANDARD_IA"
      }
    }
  ]
}
