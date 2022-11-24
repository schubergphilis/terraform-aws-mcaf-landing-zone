provider "mcaf" {
  aws {
    region = "eu-central-1"
  }
}

data "aws_caller_identity" "audit" {
  provider = aws.audit
}

data "aws_caller_identity" "logging" {
  provider = aws.logging
}

data "aws_caller_identity" "master" {}

data "aws_cloudwatch_log_group" "cloudtrail_audit" {
  count    = var.monitor_iam_activity ? 1 : 0
  provider = aws.audit
  name     = "aws-controltower/CloudTrailLogs"
}

data "aws_cloudwatch_log_group" "cloudtrail_logging" {
  count    = var.monitor_iam_activity ? 1 : 0
  provider = aws.logging
  name     = "aws-controltower/CloudTrailLogs"
}

data "aws_cloudwatch_log_group" "cloudtrail_master" {
  count = var.monitor_iam_activity ? 1 : 0
  name  = "aws-controltower/CloudTrailLogs"
}

data "aws_identitystore_group" "sso" {
  for_each          = toset([for assignment in local.aws_sso_account_assignment : assignment.sso_group])
  identity_store_id = tolist(data.aws_ssoadmin_instances.default.identity_store_ids)[0]

  filter {
    attribute_path  = "DisplayName"
    attribute_value = each.value
  }
}

data "aws_organizations_organization" "default" {}

data "aws_organizations_organizational_units" "default" {
  parent_id = data.aws_organizations_organization.default.roots[0].id
}

data "mcaf_aws_all_organizational_units" "default" {}

data "aws_region" "current" {}

data "aws_sns_topic" "all_config_notifications" {
  provider = aws.audit
  name     = "aws-controltower-AllConfigNotifications"
}

data "aws_ssoadmin_instances" "default" {}
