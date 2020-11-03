provider "aws" {
  alias = "logging"

  assume_role {
    role_arn = "arn:aws:iam::${var.control_tower_account_ids.logging}:role/AWSControlTowerExecution"
  }
}

module "datadog_logging" {
  count                 = var.datadog_integration.logging.enabled == true ? 1 : 0
  source                = "github.com/schubergphilis/terraform-aws-mcaf-datadog?ref=v0.3.2"
  providers             = { aws = aws.logging }
  api_key               = var.datadog_integration.api_key
  install_log_forwarder = var.datadog_integration.logging.forward_logs
  tags                  = var.tags
}

module "security_hub_logging" {
  source    = "./modules/security_hub"
  providers = { aws = aws.logging }
}
