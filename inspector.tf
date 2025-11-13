locals {
  inspector_members_account_ids = var.aws_inspector.enabled ? [
    for account in data.aws_organizations_organization.default.accounts : account.id
    if account.id != var.control_tower_account_ids.audit
    && !contains(var.aws_inspector.excluded_member_account_ids, account.id)
  ] : []
}

module "inspector" {
  for_each = var.aws_inspector.enabled == true ? local.all_governed_regions : []

  providers = {
    aws.management      = aws
    aws.delegated_admin = aws.audit
  }

  source = "./modules/inspector"

  region                  = each.key
  member_account_ids      = local.inspector_members_account_ids
  resource_create_timeout = var.aws_inspector.resource_create_timeout
  tags                    = var.tags

  enable_scan = {
    ec2         = var.aws_inspector.enable_scan_ec2
    ecr         = var.aws_inspector.enable_scan_ecr
    lambda      = var.aws_inspector.enable_scan_lambda
    lambda_code = var.aws_inspector.enable_scan_lambda_code
  }
}
