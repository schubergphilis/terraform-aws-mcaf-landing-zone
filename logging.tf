provider "aws" {
  alias = "logging"

  assume_role {
    role_arn = "arn:aws:iam::${var.control_tower_account_ids.logging}:role/AWSControlTowerExecution"
  }
}

resource "aws_config_aggregate_authorization" "logging" {
  for_each   = { for aggregator in local.aws_config_aggregators : "${aggregator.account_id}-${aggregator.region}" => aggregator if aggregator.account_id != var.control_tower_account_ids.audit }
  provider   = aws.logging
  account_id = each.value.account_id
  region     = each.value.region
  tags       = var.tags
}

module "datadog_logging" {
  count                 = try(var.datadog.enable_integration, false) == true ? 1 : 0
  source                = "github.com/schubergphilis/terraform-aws-mcaf-datadog?ref=v0.3.8"
  providers             = { aws = aws.logging }
  api_key               = try(var.datadog.api_key, null)
  excluded_regions      = var.datadog_excluded_regions
  install_log_forwarder = try(var.datadog.install_log_forwarder, false)
  site_url              = try(var.datadog.site_url, null)
  tags                  = var.tags
}

resource "aws_iam_account_password_policy" "logging" {
  count                          = var.aws_account_password_policy != null ? 1 : 0
  provider                       = aws.logging
  allow_users_to_change_password = var.aws_account_password_policy.allow_users_to_change
  max_password_age               = var.aws_account_password_policy.max_age
  minimum_password_length        = var.aws_account_password_policy.minimum_length
  password_reuse_prevention      = var.aws_account_password_policy.reuse_prevention_history
  require_lowercase_characters   = var.aws_account_password_policy.require_lowercase_characters
  require_numbers                = var.aws_account_password_policy.require_numbers
  require_symbols                = var.aws_account_password_policy.require_symbols
  require_uppercase_characters   = var.aws_account_password_policy.require_uppercase_characters
}

resource "aws_ebs_encryption_by_default" "logging" {
  provider = aws.logging
  enabled  = var.aws_ebs_encryption_by_default
}

resource "aws_s3_account_public_access_block" "logging" {
  provider                = aws.logging
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
