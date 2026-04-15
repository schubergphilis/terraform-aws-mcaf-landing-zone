data "aws_caller_identity" "audit" {
  provider = aws.audit
}

data "aws_caller_identity" "logging" {
  provider = aws.logging
}

data "aws_caller_identity" "management" {}

data "aws_cloudwatch_log_groups" "cloudtrail_master" {
  log_group_name_prefix = "aws-controltower/CloudTrailLogs"
}

data "aws_organizations_organization" "default" {}

data "aws_organizations_organizational_units" "default" {
  parent_id = data.aws_organizations_organization.default.roots[0].id
}

data "aws_region" "current" {}

data "aws_resourcegroupstaggingapi_resources" "controltower_config_s3" {
  provider = aws.audit

  resource_type_filters = ["s3"]

  tag_filter {
    key    = "aws:cloudformation:logical-id"
    values = ["ConfigS3Bucket"]
  }
}

data "aws_sns_topic" "all_config_notifications" {
  for_each = local.all_governed_regions
  provider = aws.audit

  region = each.key

  name = "aws-controltower-AllConfigNotifications"
}

data "mcaf_aws_all_organizational_units" "default" {}
