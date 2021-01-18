provider "aws" {
  alias = "audit"

  assume_role {
    role_arn = "arn:aws:iam::${var.control_tower_account_ids.audit}:role/AWSControlTowerExecution"
  }
}

resource "aws_cloudwatch_event_bus" "monitor_iam_access_audit" {
  provider = aws.audit
  name     = "LandingZone-MonitorIAMAccess"
}

resource "aws_cloudwatch_event_permission" "organization_access_audit" {
  for_each       = { for account in data.aws_organizations_organization.default.accounts : account.id => account.name if account.id != var.control_tower_account_ids.audit }
  provider       = aws.audit
  event_bus_name = aws_cloudwatch_event_bus.monitor_iam_access_audit.name
  principal      = each.key
  statement_id   = "${each.value}Access"
}

resource "aws_cloudwatch_event_rule" "monitor_iam_access_audit" {
  for_each    = { for identity, identity_data in local.monitor_iam_access : identity => identity_data if try(identity_data.account, null) == "audit" || identity == "Root" }
  provider    = aws.audit
  name        = substr("LandingZone-MonitorIAMAccess-${each.key}", 0, 64)
  description = "Monitors IAM access for ${each.key}"

  event_pattern = templatefile("${path.module}/files/event_bridge/monitor_iam_access.json.tpl", {
    userIdentity = jsonencode(each.value.userIdentity)
  })

  depends_on = [
    data.aws_iam_role.monitor_iam_access_audit,
    data.aws_iam_user.monitor_iam_access_audit
  ]
}

resource "aws_cloudwatch_event_target" "monitor_iam_access_audit" {
  for_each  = aws_cloudwatch_event_rule.monitor_iam_access_audit
  provider  = aws.audit
  rule      = each.value.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.monitor_iam_access_audit.arn
}

resource "aws_cloudwatch_event_rule" "notify_iam_access_member_accounts" {
  provider       = aws.audit
  name           = "LandingZone-NotifyIAMAccessMemberAccounts"
  description    = "Monitors IAM access in member accounts"
  event_bus_name = aws_cloudwatch_event_bus.monitor_iam_access_audit.name
  event_pattern  = file("${path.module}/files/event_bridge/notify_iam_access.json.tpl")
}

resource "aws_cloudwatch_event_target" "notify_iam_access_member_accounts" {
  provider       = aws.audit
  arn            = aws_sns_topic.monitor_iam_access_audit.arn
  event_bus_name = aws_cloudwatch_event_bus.monitor_iam_access_audit.name
  rule           = aws_cloudwatch_event_rule.notify_iam_access_member_accounts.name
  target_id      = "SendToSNS"
}

resource "aws_cloudwatch_event_rule" "security_hub_findings" {
  provider      = aws.audit
  name          = "LandingZone-SecurityHubFindings"
  description   = "Rule for getting SecurityHub findings"
  event_pattern = file("${path.module}/files/event_bridge/security_hub_findings.json.tpl")
}

resource "aws_cloudwatch_event_target" "security_hub_findings" {
  provider  = aws.audit
  arn       = aws_sns_topic.security_hub_findings.arn
  rule      = aws_cloudwatch_event_rule.security_hub_findings.name
  target_id = "SendToSNS"
}

resource "aws_sns_topic" "security_hub_findings" {
  provider          = aws.audit
  name              = "LandingZone-SecurityHubFindings"
  kms_master_key_id = module.kms_key_audit.id
}

resource "aws_sns_topic_policy" "security_hub_findings" {
  provider = aws.audit
  arn      = aws_sns_topic.security_hub_findings.arn
  policy = templatefile("${path.module}/files/sns/topic_policy.json", {
    account_id = data.aws_caller_identity.audit.account_id
    sns_topic  = aws_sns_topic.security_hub_findings.arn
  })
}

resource "aws_sns_topic_subscription" "security_hub_findings" {
  for_each               = var.sns_aws_security_hub_subscription
  provider               = aws.audit
  endpoint               = each.value.endpoint
  endpoint_auto_confirms = length(regexall("http", each.value.protocol)) > 0
  protocol               = each.value.protocol
  topic_arn              = aws_sns_topic.security_hub_findings.arn
}

resource "aws_config_aggregate_authorization" "audit" {
  for_each   = { for aggregator in local.aws_config_aggregators : "${aggregator.account_id}-${aggregator.region}" => aggregator if aggregator.account_id != var.control_tower_account_ids.audit }
  provider   = aws.audit
  account_id = each.value.account_id
  region     = each.value.region
}

resource "aws_config_configuration_aggregator" "audit" {
  provider = aws.audit
  name     = "audit"

  account_aggregation_source {
    account_ids = [
      for account in data.aws_organizations_organization.default.accounts : account.id if account.id != var.control_tower_account_ids.audit
    ]
    all_regions = true
  }
}

resource "aws_sns_topic" "monitor_iam_access_audit" {
  provider          = aws.audit
  name              = "LandingZone-MonitorIAMAccess"
  kms_master_key_id = module.kms_key_audit.id
}

resource "aws_sns_topic_policy" "monitor_iam_access_audit" {
  provider = aws.audit
  arn      = aws_sns_topic.monitor_iam_access_audit.arn
  policy = templatefile("${path.module}/files/sns/topic_policy.json", {
    account_id = data.aws_caller_identity.audit.account_id
    sns_topic  = aws_sns_topic.monitor_iam_access_audit.arn
  })
}

resource "aws_guardduty_detector" "audit" {
  count    = var.aws_guardduty == true ? 1 : 0
  provider = aws.audit
}

resource "aws_guardduty_member" "logging" {
  count       = var.aws_guardduty == true ? 1 : 0
  provider    = aws.audit
  account_id  = aws_guardduty_detector.logging[0].account_id
  detector_id = aws_guardduty_detector.audit[0].id
  email       = local.aws_account_emails[aws_guardduty_detector.logging[0].account_id]
  invite      = true
  depends_on  = [aws_guardduty_organization_admin_account.audit]

  lifecycle {
    ignore_changes = [email]
  }
}

resource "aws_guardduty_member" "master" {
  count       = var.aws_guardduty == true ? 1 : 0
  provider    = aws.audit
  account_id  = aws_guardduty_detector.master[0].account_id
  detector_id = aws_guardduty_detector.audit[0].id
  email       = local.aws_account_emails[aws_guardduty_detector.master[0].account_id]
  invite      = true
  depends_on  = [aws_guardduty_organization_admin_account.audit]

  lifecycle {
    ignore_changes = [email]
  }
}

resource "aws_guardduty_organization_configuration" "default" {
  count       = var.aws_guardduty == true ? 1 : 0
  provider    = aws.audit
  auto_enable = true
  detector_id = aws_guardduty_detector.audit[0].id
  depends_on  = [aws_guardduty_organization_admin_account.audit]
}

module "datadog_audit" {
  count                 = try(var.datadog.enable_integration, false) == true ? 1 : 0
  source                = "github.com/schubergphilis/terraform-aws-mcaf-datadog?ref=v0.3.2"
  providers             = { aws = aws.audit }
  api_key               = try(var.datadog.api_key, null)
  install_log_forwarder = try(var.datadog.install_log_forwarder, false)
  tags                  = var.tags
}

module "kms_key_audit" {
  source              = "github.com/schubergphilis/terraform-aws-mcaf-kms?ref=v0.1.5"
  providers           = { aws = aws.audit }
  name                = "audit"
  description         = "KMS key used for encrypting audit-related data"
  enable_key_rotation = true
  tags                = var.tags

  policy = templatefile("${path.module}/files/kms/audit_key_policy.json", {
    audit_account_id  = var.control_tower_account_ids.audit
    master_account_id = data.aws_caller_identity.master.account_id
  })
}

module "security_hub_audit" {
  source    = "./modules/security_hub"
  providers = { aws = aws.audit }

  member_accounts = {
    for id, email in local.aws_account_emails : id => email if id != var.control_tower_account_ids.audit
  }
}

resource "aws_sns_topic_subscription" "aws_config" {
  for_each               = var.sns_aws_config_subscription
  provider               = aws.audit
  endpoint               = each.value.endpoint
  endpoint_auto_confirms = length(regexall("http", each.value.protocol)) > 0
  protocol               = each.value.protocol
  topic_arn              = "arn:aws:sns:${data.aws_region.current.name}:${var.control_tower_account_ids.audit}:aws-controltower-AggregateSecurityNotifications"
}

resource "aws_iam_account_password_policy" "audit" {
  count                          = var.aws_create_account_password_policy ? 1 : 0
  provider                       = aws.audit
  allow_users_to_change_password = var.aws_account_password_policy.allow_users_to_change
  max_password_age               = var.aws_account_password_policy.max_age
  minimum_password_length        = var.aws_account_password_policy.minimum_length
  password_reuse_prevention      = var.aws_account_password_policy.reuse_prevention_history
  require_lowercase_characters   = var.aws_account_password_policy.require_lowercase_characters
  require_numbers                = var.aws_account_password_policy.require_numbers
  require_symbols                = var.aws_account_password_policy.require_symbols
  require_uppercase_characters   = var.aws_account_password_policy.require_uppercase_characters
}
