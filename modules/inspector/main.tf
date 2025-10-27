locals {
  inspector_enabled_resource_types = compact([
    var.enable_scan_ec2 ? "EC2" : "",
    var.enable_scan_ecr ? "ECR" : "",
    var.enable_scan_lambda ? "LAMBDA" : "",
    var.enable_scan_lambda_code ? "LAMBDA_CODE" : "",
  ])
}

data "aws_caller_identity" "delegated_admin" {
  provider = aws.delegated_admin
}

// Amazon Inspector - Management account configuration
resource "aws_inspector2_delegated_admin_account" "default" {

  region = var.region

  account_id = data.aws_caller_identity.delegated_admin.account_id
}

// Amazon Inspector - Delegated administrator account configuration
resource "aws_inspector2_enabler" "delegated_admin" {
  provider = aws.delegated_admin

  region = var.region

  account_ids    = [data.aws_caller_identity.delegated_admin.account_id]
  resource_types = local.inspector_enabled_resource_types

  depends_on = [aws_inspector2_delegated_admin_account.default]
}

// Associate the member accounts with the delegated admin account
resource "aws_inspector2_member_association" "default" {
  for_each = toset(var.member_account_ids)
  provider = aws.delegated_admin

  region = var.region

  account_id = each.value

  depends_on = [aws_inspector2_enabler.delegated_admin]
}

// Activate Inspector in the member accounts
resource "aws_inspector2_enabler" "member_accounts" {
  provider = aws.delegated_admin

  region = var.region

  account_ids    = toset(var.member_account_ids)
  resource_types = local.inspector_enabled_resource_types

  timeouts {
    create = var.resource_create_timeout
  }

  depends_on = [aws_inspector2_member_association.default]
}

// Auto-enable Inspector in the new member accounts
resource "aws_inspector2_organization_configuration" "default" {
  provider = aws.delegated_admin

  region = var.region

  auto_enable {
    ec2         = var.enable_scan_ec2
    ecr         = var.enable_scan_ecr
    lambda      = var.enable_scan_lambda
    lambda_code = var.enable_scan_lambda_code
  }

  depends_on = [aws_inspector2_enabler.member_accounts]
}
