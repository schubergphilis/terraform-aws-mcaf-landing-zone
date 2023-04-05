resource "aws_cloudwatch_log_metric_filter" "cloudtrail_management" {
  for_each = var.monitor_iam_activity ? merge(local.iam_activity, local.cloudtrail_activity_cis_aws_foundations) : {}

  name           = "LandingZone-IAMActivity-${each.key}"
  pattern        = each.value
  log_group_name = data.aws_cloudwatch_log_group.cloudtrail_management[0].name

  metric_transformation {
    name      = "LandingZone-IAMActivity-${each.key}"
    namespace = "LandingZone-IAMActivity"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudtrail_management" {
  for_each = aws_cloudwatch_log_metric_filter.cloudtrail_management

  alarm_name                = each.value.name
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = each.value.name
  namespace                 = each.value.metric_transformation[0].namespace
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitors IAM activity for ${each.key}"
  alarm_actions             = [aws_sns_topic.iam_activity[0].arn]
  insufficient_data_actions = []
  tags                      = var.tags
}

resource "aws_iam_account_password_policy" "master" {
  count = var.aws_account_password_policy != null ? 1 : 0

  allow_users_to_change_password = var.aws_account_password_policy.allow_users_to_change
  max_password_age               = var.aws_account_password_policy.max_age
  minimum_password_length        = var.aws_account_password_policy.minimum_length
  password_reuse_prevention      = var.aws_account_password_policy.reuse_prevention_history
  require_lowercase_characters   = var.aws_account_password_policy.require_lowercase_characters
  require_numbers                = var.aws_account_password_policy.require_numbers
  require_symbols                = var.aws_account_password_policy.require_symbols
  require_uppercase_characters   = var.aws_account_password_policy.require_uppercase_characters
}

resource "aws_ebs_encryption_by_default" "master" {
  enabled = var.aws_ebs_encryption_by_default
}

resource "aws_s3_account_public_access_block" "master" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
