data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "monitor_iam_access_audit_topic" {
  statement {
    actions = [
      "SNS:AddPermission",
      "SNS:DeleteTopic",
      "SNS:GetTopicAttributes",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
      "SNS:Receive",
      "SNS:RemovePermission",
      "SNS:SetTopicAttributes",
      "SNS:Subscribe"
    ]

    resources = [
      aws_sns_topic.monitor_iam_access_audit.arn
    ]

    sid = "__default_statement_ID"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        var.control_tower_account_ids.audit
      ]
    }
  }

  statement {
    actions = [
      "sns:Publish"
    ]

    resources = [
      aws_sns_topic.monitor_iam_access_audit.arn
    ]

    sid = "__events"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "monitor_iam_access" {
  statement {
    actions = [
      "events:PutEvents"
    ]

    resources = [
      aws_cloudwatch_event_bus.monitor_iam_access_audit.arn
    ]
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
