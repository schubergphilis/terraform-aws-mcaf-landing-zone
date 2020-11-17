provider "aws" {
  alias = "audit"

  assume_role {
    role_arn = "arn:aws:iam::${var.control_tower_account_ids.audit}:role/AWSControlTowerExecution"
  }
}

resource "aws_cloudwatch_event_rule" "monitor_iam_access_audit" {
  for_each    = local.monitor_iam_access
  provider    = aws.audit
  name        = substr("LandingZone-MonitorIAMAccess-${each.key}", 0, 64)
  description = "Monitors IAM access for ${each.key}"

  event_pattern = templatefile("${path.module}/files/event_bridge/monitor_iam_access.json.tpl", {
    userIdentity = jsonencode(each.value)
  })

  depends_on = [data.aws_iam_role.monitor_iam_access_audit, data.aws_iam_user.monitor_iam_access_audit]
}

resource "aws_cloudwatch_event_target" "monitor_iam_access_audit" {
  for_each  = aws_cloudwatch_event_rule.monitor_iam_access_audit
  provider  = aws.audit
  rule      = each.value.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.monitor_iam_access.arn
}

resource "aws_config_aggregate_authorization" "audit" {
  for_each   = { for aggregator in local.aws_config_aggregators : "${aggregator.account_id}-${aggregator.region}" => aggregator }
  provider   = aws.audit
  account_id = each.value.account_id
  region     = each.value.region
}

resource "aws_config_configuration_aggregator" "audit" {
  name = "audit"

  account_aggregation_source {
    account_ids = [
      for account in data.aws_organizations_organization.default.accounts : account.id if account.id != var.control_tower_account_ids.audit
    ]
    all_regions = true
  }
}

resource "aws_sns_topic" "monitor_iam_access" {
  name = "LandingZone-MonitorIAMAccess"
}

resource "aws_sns_topic_policy" "monitor_iam_access" {
  arn    = aws_sns_topic.monitor_iam_access.arn
  policy = data.aws_iam_policy_document.monitor_iam_access_sns_topic_policy.json
}

module "datadog_audit" {
  count                 = try(var.datadog.enable_integration, false) == true ? 1 : 0
  source                = "github.com/schubergphilis/terraform-aws-mcaf-datadog?ref=v0.3.2"
  providers             = { aws = aws.audit }
  api_key               = try(var.datadog.api_key, null)
  install_log_forwarder = try(var.datadog.install_log_forwarder, false)
  tags                  = var.tags
}

module "security_hub_audit" {
  source    = "./modules/security_hub"
  providers = { aws = aws.audit }

  member_accounts = {
    for account in data.aws_organizations_organization.default.accounts : account.id => account.email if account.id != var.control_tower_account_ids.audit
  }
}
