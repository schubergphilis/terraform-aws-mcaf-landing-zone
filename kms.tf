locals {

  # Audit Account
  decoded_policy_documents_audit = [for policy_json in var.kms_key_policy_audit : jsondecode(policy_json)]
  all_statements_audit = flatten([
    for policy in local.decoded_policy_documents_audit : try(coalesce(policy.Statement, policy.statement), [])
  ])
  user_sids_audit = [for statement in local.all_statements_audit : try(coalesce(statement.Sid, statement.sid),"")]
  has_admin_control_tower_sid_audit = contains(local.user_sids_audit, "Administrative permissions for pipeline")
  # Extract user-supplied statement matching the SID 'Administrative permissions for pipeline'
  user_admin_statement_audit = local.has_admin_control_tower_sid_audit ? one([
    for s in local.all_statements_audit :
    {
      actions = try(coalesce(s.Actions, s.actions), [])
    }
    if try(coalesce(s.Sid, s.sid), "") == "Administrative permissions for pipeline"
  ]) : []
  default_admin_control_tower_actions_audit = [
    "kms:Create*",
    "kms:Describe*",
    "kms:Enable*",
    "kms:GenerateDataKey*",
    "kms:Get*",
    "kms:List*",
    "kms:Put*",
    "kms:Revoke*",
    "kms:TagResource",
    "kms:UntagResource",
    "kms:Update*"
  ]
  merged_admin_control_tower_actions_audit = distinct(concat(
    local.default_admin_control_tower_actions_audit,
    try(local.user_admin_statement_audit.actions, [])
  ))

  # Logging Account
  decoded_policy_documents_logging = [for policy_json in var.kms_key_policy_logging : jsondecode(policy_json)]
  all_statements_logging = flatten([
    for policy in local.decoded_policy_documents_logging : try(coalesce(policy.Statement, policy.statement), [])
  ])
  user_sids_logging = [for statement in local.all_statements_logging : try(coalesce(statement.Sid, statement.sid),"")]
  has_admin_control_tower_sid_logging = contains(local.user_sids_logging, "Administrative permissions for pipeline")
  # Extract user-supplied statement matching the SID 'Administrative permissions for pipeline'
  user_admin_statement_logging = local.has_admin_control_tower_sid_logging ? one([
    for s in local.all_statements_logging :
    {
      actions = try(coalesce(s.Actions, s.actions), [])
    }
    if try(coalesce(s.Sid, s.sid), "") == "Administrative permissions for pipeline"
  ]) : []
  default_admin_control_tower_actions_logging = [
    "kms:Create*",
    "kms:Describe*",
    "kms:Enable*",
    "kms:Get*",
    "kms:List*",
    "kms:Put*",
    "kms:Revoke*",
    "kms:TagResource",
    "kms:UntagResource",
    "kms:Update*",
    "kms:GenerateDataKey*"
  ]
  merged_admin_control_tower_actions_logging = distinct(concat(
    local.default_admin_control_tower_actions_logging,
    try(local.user_admin_statement_logging.actions, [])
  ))
  
}

# Management Account
module "kms_key" {
  source  = "schubergphilis/mcaf-kms/aws"
  version = "~> 0.3.0"

  name                = "inception"
  description         = "KMS key used in the master account"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms_key.json
  tags                = var.tags
}

data "aws_iam_policy_document" "kms_key" {
  override_policy_documents = var.kms_key_policy

  statement {
    sid       = "Base Permissions"
    actions   = ["kms:*"]
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.management.account_id}:key/*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.management.account_id}:root"
      ]
    }
  }

  statement {
    sid = "Allow ControlTower CloudTrail Log Group Encryption"
    actions = [
      "kms:Decrypt",
      "kms:Describe*",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*"
    ]
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.management.account_id}:key/*"]

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"

      values = [
        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.management.account_id}:aws-controltower/CloudTrailLogs:*"
      ]
    }

    principals {
      type = "Service"
      identifiers = [
        "logs.${data.aws_region.current.name}.amazonaws.com"
      ]
    }
  }

  statement {
    sid       = "Allow Control Tower dependencies CloudWatch, CloudTrail, Config & SNS Decrypt"
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.management.account_id}:key/*"]

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]

    principals {
      type = "Service"
      identifiers = [
        "config.amazonaws.com",
        "cloudtrail.amazonaws.com",
        "cloudwatch.amazonaws.com",
        "events.amazonaws.com",
        "sns.amazonaws.com"
      ]
    }
  }

  dynamic "statement" {
    for_each = var.ses_root_accounts_mail_forward != null ? ["allow_ses"] : []
    content {
      sid       = "Allow SES Decrypt"
      effect    = "Allow"
      resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.management.account_id}:key/*"]

      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey*"
      ]

      principals {
        type = "Service"
        identifiers = [
          "ses.amazonaws.com"
        ]
      }
    }
  }

  dynamic "statement" {
    for_each = var.ses_root_accounts_mail_forward != null ? ["allow_cw_loggroup_email_forwarder"] : []
    content {
      sid       = "Allow EmailForwarder CloudWatch Log Group"
      effect    = "Allow"
      resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.management.account_id}:key/*"]

      actions = [
        "kms:Decrypt",
        "kms:Describe*",
        "kms:Encrypt",
        "kms:GenerateDataKey*",
        "kms:ReEncrypt*"
      ]

      condition {
        test     = "ArnLike"
        variable = "kms:EncryptionContext:aws:logs:arn"

        values = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.management.account_id}:log-group:/aws/lambda/EmailForwarder"
        ]
      }

      principals {
        type = "Service"
        identifiers = [
          "logs.${data.aws_region.current.name}.amazonaws.com"
        ]
      }
    }
  }
}

# Audit Account
module "kms_key_audit" {
  providers = { aws = aws.audit }

  source  = "schubergphilis/mcaf-kms/aws"
  version = "~> 0.3.0"

  name                = "audit"
  description         = "KMS key used for encrypting audit-related data"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms_key_audit.json
  tags                = var.tags
}

data "aws_iam_policy_document" "kms_key_audit" {
  source_policy_documents = var.kms_key_policy_audit

  statement {
    sid       = "Full permissions for the root user only"
    actions   = ["kms:*"]
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.audit.account_id}:key/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalType"
      values   = ["Account"]
    }

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.audit.account_id}:root"
      ]
    }
  }

  # Add merged 'Administrative permissions for pipeline' if user includes that SID
  dynamic "statement" {
    for_each = local.has_admin_control_tower_sid_audit ? [1] : []

    content {
      sid       = "Administrative permissions for pipeline"
      effect    = "Allow"
      resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.audit.account_id}:key/*"]

      actions = local.merged_admin_control_tower_actions_audit

      principals {
        type = "AWS"
        identifiers = [
          "arn:aws:iam::${data.aws_caller_identity.audit.account_id}:AWSControlTowerExecution"
        ]
      }
    }
  }
  statement {
    sid       = "List KMS keys permissions for all IAM users"
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.audit.account_id}:key/*"]

    actions = [
      "kms:Describe*",
      "kms:Get*",
      "kms:List*"
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.audit.account_id}:root"
      ]
    }
  }

  statement {
    sid       = "Allow CloudWatch Decrypt"
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.audit.account_id}:key/*"]

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]

    principals {
      type = "Service"
      identifiers = [
        "cloudwatch.amazonaws.com",
        "events.amazonaws.com"
      ]
    }
  }

  statement {
    sid       = "Allow SNS Decrypt"
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.audit.account_id}:key/*"]

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]

    principals {
      type = "Service"
      identifiers = [
        "sns.amazonaws.com"
      ]
    }
  }

  dynamic "statement" {
    for_each = var.aws_auditmanager.enabled ? ["allow_audit_manager"] : []

    content {
      sid       = "Allow Audit Manager from management to describe and grant"
      effect    = "Allow"
      resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.audit.account_id}:key/*"]

      actions = [
        "kms:CreateGrant",
        "kms:DescribeKey"
      ]

      principals {
        type = "AWS"
        identifiers = [
          "arn:aws:iam::${data.aws_caller_identity.management.account_id}:root"
        ]
      }

      condition {
        test     = "Bool"
        variable = "kms:ViaService"

        values = [
          "auditmanager.amazonaws.com"
        ]
      }
    }
  }

  dynamic "statement" {
    for_each = var.aws_auditmanager.enabled ? ["allow_audit_manager"] : []
    content {
      sid       = "Encrypt and Decrypt permissions for S3"
      effect    = "Allow"
      resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.management.account_id}:key/*"]

      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*"
      ]

      principals {
        type = "AWS"
        identifiers = [
          "arn:aws:iam::${data.aws_caller_identity.management.account_id}:root"
        ]
      }

      condition {
        test     = "StringLike"
        variable = "kms:ViaService"
        values = [
          "s3.${data.aws_region.current.name}.amazonaws.com",
        ]
      }
    }
  }
}

# Logging Account
module "kms_key_logging" {
  providers = { aws = aws.logging }

  source  = "schubergphilis/mcaf-kms/aws"
  version = "~> 0.3.0"

  name                = "logging"
  description         = "KMS key to use with logging account"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms_key_logging.json
  tags                = var.tags
}

data "aws_iam_policy_document" "kms_key_logging" {
  source_policy_documents = var.kms_key_policy_logging

  statement {
    sid       = "Full permissions for the root user only"
    actions   = ["kms:*"]
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.logging.account_id}:key/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalType"
      values   = ["Account"]
    }

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.logging.account_id}:root"
      ]
    }
  }

  # Add merged 'Administrative permissions for pipeline' if user includes that SID
  dynamic "statement" {
    for_each = local.has_admin_control_tower_sid_logging ? [1] : []

    content {
      sid       = "Administrative permissions for pipeline"
      effect    = "Allow"
      resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.logging.account_id}:key/*"]

      actions = local.merged_admin_control_tower_actions_logging

      principals {
        type = "AWS"
        identifiers = [
          "arn:aws:iam::${data.aws_caller_identity.logging.account_id}:AWSControlTowerExecution"
        ]
      }
    }
  }
  statement {
    sid       = "List KMS keys permissions for all IAM users"
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.logging.account_id}:key/*"]

    actions = [
      "kms:Describe*",
      "kms:Get*",
      "kms:List*"
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.logging.account_id}:root"
      ]
    }
  }

  statement {
    sid       = "KMS permissions for AWS logs service"
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.logging.account_id}:key/*"]

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
  }

  statement {
    sid       = "AllowAWSConfigToEncryptDecryptLogs"
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.logging.account_id}:key/*"]

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*"
    ]

    principals {
      type = "Service"
      identifiers = [
        "config.amazonaws.com"
      ]
    }
  }
}
