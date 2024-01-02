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

  arn = aws_sns_topic.iam_activity[0].arn

  policy = templatefile("${path.module}/files/sns/iam_activity_topic_policy.json.tpl", {
    audit_account_id         = data.aws_caller_identity.audit.account_id
    mgmt_account_id          = data.aws_caller_identity.management.account_id
    services_allowed_publish = jsonencode("cloudwatch.amazonaws.com")
    sns_topic                = aws_sns_topic.iam_activity[0].arn

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
  topic_arn              = aws_sns_topic.iam_activity[0].arn
}

resource "aws_iam_role" "sns_feedback" {
  provider = aws.audit

  name = "LandingZone-SNSFeedback"
  path = var.path
  tags = var.tags

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

    resources = compact([aws_sns_topic.security_hub_findings.arn, var.monitor_iam_activity ? aws_sns_topic.iam_activity[0].arn : null])

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [data.aws_caller_identity.audit.account_id]
    }
  }
}

resource "aws_iam_role_policy" "sns_feedback_policy" {
  provider = aws.audit

  name   = "LandingZone-SNSFeedbackPolicy"
  policy = data.aws_iam_policy_document.sns_feedback.json
  role   = aws_iam_role.sns_feedback.id
}
