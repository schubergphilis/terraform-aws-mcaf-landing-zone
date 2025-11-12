########################################
# MANAGEMENT ACCOUNT
########################################

module "kms_key" {
  for_each = local.all_governed_regions

  source  = "schubergphilis/mcaf-kms/aws"
  version = "~> 1.0.0"

  region              = each.value
  name                = "inception"
  description         = "KMS key used in the master account"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms_key[each.value].json
  tags                = var.tags
}

data "aws_iam_policy_document" "kms_key" {
  # One policy document per governed region
  for_each = local.all_governed_regions

  # Per-region extra JSON docs (if any)
  override_policy_documents = lookup(var.kms_key_policies_by_region, each.value, [])

  statement {
    sid       = "Base Permissions"
    actions   = ["kms:*"]
    effect    = "Allow"
    resources = ["arn:aws:kms:${each.value}:${data.aws_caller_identity.management.account_id}:key/*"]

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
    resources = ["arn:aws:kms:${each.value}:${data.aws_caller_identity.management.account_id}:key/*"]

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:aws:logs:${each.value}:${data.aws_caller_identity.management.account_id}:aws-controltower/CloudTrailLogs:*"
      ]
    }

    principals {
      type = "Service"
      identifiers = [
        "logs.${each.value}.amazonaws.com"
      ]
    }
  }

  statement {
    sid       = "Allow Control Tower dependencies CloudWatch, CloudTrail, Config & SNS Decrypt"
    effect    = "Allow"
    resources = ["arn:aws:kms:${each.value}:${data.aws_caller_identity.management.account_id}:key/*"]

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
      resources = ["arn:aws:kms:${each.value}:${data.aws_caller_identity.management.account_id}:key/*"]

      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey*"
      ]

      principals {
        type        = "Service"
        identifiers = ["ses.amazonaws.com"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.ses_root_accounts_mail_forward != null ? ["allow_cw_loggroup_email_forwarder"] : []
    content {
      sid       = "Allow EmailForwarder CloudWatch Log Group"
      effect    = "Allow"
      resources = ["arn:aws:kms:${each.value}:${data.aws_caller_identity.management.account_id}:key/*"]

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
          "arn:aws:logs:${each.value}:${data.aws_caller_identity.management.account_id}:log-group:/aws/lambda/EmailForwarder"
        ]
      }

      principals {
        type        = "Service"
        identifiers = ["logs.${each.value}.amazonaws.com"]
      }
    }
  }
}

########################################
# AUDIT ACCOUNT
########################################

module "kms_key_audit" {
  for_each  = local.all_governed_regions
  providers = { aws = aws.audit }

  source  = "schubergphilis/mcaf-kms/aws"
  version = "~> 1.0.0"

  region              = each.value
  name                = "audit"
  description         = "KMS key used for encrypting audit-related data"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms_key_audit[each.value].json
  tags                = var.tags
}

data "aws_iam_policy_document" "kms_key_audit" {
  # One policy document per governed region
  for_each = local.all_governed_regions

  # Per-region extra JSON docs (if any)
  source_policy_documents = lookup(var.kms_key_policies_audit_by_region, each.value, [])

  statement {
    sid       = "Full permissions for the root user only"
    actions   = ["kms:*"]
    effect    = "Allow"
    resources = ["arn:aws:kms:${each.value}:${data.aws_caller_identity.audit.account_id}:key/*"]

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

  statement {
    sid       = "Administrative permissions for pipeline"
    effect    = "Allow"
    resources = ["arn:aws:kms:${each.value}:${data.aws_caller_identity.audit.account_id}:key/*"]

    actions = [
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

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.audit.account_id}:role/AWSControlTowerExecution"
      ]
    }
  }

  statement {
    sid       = "List KMS keys permissions for all IAM users"
    effect    = "Allow"
    resources = ["arn:aws:kms:${each.value}:${data.aws_caller_identity.audit.account_id}:key/*"]

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
    resources = ["arn:aws:kms:${each.value}:${data.aws_caller_identity.audit.account_id}:key/*"]

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
    resources = ["arn:aws:kms:${each.value}:${data.aws_caller_identity.audit.account_id}:key/*"]

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
  }

  dynamic "statement" {
    for_each = var.aws_auditmanager.enabled ? ["allow_audit_manager"] : []
    content {
      sid       = "Allow Audit Manager from management to describe and grant"
      effect    = "Allow"
      resources = ["arn:aws:kms:${each.value}:${data.aws_caller_identity.audit.account_id}:key/*"]

      actions = [
        "kms:CreateGrant",
        "kms:DescribeKey"
      ]

      principals {
        type        = "AWS"
        identifiers = ["arn:aws:iam::${data.aws_caller_identity.management.account_id}:root"]
      }

      condition {
        test     = "Bool"
        variable = "kms:ViaService"
        values   = ["auditmanager.amazonaws.com"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.aws_auditmanager.enabled ? ["allow_audit_manager"] : []
    content {
      sid       = "Encrypt and Decrypt permissions for S3"
      effect    = "Allow"
      resources = ["arn:aws:kms:${each.value}:${data.aws_caller_identity.management.account_id}:key/*"]

      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*"
      ]

      principals {
        type        = "AWS"
        identifiers = ["arn:aws:iam::${data.aws_caller_identity.management.account_id}:root"]
      }

      condition {
        test     = "StringLike"
        variable = "kms:ViaService"
        values   = ["s3.${each.value}.amazonaws.com"]
      }
    }
  }
}

########################################
# LOGGING ACCOUNT
########################################

module "kms_key_logging" {
  for_each  = local.all_governed_regions
  providers = { aws = aws.logging }

  source  = "schubergphilis/mcaf-kms/aws"
  version = "~> 1.0.0"

  region              = each.value
  name                = "logging"
  description         = "KMS key to use with logging account"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms_key_logging[each.value].json
  tags                = var.tags
}

data "aws_iam_policy_document" "kms_key_logging" {
  # One policy document per governed region
  for_each = local.all_governed_regions

  # Per-region extra JSON docs (if any)
  source_policy_documents = lookup(var.kms_key_policies_logging_by_region, each.value, [])

  statement {
    sid       = "Full permissions for the root user only"
    actions   = ["kms:*"]
    effect    = "Allow"
    resources = ["arn:aws:kms:${each.value}:${data.aws_caller_identity.logging.account_id}:key/*"]

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

  statement {
    sid       = "Administrative permissions for pipeline"
    effect    = "Allow"
    resources = ["arn:aws:kms:${each.value}:${data.aws_caller_identity.logging.account_id}:key/*"]

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:Get*",
      "kms:List*",
      "kms:Put*",
      "kms:Revoke*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:Update*"
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.logging.account_id}:role/AWSControlTowerExecution"
      ]
    }
  }

  statement {
    sid       = "List KMS keys permissions for all IAM users"
    effect    = "Allow"
    resources = ["arn:aws:kms:${each.value}:${data.aws_caller_identity.logging.account_id}:key/*"]

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
    resources = ["arn:aws:kms:${each.value}:${data.aws_caller_identity.logging.account_id}:key/*"]

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    principals {
      type        = "Service"
      identifiers = ["logs.${each.value}.amazonaws.com"]
    }
  }

  statement {
    sid       = "AllowAWSConfigToEncryptDecryptLogs"
    effect    = "Allow"
    resources = ["arn:aws:kms:${each.value}:${data.aws_caller_identity.logging.account_id}:key/*"]

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*"
    ]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}
