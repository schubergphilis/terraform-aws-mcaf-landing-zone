provider "aws" {
  alias = "logging"

  assume_role {
    role_arn = "arn:aws:iam::${var.control_tower_account_ids.logging}:role/AWSControlTowerExecution"
  }
}

resource "aws_config_aggregate_authorization" "logging" {
  for_each   = { for aggregator in local.aws_config_aggregators : "${aggregator.account_id}-${aggregator.region}" => aggregator }
  provider   = aws.logging
  account_id = each.value.account_id
  region     = each.value.region
}

module "datadog_logging" {
  count                 = try(var.datadog.enable_integration, false) == true ? 1 : 0
  source                = "github.com/schubergphilis/terraform-aws-mcaf-datadog?ref=v0.3.2"
  providers             = { aws = aws.logging }
  api_key               = try(var.datadog.api_key, null)
  install_log_forwarder = try(var.datadog.install_log_forwarder, false)
  tags                  = var.tags
}

module "security_hub_logging" {
  source    = "./modules/security_hub"
  providers = { aws = aws.logging }
}
