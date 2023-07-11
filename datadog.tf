module "datadog_audit" {
  #checkov:skip=CKV_AWS_124: since this is managed by terraform, we reason that this already provides feedback and a seperate SNS topic is therefore not required
  count     = try(var.datadog.enable_integration, false) == true ? 1 : 0
  providers = { aws = aws.audit }

  source                  = "github.com/schubergphilis/terraform-aws-mcaf-datadog?ref=v0.3.11"
  api_key                 = try(var.datadog.api_key, null)
  excluded_regions        = var.datadog_excluded_regions
  install_log_forwarder   = try(var.datadog.install_log_forwarder, false)
  log_collection_services = try(var.datadog.log_collection_services, [])
  site_url                = try(var.datadog.site_url, null)
  tags                    = var.tags
}

module "datadog_master" {
  #checkov:skip=CKV_AWS_124: since this is managed by terraform, we reason that this already provides feedback and a seperate SNS topic is therefore not required
  count = try(var.datadog.enable_integration, false) == true ? 1 : 0

  source                  = "github.com/schubergphilis/terraform-aws-mcaf-datadog?ref=v0.3.11"
  api_key                 = try(var.datadog.api_key, null)
  excluded_regions        = var.datadog_excluded_regions
  install_log_forwarder   = try(var.datadog.install_log_forwarder, false)
  log_collection_services = try(var.datadog.log_collection_services, [])
  site_url                = try(var.datadog.site_url, null)
  tags                    = var.tags
}

module "datadog_logging" {
  #checkov:skip=CKV_AWS_124: since this is managed by terraform, we reason that this already provides feedback and a seperate SNS topic is therefore not required
  count     = try(var.datadog.enable_integration, false) == true ? 1 : 0
  providers = { aws = aws.logging }

  source                  = "github.com/schubergphilis/terraform-aws-mcaf-datadog?ref=v0.3.11"
  api_key                 = try(var.datadog.api_key, null)
  excluded_regions        = var.datadog_excluded_regions
  install_log_forwarder   = try(var.datadog.install_log_forwarder, false)
  log_collection_services = try(var.datadog.log_collection_services, [])
  site_url                = try(var.datadog.site_url, null)
  tags                    = var.tags
}
