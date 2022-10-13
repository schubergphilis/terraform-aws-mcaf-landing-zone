provider "aws" {
  alias = "audit"

  assume_role {
    role_arn = "arn:aws:iam::${var.control_tower_account_ids.audit}:role/AWSControlTowerExecution"
  }
}

resource "aws_iam_account_password_policy" "audit" {
  count                          = var.aws_account_password_policy != null ? 1 : 0
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

resource "aws_ebs_encryption_by_default" "audit" {
  provider = aws.audit
  enabled  = var.aws_ebs_encryption_by_default
}

resource "aws_s3_account_public_access_block" "audit" {
  provider                = aws.audit
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// AWS Config
resource "aws_config_configuration_aggregator" "audit" {
  provider = aws.audit
  name     = "audit"
  tags     = var.tags

  account_aggregation_source {
    account_ids = [
      for account in data.aws_organizations_organization.default.accounts : account.id if account.id != var.control_tower_account_ids.audit
    ]
    all_regions = true
  }
}

resource "aws_config_aggregate_authorization" "audit" {
  for_each   = { for aggregator in local.aws_config_aggregators : "${aggregator.account_id}-${aggregator.region}" => aggregator if aggregator.account_id != var.control_tower_account_ids.audit }
  provider   = aws.audit
  account_id = each.value.account_id
  region     = each.value.region
  tags       = var.tags
}

resource "aws_sns_topic_subscription" "aws_config" {
  for_each               = var.aws_config_sns_subscription
  provider               = aws.audit
  endpoint               = each.value.endpoint
  endpoint_auto_confirms = length(regexall("http", each.value.protocol)) > 0
  protocol               = each.value.protocol
  topic_arn              = "arn:aws:sns:${data.aws_region.current.name}:${var.control_tower_account_ids.audit}:aws-controltower-AggregateSecurityNotifications"
}

// Guardduty
resource "aws_guardduty_organization_admin_account" "audit" {
  count            = var.aws_guardduty == true ? 1 : 0
  admin_account_id = var.control_tower_account_ids.audit
}

resource "aws_guardduty_organization_configuration" "default" {
  count       = var.aws_guardduty == true ? 1 : 0
  provider    = aws.audit
  auto_enable = true
  detector_id = aws_guardduty_detector.audit[0].id
  depends_on  = [aws_guardduty_organization_admin_account.audit]
}

resource "aws_guardduty_detector" "audit" {
  count    = var.aws_guardduty == true ? 1 : 0
  provider = aws.audit
  tags     = var.tags

  datasources {
    s3_logs {
      enable = var.aws_guardduty_s3_protection
    }
  }
}

// Security Hub
resource "aws_securityhub_account" "default" {
  provider = aws.audit
}

resource "aws_securityhub_organization_admin_account" "default" {
  admin_account_id = data.aws_caller_identity.audit.account_id
  depends_on       = [aws_securityhub_account.default]
}

resource "aws_securityhub_organization_configuration" "default" {
  provider    = aws.audit
  auto_enable = true
  depends_on  = [aws_securityhub_organization_admin_account.default]
}

resource "aws_securityhub_product_subscription" "default" {
  for_each    = toset(var.aws_security_hub_product_arns)
  provider    = aws.audit
  product_arn = each.value
  depends_on  = [aws_securityhub_account.default]
}

resource "aws_securityhub_standards_subscription" "default" {
  for_each      = toset(local.security_hub_standards_arns)
  provider      = aws.audit
  standards_arn = each.value
  depends_on    = [aws_securityhub_account.default]
}

resource "aws_cloudwatch_event_rule" "security_hub_findings" {
  provider      = aws.audit
  name          = "LandingZone-SecurityHubFindings"
  description   = "Rule for getting SecurityHub findings"
  event_pattern = file("${path.module}/files/event_bridge/security_hub_findings.json.tpl")
  tags          = var.tags
}

resource "aws_cloudwatch_event_target" "security_hub_findings" {
  provider  = aws.audit
  arn       = aws_sns_topic.security_hub_findings.arn
  rule      = aws_cloudwatch_event_rule.security_hub_findings.name
  target_id = "SendToSNS"
}

resource "aws_sns_topic" "security_hub_findings" {
  provider                       = aws.audit
  name                           = "LandingZone-SecurityHubFindings"
  http_success_feedback_role_arn = aws_iam_role.sns_feedback.arn
  http_failure_feedback_role_arn = aws_iam_role.sns_feedback.arn
  kms_master_key_id              = module.kms_key_audit.id
  tags                           = var.tags
}

resource "aws_sns_topic_policy" "security_hub_findings" {
  provider = aws.audit
  arn      = aws_sns_topic.security_hub_findings.arn
  policy = templatefile("${path.module}/files/sns/security_hub_topic_policy.json.tpl", {
    account_id               = data.aws_caller_identity.audit.account_id
    services_allowed_publish = jsonencode("events.amazonaws.com")
    sns_topic                = aws_sns_topic.security_hub_findings.arn
  })
}

resource "aws_sns_topic_subscription" "security_hub_findings" {
  for_each               = var.aws_security_hub_sns_subscription
  provider               = aws.audit
  endpoint               = each.value.endpoint
  endpoint_auto_confirms = length(regexall("http", each.value.protocol)) > 0
  protocol               = each.value.protocol
  topic_arn              = aws_sns_topic.security_hub_findings.arn
}

// Monitoring
module "datadog_audit" {
  count                 = try(var.datadog.enable_integration, false) == true ? 1 : 0
  source                = "github.com/schubergphilis/terraform-aws-mcaf-datadog?ref=v0.3.8"
  providers             = { aws = aws.audit }
  api_key               = try(var.datadog.api_key, null)
  excluded_regions      = var.datadog_excluded_regions
  install_log_forwarder = try(var.datadog.install_log_forwarder, false)
  site_url              = try(var.datadog.site_url, null)
  tags                  = var.tags
}

resource "aws_sns_topic" "iam_activity" {
  count    = var.monitor_iam_activity ? 1 : 0
  provider = aws.audit

  name                           = "LandingZone-IAMActivity"
  http_success_feedback_role_arn = aws_iam_role.sns_feedback.arn
  http_failure_feedback_role_arn = aws_iam_role.sns_feedback.arn
  kms_master_key_id              = module.kms_key_audit.id
  tags                           = var.tags
}

resource "aws_sns_topic_policy" "iam_activity" {
  count    = var.monitor_iam_activity ? 1 : 0
  provider = aws.audit

  arn = aws_sns_topic.iam_activity.0.arn

  policy = templatefile("${path.module}/files/sns/iam_activity_topic_policy.json.tpl", {
    account_id               = data.aws_caller_identity.audit.account_id
    services_allowed_publish = jsonencode("cloudwatch.amazonaws.com")
    sns_topic                = aws_sns_topic.iam_activity.0.arn

    security_hub_roles = local.security_hub_has_cis_aws_foundations_enabled ? sort([
      for account_id, _ in local.aws_account_emails : "\"arn:aws:sts::${account_id}:assumed-role/AWSServiceRoleForSecurityHub/securityhub\""
      if account_id != var.control_tower_account_ids.audit
    ]) : []
  })
}

resource "aws_sns_topic_subscription" "iam_activity" {
  for_each = var.monitor_iam_activity ? var.monitor_iam_activity_sns_subscription : {}
  provider = aws.audit

  endpoint               = each.value.endpoint
  endpoint_auto_confirms = length(regexall("http", each.value.protocol)) > 0
  protocol               = each.value.protocol
  topic_arn              = aws_sns_topic.iam_activity.0.arn
}

resource "aws_iam_role" "sns_feedback" {
  provider = aws.audit
  name     = "LandingZone-SNSFeedback"
  tags     = var.tags

  assume_role_policy = templatefile("${path.module}/files/iam/service_assume_role.json.tpl", {
    service = "sns.amazonaws.com"
  })
}

data "aws_iam_policy_document" "sns_feedback" {
  statement {
    sid = "SNSFeedbackPolicy"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutMetricFilter",
      "logs:PutRetentionPolicy"
    ]

    resources = compact([aws_sns_topic.security_hub_findings.arn, var.monitor_iam_activity ? aws_sns_topic.iam_activity.0.arn : null])

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = [data.aws_caller_identity.audit.account_id]
    }
  }
}

resource "aws_iam_role_policy" "sns_feedback_policy" {
  provider = aws.audit
  name     = "LandingZone-SNSFeedbackPolicy"
  policy   = data.aws_iam_policy_document.sns_feedback.json
  role     = aws_iam_role.sns_feedback.id
}
