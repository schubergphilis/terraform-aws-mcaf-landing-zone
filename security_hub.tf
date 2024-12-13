// AWS Security Hub - Management account configuration and enrollment
locals {
  security_configuration_type = (
    var.aws_security_hub.organization_configuration_type == "CENTRAL" ? "NONE" :
    (var.aws_security_hub.auto_enable_default_standards ? "DEFAULT" : "NONE")
  )
}
resource "aws_securityhub_organization_admin_account" "default" {
  admin_account_id = data.aws_caller_identity.audit.account_id

  depends_on = [aws_securityhub_account.default]
}

resource "aws_securityhub_account" "management" {
  control_finding_generator = var.aws_security_hub.control_finding_generator

  depends_on = [aws_securityhub_organization_configuration.default]
}

resource "aws_securityhub_member" "management" {
  provider = aws.audit

  account_id = data.aws_caller_identity.management.account_id

  depends_on = [aws_securityhub_account.management]

  lifecycle {
    ignore_changes = [invite]
  }
}

resource "aws_securityhub_standards_subscription" "management" {
  for_each = toset(local.security_hub_standards_arns)

  standards_arn = each.value

  depends_on = [aws_securityhub_account.default]
}

// AWS Security Hub - Audit account configuration and enrollment
resource "aws_securityhub_account" "default" {
  provider = aws.audit

  control_finding_generator = var.aws_security_hub.control_finding_generator
}

resource "aws_securityhub_organization_configuration" "default" {
  provider = aws.audit

  auto_enable           = var.aws_security_hub.organization_configuration_type == "CENTRAL" ? false : var.aws_security_hub.auto_enable_new_accounts
  auto_enable_standards = local.security_configuration_type

  organization_configuration {
    configuration_type = var.aws_security_hub.organization_configuration_type
  }

  depends_on = [aws_securityhub_organization_admin_account.default, aws_securityhub_finding_aggregator.default]
}

resource "aws_securityhub_product_subscription" "default" {
  for_each = toset(var.aws_security_hub.product_arns)
  provider = aws.audit

  product_arn = each.value

  depends_on = [aws_securityhub_account.default]
}

resource "aws_securityhub_standards_subscription" "default" {
  for_each = toset(local.security_hub_standards_arns)
  provider = aws.audit

  standards_arn = each.value

  depends_on = [aws_securityhub_account.default]
}

resource "aws_cloudwatch_event_rule" "security_hub_findings" {
  provider = aws.audit

  name          = "LandingZone-SecurityHubFindings"
  description   = "Rule for getting SecurityHub findings"
  event_pattern = file("${path.module}/files/event_bridge/security_hub_findings.json.tpl")
  tags          = var.tags
}

resource "aws_cloudwatch_event_target" "security_hub_findings" {
  provider = aws.audit

  arn       = aws_sns_topic.security_hub_findings.arn
  rule      = aws_cloudwatch_event_rule.security_hub_findings.name
  target_id = "SendToSNS"
}

resource "aws_sns_topic" "security_hub_findings" {
  provider = aws.audit

  name                           = "LandingZone-SecurityHubFindings"
  http_success_feedback_role_arn = aws_iam_role.sns_feedback.arn
  http_failure_feedback_role_arn = aws_iam_role.sns_feedback.arn
  kms_master_key_id              = module.kms_key_audit.id
  tags                           = var.tags
}

resource "aws_sns_topic_policy" "security_hub_findings" {
  provider = aws.audit

  arn = aws_sns_topic.security_hub_findings.arn
  policy = templatefile("${path.module}/files/sns/security_hub_topic_policy.json.tpl", {
    account_id               = data.aws_caller_identity.audit.account_id
    services_allowed_publish = jsonencode("events.amazonaws.com")
    sns_topic                = aws_sns_topic.security_hub_findings.arn
  })
}

resource "aws_sns_topic_subscription" "security_hub_findings" {
  for_each = var.aws_security_hub_sns_subscription
  provider = aws.audit

  endpoint               = each.value.endpoint
  endpoint_auto_confirms = length(regexall("http", each.value.protocol)) > 0
  protocol               = each.value.protocol
  topic_arn              = aws_sns_topic.security_hub_findings.arn
}

// AWS Security Hub - Logging account enrollment
resource "aws_securityhub_member" "logging" {
  provider = aws.audit

  account_id = data.aws_caller_identity.logging.account_id

  lifecycle {
    ignore_changes = [invite]
  }

  depends_on = [aws_securityhub_organization_configuration.default]
}

resource "aws_securityhub_standards_subscription" "logging" {
  for_each = toset(local.security_hub_standards_arns)
  provider = aws.logging

  standards_arn = each.value
  depends_on    = [aws_securityhub_account.default]
}

resource "aws_securityhub_finding_aggregator" "default" {
  linking_mode      = var.aws_security_hub.linking_mode
  specified_regions = var.aws_security_hub.specified_regions

  depends_on = [aws_securityhub_account.default]
}
