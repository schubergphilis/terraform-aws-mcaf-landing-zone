module "datadog" {
  count                 = try(var.datadog.enable_integration, false) == true ? 1 : 0
  source                = "github.com/schubergphilis/terraform-aws-mcaf-datadog?ref=v0.3.3"
  providers             = { aws = aws.managed_by_inception }
  api_key               = try(var.datadog.api_key, null)
  install_log_forwarder = try(var.datadog.install_log_forwarder, false)
  site_url              = try(var.datadog.site_url, null)
  tags                  = var.tags
}
