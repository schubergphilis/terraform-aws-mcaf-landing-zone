# Management Account
module "kms_key" {
  source              = "github.com/schubergphilis/terraform-aws-mcaf-kms?ref=v0.2.0"
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
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.master.account_id}:key/*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.master.account_id}:root"
      ]
    }
  }

  dynamic "statement" {
    for_each = var.ses_root_accounts_mail_forward != null ? ["allow_ses"] : []
    content {
      sid       = "Allow SES Decrypt"
      effect    = "Allow"
      resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.master.account_id}:key/*"]

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
}

# Audit Account
module "kms_key_audit" {
  providers = { aws = aws.audit }

  source              = "github.com/schubergphilis/terraform-aws-mcaf-kms?ref=v0.2.0"
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

  statement {
    sid = "Administrative permissions for pipeline"
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
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.audit.account_id}:key/*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.audit.account_id}:role/AWSControlTowerExecution"
      ]
    }
  }

  statement {
    sid = "List KMS keys permissions for all IAM users"
    actions = [
      "kms:Describe*",
      "kms:Get*",
      "kms:List*"
    ]
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.audit.account_id}:key/*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.audit.account_id}:root"
      ]
    }
  }

  statement {
    sid = "Allow CloudWatch Decrypt"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.audit.account_id}:key/*"]

    principals {
      type = "Service"
      identifiers = [
        "cloudwatch.amazonaws.com",
        "events.amazonaws.com"
      ]
    }
  }

  statement {
    sid = "Allow SNS Decrypt"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.audit.account_id}:key/*"]

    principals {
      type = "Service"
      identifiers = [
        "sns.amazonaws.com"
      ]
    }
  }
}

# Logging Account
module "kms_key_logging" {
  providers = { aws = aws.logging }

  source              = "github.com/schubergphilis/terraform-aws-mcaf-kms?ref=v0.2.0"
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

  statement {
    sid = "Administrative permissions for pipeline"
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
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.logging.account_id}:key/*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.logging.account_id}:role/AWSControlTowerExecution"
      ]
    }
  }

  statement {
    sid = "List KMS keys permissions for all IAM users"
    actions = [
      "kms:Describe*",
      "kms:Get*",
      "kms:List*"
    ]
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.logging.account_id}:key/*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.logging.account_id}:root"
      ]
    }
  }

  statement {
    sid    = "KMS permissions for AWS logs service"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.logging.account_id}:key/*"]

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
  }

  statement {
    sid = "AllowAWSConfigToEncryptDecryptLogs"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*"
    ]
    effect    = "Allow"
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.logging.account_id}:key/*"]

    principals {
      type = "Service"
      identifiers = [
        "config.amazonaws.com"
      ]
    }
  }
}
