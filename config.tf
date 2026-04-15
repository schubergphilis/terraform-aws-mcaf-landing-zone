locals {
  aws_config_rules = setunion(
    var.aws_config_organization_managed_rules,
    [
      "CLOUD_TRAIL_ENABLED",
      "ENCRYPTED_VOLUMES",
      "ROOT_ACCOUNT_MFA_ENABLED",
      "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
    ]
  )

  controltower_aws_config_s3_name = element(split(":::", one(
    data.aws_resourcegroupstaggingapi_resources.controltower_config_s3.resource_tag_mapping_list[*].resource_arn
  )), 1)
}

resource "aws_config_organization_managed_rule" "default" {
  for_each = toset(local.aws_config_rules)

  name            = each.value
  rule_identifier = each.value
}

resource "aws_sns_topic_subscription" "aws_config" {
  for_each = var.aws_config_sns_subscription
  provider = aws.audit

  endpoint               = each.value.endpoint
  endpoint_auto_confirms = length(regexall("http", each.value.protocol)) > 0
  protocol               = each.value.protocol
  topic_arn              = "arn:aws:sns:${data.aws_region.current.region}:${var.control_tower_account_ids.audit}:aws-controltower-AggregateSecurityNotifications"
}

# AWS Control Tower implements a Service-Linked Config Aggregator (SLCA) in the audit account as part of Landing Zone 4.0+, 
# but as the management account is not managed by Control Tower, AWS Config needs to be enabled for this account separately.
# The bucket created as of Landing Zone 4.0+ is used instead of a seperate bucket: aws-controltower-config-logs-<audit account id>-aaa-bbb

resource "aws_iam_service_linked_role" "config" {
  aws_service_name      = "config.amazonaws.com"
  account_id            = each.value.account_id
  authorized_aws_region = each.value.region
  tags                  = var.tags
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
  version = "~> 2.0.0"

  name        = local.aws_config_s3_name
  kms_key_arn = module.kms_key_logging[var.regions.home_region].arn # As is recommended design, all AWS Config output is send to a bucket in the home region.
  policy      = data.aws_iam_policy_document.aws_config_s3.json
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

module "aws_config_recorder" {
  for_each = local.all_governed_regions

  source = "./modules/aws-config-recorder"

  region                      = each.key
  delivery_frequency          = "One_Hour"
  iam_service_linked_role_arn = aws_iam_service_linked_role.config.arn
  kms_key_arn                 = module.kms_key[var.regions.home_region].arn
  s3_bucket_name              = local.controltower_aws_config_s3_name
  s3_key_prefix               = data.aws_organizations_organization.default.id
  sns_topic_arn               = data.aws_sns_topic.all_config_notifications[each.key].arn
}
