data "aws_caller_identity" "audit" {
  provider = aws.audit
}

data "aws_caller_identity" "logging" {
  provider = aws.logging
}

data "aws_caller_identity" "management" {}

data "aws_cloudwatch_log_group" "cloudtrail_master" {
  count = var.monitor_iam_activity ? 1 : 0

  name = "aws-controltower/CloudTrailLogs"
}

data "aws_organizations_organization" "default" {}

data "aws_organizations_organizational_units" "default" {
  parent_id = data.aws_organizations_organization.default.roots[0].id
}

data "aws_region" "current" {}

data "aws_sns_topic" "all_config_notifications" {
  provider = aws.audit

  name = "aws-controltower-AllConfigNotifications"
}

data "mcaf_aws_all_organizational_units" "default" {}
