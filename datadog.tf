module "datadog_audit" {
  #checkov:skip=CKV_AWS_124: since this is managed by terraform, we reason that this already provides feedback and a seperate SNS topic is therefore not required
  count     = try(var.datadog.enable_integration, false) == true ? 1 : 0
  providers = { aws = aws.audit }

  source  = "schubergphilis/mcaf-datadog/aws"
  version = "~> 0.8.5"

  api_key                              = try(var.datadog.api_key, null)
  cspm_resource_collection_enabled     = var.datadog.cspm_resource_collection_enabled
  excluded_regions                     = var.datadog_excluded_regions
  extended_resource_collection_enabled = var.datadog.extended_resource_collection_enabled
  install_log_forwarder                = var.datadog.install_log_forwarder
  log_collection_services              = var.datadog.log_collection_services
  log_forwarder_version                = var.datadog.log_forwarder_version
  metric_tag_filters                   = var.datadog.metric_tag_filters
  namespace_rules                      = var.datadog.namespace_rules
  site_url                             = try(var.datadog.site_url, null)
  tags                                 = var.tags
}

module "datadog_master" {
  #checkov:skip=CKV_AWS_124: since this is managed by terraform, we reason that this already provides feedback and a seperate SNS topic is therefore not required
  count = try(var.datadog.enable_integration, false) == true ? 1 : 0

  source  = "schubergphilis/mcaf-datadog/aws"
  version = "~> 0.8.5"

  api_key                              = try(var.datadog.api_key, null)
  cspm_resource_collection_enabled     = var.datadog.cspm_resource_collection_enabled
  excluded_regions                     = var.datadog_excluded_regions
  extended_resource_collection_enabled = var.datadog.extended_resource_collection_enabled
  install_log_forwarder                = var.datadog.install_log_forwarder
  log_collection_services              = var.datadog.log_collection_services
  log_forwarder_version                = var.datadog.log_forwarder_version
  metric_tag_filters                   = var.datadog.metric_tag_filters
  namespace_rules                      = var.datadog.namespace_rules
  site_url                             = try(var.datadog.site_url, null)
  tags                                 = var.tags
}

module "datadog_logging" {
  #checkov:skip=CKV_AWS_124: since this is managed by terraform, we reason that this already provides feedback and a seperate SNS topic is therefore not required
  count     = try(var.datadog.enable_integration, false) == true ? 1 : 0
  providers = { aws = aws.logging }

  source  = "schubergphilis/mcaf-datadog/aws"
  version = "~> 0.8.5"

  api_key                              = try(var.datadog.api_key, null)
  cspm_resource_collection_enabled     = var.datadog.cspm_resource_collection_enabled
  excluded_regions                     = var.datadog_excluded_regions
  extended_resource_collection_enabled = var.datadog.extended_resource_collection_enabled
  install_log_forwarder                = var.datadog.install_log_forwarder
  log_collection_services              = var.datadog.log_collection_services
  log_forwarder_version                = var.datadog.log_forwarder_version
  metric_tag_filters                   = var.datadog.metric_tag_filters
  namespace_rules                      = var.datadog.namespace_rules
  site_url                             = try(var.datadog.site_url, null)
  tags                                 = var.tags
}
