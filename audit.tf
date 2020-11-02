data "aws_organizations_organization" "default" {}

provider "aws" {
  alias = "audit"

  assume_role {
    role_arn = "arn:aws:iam::${var.control_tower_account_ids.audit}:role/AWSControlTowerExecution"
  }
}

module "security_hub_audit" {
  source    = "./modules/security_hub"
  providers = { aws = aws.audit }

  member_accounts = {
    for account in data.aws_organizations_organization.default.accounts : account.id => account.email if account.id != var.control_tower_account_ids.audit
  }
}
