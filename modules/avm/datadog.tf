module "datadog" {
  count                 = var.datadog_integration == true ? 1 : 0
  providers             = { aws = aws.managed_by_inception }
  source                = "github.com/schubergphilis/terraform-aws-mcaf-datadog?ref=v0.3.2"
  api_key               = var.datadog_api_key
  install_log_forwarder = var.datadog_install_log_forwarder
  tags                  = local.tags
}
