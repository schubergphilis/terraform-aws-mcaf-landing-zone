// AWS Config - Management account configuration
resource "aws_config_aggregate_authorization" "master" {
  for_each = { for aggregator in local.aws_config_aggregators : "${aggregator.account_id}-${aggregator.region}" => aggregator if aggregator.account_id != var.control_tower_account_ids.audit }

  account_id = each.value.account_id
  region     = each.value.region
  tags       = var.tags
}

resource "aws_config_aggregate_authorization" "master_to_audit" {
  for_each = toset(try(var.aws_config.aggregator_regions, ["eu-central-1", "eu-west-1"]))

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
  for_each = toset(local.aws_config_rules)

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
