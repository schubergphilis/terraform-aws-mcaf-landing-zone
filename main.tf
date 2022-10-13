#tfsec:ignore:AWS065
resource "aws_cloudtrail" "additional_auditing_trail" {
  count                      = var.additional_auditing_trail != null ? 1 : 0
  name                       = var.additional_auditing_trail.name
  enable_log_file_validation = true
  is_multi_region_trail      = true
  is_organization_trail      = true
  s3_bucket_name             = var.additional_auditing_trail.bucket
  tags                       = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "iam_activity_master" {
  for_each = var.monitor_iam_activity ? merge(local.iam_activity, local.cloudtrail_activity_cis_aws_foundations) : {}

  name           = "LandingZone-IAMActivity-${each.key}"
  pattern        = each.value
  log_group_name = data.aws_cloudwatch_log_group.cloudtrail_master.0.name

  metric_transformation {
    name      = "LandingZone-IAMActivity-${each.key}"
    namespace = "LandingZone-IAMActivity"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "iam_activity_master" {
  for_each = aws_cloudwatch_log_metric_filter.iam_activity_master

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

resource "aws_config_aggregate_authorization" "master" {
  for_each   = { for aggregator in local.aws_config_aggregators : "${aggregator.account_id}-${aggregator.region}" => aggregator if aggregator.account_id != var.control_tower_account_ids.audit }
  account_id = each.value.account_id
  region     = each.value.region
  tags       = var.tags
}

resource "aws_config_aggregate_authorization" "master_to_audit" {
  for_each   = toset(try(var.aws_config.aggregator_regions, ["eu-central-1", "eu-west-1"]))
  account_id = var.control_tower_account_ids.audit
  region     = each.value
  tags       = var.tags
}

resource "aws_config_configuration_recorder" "default" {
  name     = "default"
  role_arn = aws_iam_role.config_recorder.arn

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
  s3_bucket_name = "aws-controltower-logs-${var.control_tower_account_ids.logging}-${data.aws_region.current.name}"
  s3_key_prefix  = data.aws_organizations_organization.default.id
  sns_topic_arn  = data.aws_sns_topic.all_config_notifications.arn
  depends_on     = [aws_config_configuration_recorder.default]
}

resource "aws_config_organization_managed_rule" "default" {
  for_each        = toset(local.aws_config_rules)
  name            = each.value
  rule_identifier = each.value
}

resource "aws_iam_role" "config_recorder" {
  name = "LandingZone-ConfigRecorderRole"
  tags = var.tags

  assume_role_policy = templatefile("${path.module}/files/iam/service_assume_role.json.tpl", {
    service = "config.amazonaws.com"
  })
}

resource "aws_iam_role_policy_attachment" "config_recorder_read_only" {
  role       = aws_iam_role.config_recorder.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "config_recorder_config_role" {
  role       = aws_iam_role.config_recorder.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

module "datadog_master" {
  count                 = try(var.datadog.enable_integration, false) == true ? 1 : 0
  source                = "github.com/schubergphilis/terraform-aws-mcaf-datadog?ref=v0.3.8"
  api_key               = try(var.datadog.api_key, null)
  excluded_regions      = var.datadog_excluded_regions
  install_log_forwarder = try(var.datadog.install_log_forwarder, false)
  site_url              = try(var.datadog.site_url, null)
  tags                  = var.tags
}

resource "aws_iam_account_password_policy" "master" {
  count                          = var.aws_account_password_policy != null ? 1 : 0
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
