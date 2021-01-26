provider "aws" {
  alias = "logging"

  assume_role {
    role_arn = "arn:aws:iam::${var.control_tower_account_ids.logging}:role/AWSControlTowerExecution"
  }
}

resource "aws_cloudwatch_event_rule" "monitor_iam_access_logging" {
  for_each    = { for identity, identity_data in local.monitor_iam_access : identity => identity_data if try(identity_data.account, null) == "logging" || identity == "Root" }
  provider    = aws.logging
  name        = substr("LandingZone-MonitorIAMAccess-${each.key}", 0, 64)
  description = "Monitors IAM access for ${each.key}"

  event_pattern = templatefile("${path.module}/files/event_bridge/monitor_iam_access.json.tpl", {
    userIdentity = jsonencode(each.value.userIdentity)
  })

  depends_on = [
    data.aws_iam_role.monitor_iam_access_logging,
    data.aws_iam_user.monitor_iam_access_logging
  ]
}

resource "aws_cloudwatch_event_target" "monitor_iam_access_logging" {
  for_each   = aws_cloudwatch_event_rule.monitor_iam_access_logging
  provider   = aws.logging
  arn        = aws_cloudwatch_event_bus.monitor_iam_access_audit.arn
  role_arn   = aws_iam_role.monitor_iam_access_logging.arn
  rule       = each.value.name
  target_id  = "SendToAuditEventBus"
  depends_on = [aws_cloudwatch_event_permission.organization_access_audit]
}

resource "aws_config_aggregate_authorization" "logging" {
  for_each   = { for aggregator in local.aws_config_aggregators : "${aggregator.account_id}-${aggregator.region}" => aggregator if aggregator.account_id != var.control_tower_account_ids.audit }
  provider   = aws.logging
  account_id = each.value.account_id
  region     = each.value.region
}

resource "aws_iam_role" "monitor_iam_access_logging" {
  provider           = aws.logging
  name               = "LandingZone-MonitorIAMAccess"
  assume_role_policy = templatefile("${path.module}/files/iam/service_assume_role.json.tpl", { service = "events.amazonaws.com" })
  tags               = var.tags
}

resource "aws_iam_role_policy" "monitor_iam_access_logging" {
  provider = aws.logging
  name     = "LandingZone-MonitorIAMAccess"
  role     = aws_iam_role.monitor_iam_access_logging.id
  policy = templatefile("${path.module}/files/iam/monitor_iam_access_policy.json.tpl", {
    event_bus_arn = aws_cloudwatch_event_bus.monitor_iam_access_audit.arn
  })
}

module "datadog_logging" {
  count                 = try(var.datadog.enable_integration, false) == true ? 1 : 0
  source                = "github.com/schubergphilis/terraform-aws-mcaf-datadog?ref=v0.3.2"
  providers             = { aws = aws.logging }
  api_key               = try(var.datadog.api_key, null)
  install_log_forwarder = try(var.datadog.install_log_forwarder, false)
  tags                  = var.tags
}

resource "aws_iam_account_password_policy" "logging" {
  count                          = var.aws_create_account_password_policy ? 1 : 0
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
