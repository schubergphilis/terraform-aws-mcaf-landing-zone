data "aws_iam_policy_document" "monitor_iam_access_sns_topic_policy" {
  provider = aws.audit

  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"

      values = [
        data.aws_organizations_organization.default.id
      ]
    }

    resources = [aws_sns_topic.monitor_iam_access.arn]
  }
}

data "aws_iam_role" "monitor_iam_access_audit" {
  for_each = toset([for identity in coalesce(var.monitor_iam_access, []) : identity.name if identity.type == "AssumedRole" && identity.account == "audit"])
  provider = aws.audit
  name     = each.value
}

data "aws_iam_user" "monitor_iam_access_audit" {
  for_each  = toset([for identity in coalesce(var.monitor_iam_access, []) : identity.name if identity.type == "IAMUser" && identity.account == "audit"])
  provider  = aws.audit
  user_name = each.value
}

data "aws_iam_role" "monitor_iam_access_logging" {
  for_each = toset([for identity in coalesce(var.monitor_iam_access, []) : identity.name if identity.type == "AssumedRole" && identity.account == "logging"])
  provider = aws.logging
  name     = each.value
}

data "aws_iam_user" "monitor_iam_access_logging" {
  for_each  = toset([for identity in coalesce(var.monitor_iam_access, []) : identity.name if identity.type == "IAMUser" && identity.account == "logging"])
  provider  = aws.logging
  user_name = each.value
}

data "aws_iam_role" "monitor_iam_access_master" {
  for_each = toset([for identity in coalesce(var.monitor_iam_access, []) : identity.name if identity.type == "AssumedRole" && identity.account == "master"])
  name     = each.value
}

data "aws_iam_user" "monitor_iam_access_master" {
  for_each  = toset([for identity in coalesce(var.monitor_iam_access, []) : identity.name if identity.type == "IAMUser" && identity.account == "master"])
  user_name = each.value
}

data "aws_organizations_organization" "default" {}

data "aws_region" "current" {}

data "aws_sns_topic" "all_config_notifications" {
  provider = aws.audit
  name     = "aws-controltower-AllConfigNotifications"
}
