provider "aws" {
  alias = "logging"

  assume_role {
    role_arn = "arn:aws:iam::${var.control_tower_account_ids.logging}:role/AWSControlTowerExecution"
  }
}

resource "aws_cloudwatch_log_metric_filter" "iam_activity_logging" {
  for_each = var.monitor_iam_activity ? merge(local.iam_activity, local.cloudtrail_activity_cis_aws_foundations) : {}
  provider = aws.logging

  name           = "LandingZone-IAMActivity-${each.key}"
  pattern        = each.value
  log_group_name = data.aws_cloudwatch_log_group.cloudtrail_logging.name

  metric_transformation {
    name      = "LandingZone-IAMActivity-${each.key}"
    namespace = "LandingZone-IAMActivity"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "iam_activity_logging" {
  for_each = aws_cloudwatch_log_metric_filter.iam_activity_logging
  provider = aws.logging

  alarm_name                = each.value.name
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = each.value.name
  namespace                 = each.value.metric_transformation.0.namespace
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitors IAM activity for ${each.key}"
  alarm_actions             = [aws_sns_topic.iam_activity.0.arn]
  insufficient_data_actions = []
  tags                      = var.tags
}

resource "aws_config_aggregate_authorization" "logging" {
  for_each   = { for aggregator in local.aws_config_aggregators : "${aggregator.account_id}-${aggregator.region}" => aggregator if aggregator.account_id != var.control_tower_account_ids.audit }
  provider   = aws.logging
  account_id = each.value.account_id
  region     = each.value.region
  tags       = var.tags
}

module "datadog_logging" {
  count                 = try(var.datadog.enable_integration, false) == true ? 1 : 0
  source                = "github.com/schubergphilis/terraform-aws-mcaf-datadog?ref=v0.3.8"
  providers             = { aws = aws.logging }
  api_key               = try(var.datadog.api_key, null)
  excluded_regions      = var.datadog_excluded_regions
  install_log_forwarder = try(var.datadog.install_log_forwarder, false)
  tags                  = var.tags
}

resource "aws_iam_account_password_policy" "logging" {
  count                          = var.aws_account_password_policy != null ? 1 : 0
  provider                       = aws.logging
  allow_users_to_change_password = var.aws_account_password_policy.allow_users_to_change
  max_password_age               = var.aws_account_password_policy.max_age
  minimum_password_length        = var.aws_account_password_policy.minimum_length
  password_reuse_prevention      = var.aws_account_password_policy.reuse_prevention_history
  require_lowercase_characters   = var.aws_account_password_policy.require_lowercase_characters
  require_numbers                = var.aws_account_password_policy.require_numbers
  require_symbols                = var.aws_account_password_policy.require_symbols
  require_uppercase_characters   = var.aws_account_password_policy.require_uppercase_characters
}

resource "aws_ebs_encryption_by_default" "logging" {
  provider = aws.logging
  enabled  = var.aws_ebs_encryption_by_default
}

resource "aws_s3_account_public_access_block" "logging" {
  provider                = aws.logging
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "kms_key_logging" {
  source              = "github.com/schubergphilis/terraform-aws-mcaf-kms?ref=v0.2.0"
  providers           = { aws = aws.logging }
  name                = "logging"
  description         = "KMS key to use with logging account"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms_key_logging.json
  tags                = var.tags
}

data "aws_iam_policy_document" "kms_key_logging" {
  source_json = var.kms_key_policy_logging

  statement {
    sid       = "Full permissions for the root user only"
    actions   = ["kms:*"]
    effect    = "Allow"
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalType"
      values   = ["Account"]
    }

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.logging.account_id}:root"
      ]
    }
  }

  statement {
    sid = "Administrative permissions for pipeline"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:Get*",
      "kms:List*",
      "kms:Put*",
      "kms:Revoke*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:Update*"
    ]
    effect    = "Allow"
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.control_tower_account_ids.logging}:role/AWSControlTowerExecution"
      ]
    }
  }

  statement {
    sid = "List KMS keys permissions for all IAM users"
    actions = [
      "kms:Describe*",
      "kms:Get*",
      "kms:List*"
    ]
    effect    = "Allow"
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.logging.account_id}:root"
      ]
    }
  }
}
