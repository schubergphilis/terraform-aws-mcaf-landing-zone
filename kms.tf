# Master Account

module "kms_key" {
  source              = "github.com/schubergphilis/terraform-aws-mcaf-kms?ref=v0.2.0"
  name                = "inception"
  description         = "KMS key used in the master account"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms_key.json
  tags                = var.tags
}

data "aws_iam_policy_document" "kms_key" {
  source_policy_documents = [var.kms_key_policy]

  statement {
    sid       = "Full permissions for the root user only"
    actions   = ["kms:*"]
    effect    = "Allow"
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalType"
      values   = ["Account"]
    }

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.master.account_id}:root"
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
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.master.account_id}:role/AWSControlTowerExecution"
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
    resources = ["*"]

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
      resources = ["*"]

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
  source              = "github.com/schubergphilis/terraform-aws-mcaf-kms?ref=v0.2.0"
  providers           = { aws = aws.audit }
  name                = "audit"
  description         = "KMS key used for encrypting audit-related data"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms_key_audit.json
  tags                = var.tags
}

data "aws_iam_policy_document" "kms_key_audit" {
  source_policy_documents = [var.kms_key_policy_audit]

  statement {
    sid       = "Full permissions for the root user only"
    actions   = ["kms:*"]
    effect    = "Allow"
    resources = ["*"]

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
      "kms:Get*",
      "kms:List*",
      "kms:Put*",
      "kms:Revoke*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:Update*"
    ]
    effect    = "Allow"
    resources = ["*"]

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
    resources = ["*"]

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
    resources = ["*"]

    principals {
      type = "Service"
      identifiers = [
        "cloudwatch.amazonaws.com",
        "events.amazonaws.com"
      ]
    }
  }
}

# Logging Account
module "kms_key_logging" {
  source              = "github.com/schubergphilis/terraform-aws-mcaf-kms?ref=v0.2.0"
  providers           = { aws = aws.logging }
  name                = "logging"
  description         = "KMS key to use with logging account"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms_key_logging.json
  tags                = var.tags
}

data "aws_iam_policy_document" "kms_key_logging" {
  source_policy_documents = [var.kms_key_policy_logging]

  statement {
    sid       = "Full permissions for the root user only"
    actions   = ["kms:*"]
    effect    = "Allow"
    resources = ["*"]

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
    resources = ["*"]

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
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.logging.account_id}:root"
      ]
    }
  }
}
