module "datadog" {
  count                 = var.datadog_integration == true ? 1 : 0
  source                = "github.com/schubergphilis/terraform-aws-mcaf-datadog?ref=v0.3.2"
  providers             = { aws = aws.managed_by_inception }
  api_key               = var.datadog_api_key
  install_log_forwarder = var.datadog_install_log_forwarder
  tags                  = local.tags
}
