data "aws_caller_identity" "audit" {
  provider = aws.audit
}
data "aws_caller_identity" "master" {}

data "aws_cloudwatch_log_group" "cloudtrail_audit" {
  provider = aws.audit
  name     = "aws-controltower/CloudTrailLogs"
}

data "aws_cloudwatch_log_group" "cloudtrail_logging" {
  provider = aws.logging
  name     = "aws-controltower/CloudTrailLogs"
}

data "aws_cloudwatch_log_group" "cloudtrail_master" {
  name = "aws-controltower/CloudTrailLogs"
}

data "aws_organizations_organization" "default" {}

data "aws_organizations_organizational_units" "default" {
  parent_id = data.aws_organizations_organization.default.roots[0].id
}

data "aws_region" "current" {}

data "aws_sns_topic" "all_config_notifications" {
  provider = aws.audit
  name     = "aws-controltower-AllConfigNotifications"
}
