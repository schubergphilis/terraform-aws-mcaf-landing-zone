locals {
  inspector_members = var.aws_inspector.enabled ? [
    for account in data.aws_organizations_organization.default.accounts : account.id if account.id != var.control_tower_account_ids.audit
  ] : []
}

resource "aws_inspector2_delegated_admin_account" "default" {
  count = var.aws_inspector.enabled == true ? 1 : 0

  account_id = var.control_tower_account_ids.audit
}

resource "aws_inspector2_member_association" "default" {
  for_each = toset(local.inspector_members)

  account_id = each.value

  depends_on = [
    aws_inspector2_delegated_admin_account.default,
    aws_inspector2_organization_configuration.default
  ]
}

resource "aws_inspector2_organization_configuration" "default" {
  count    = var.aws_inspector.enabled == true ? 1 : 0
  provider = aws.audit

  auto_enable {
    ec2         = var.aws_inspector.auto_enable_ec2
    ecr         = var.aws_inspector.auto_enable_ecr
    lambda      = var.aws_inspector.auto_enable_lambda
    lambda_code = var.aws_inspector.auto_enable_lambda_code
  }

  depends_on = [
    aws_inspector2_delegated_admin_account.default
  ]
}
