locals {
  inspector_members_account_ids = var.aws_inspector.enabled ? [
    for account in data.aws_organizations_organization.default.accounts : account.id if account.id != var.control_tower_account_ids.audit
  ] : []

  inspector_enabled_resource_types = var.aws_inspector.enabled ? compact([
    var.aws_inspector.enable_scan_ec2 ? "EC2" : "",
    var.aws_inspector.enable_scan_ecr ? "ECR" : "",
    var.aws_inspector.enable_scan_lambda ? "LAMBDA" : "",
    var.aws_inspector.enable_scan_lambda_code ? "LAMBDA_CODE" : "",
  ]) : []
}

// Delegate the admin account to the audit account
resource "aws_inspector2_delegated_admin_account" "default" {
  count = var.aws_inspector.enabled == true ? 1 : 0

  account_id = var.control_tower_account_ids.audit
}

// Activate Inspector in the audit account
resource "aws_inspector2_enabler" "audit_account" {
  count    = var.aws_inspector.enabled == true ? 1 : 0
  provider = aws.audit

  account_ids    = [var.control_tower_account_ids.audit]
  resource_types = local.inspector_enabled_resource_types

  depends_on = [aws_inspector2_delegated_admin_account.default]
}

// Associate the member accounts with the audit account
resource "aws_inspector2_member_association" "default" {
  for_each = toset(local.inspector_members_account_ids)
  provider = aws.audit

  account_id = each.value

  depends_on = [aws_inspector2_enabler.audit_account]
}

// Activate Inspector in the member accounts
resource "aws_inspector2_enabler" "member_accounts" {
  count    = var.aws_inspector.enabled == true ? 1 : 0
  provider = aws.audit

  account_ids    = toset(local.inspector_members_account_ids)
  resource_types = local.inspector_enabled_resource_types

  depends_on = [aws_inspector2_member_association.default]
}

// Auto-enable Inspector in the new member accounts
resource "aws_inspector2_organization_configuration" "default" {
  count    = var.aws_inspector.enabled == true ? 1 : 0
  provider = aws.audit

  auto_enable {
    ec2         = var.aws_inspector.enable_scan_ec2
    ecr         = var.aws_inspector.enable_scan_ecr
    lambda      = var.aws_inspector.enable_scan_lambda
    lambda_code = var.aws_inspector.enable_scan_lambda_code
  }

  depends_on = [aws_inspector2_enabler.member_accounts]
}
