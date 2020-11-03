data "aws_organizations_organization" "default" {}

provider "aws" {
  alias = "audit"

  assume_role {
    role_arn = "arn:aws:iam::${var.control_tower_account_ids.audit}:role/AWSControlTowerExecution"
  }
}

module "datadog_audit" {
  count                 = var.datadog_integration.audit.enabled == true ? 1 : 0
  source                = "github.com/schubergphilis/terraform-aws-mcaf-datadog?ref=v0.3.2"
  providers             = { aws = aws.audit }
  api_key               = var.datadog_integration.api_key
  install_log_forwarder = var.datadog_integration.audit.forward_logs
  tags                  = var.tags
}

module "security_hub_audit" {
  source    = "./modules/security_hub"
  providers = { aws = aws.audit }

  member_accounts = {
    for account in data.aws_organizations_organization.default.accounts : account.id => account.email if account.id != var.control_tower_account_ids.audit
  }
}
