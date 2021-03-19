locals {
  aws_config_aggregators = var.aws_config != null ? flatten([
    for account in var.aws_config.aggregator_account_ids : [
      for region in var.aws_config.aggregator_regions : {
        account_id = account
        region     = region
      }
    ]
  ]) : []

  email               = var.email != null ? var.email : "${local.prefixed_email}@schubergphilis.com"
  name                = var.environment != null ? "${var.name}-${var.environment}" : var.name
  prefixed_email      = "${var.defaults.email_prefix}${local.name}"
  prefixed_name       = "${var.defaults.account_iam_prefix}${local.name}"
  organizational_unit = var.organizational_unit != null ? var.organizational_unit : var.environment == "prod" ? "Production" : "Non-Production"

  iam_activity = merge(
    {
      Root = "{ $.userIdentity.type = \"Root\" }"
    },
    var.monitor_iam_activity_sso == true ? {
      SSO = "{ $.readOnly IS FALSE  && $.userIdentity.sessionContext.sessionIssuer.userName = \"AWSReservedSSO_*\" && $.eventName != \"ConsoleLogin\" }"
    } : {}
  )
}

provider "aws" {
  alias  = "managed_by_inception"
  region = var.region

  assume_role {
    role_arn = "arn:aws:iam::${module.account.id}:role/AWSControlTowerExecution"
  }
}

data "aws_cloudwatch_log_group" "cloudtrail" {
  provider = aws.managed_by_inception
  name     = "aws-controltower/CloudTrailLogs"
}

module "account" {
  source                   = "github.com/schubergphilis/terraform-aws-mcaf-account?ref=v0.3.0"
  account                  = coalesce(var.account_name, local.name)
  email                    = local.email
  organizational_unit      = local.organizational_unit
  provisioned_product_name = var.provisioned_product_name
  sso_email                = var.defaults.sso_email
  sso_firstname            = var.sso_firstname
  sso_lastname             = var.sso_lastname
}

module "workspace" {
  count                  = var.create_workspace ? 1 : 0
  source                 = "github.com/schubergphilis/terraform-aws-mcaf-workspace?ref=v0.4.1"
  providers              = { aws = aws.managed_by_inception }
  name                   = local.name
  agent_pool_id          = var.tfe_agent_pool_id
  auto_apply             = var.terraform_auto_apply
  branch                 = var.tfe_vcs_branch
  create_repository      = false
  execution_mode         = var.tfe_agent_pool_id != null ? "agent" : "remote"
  kms_key_id             = var.kms_key_id
  oauth_token_id         = var.oauth_token_id
  policy_arns            = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  region                 = var.region
  repository_name        = var.name
  repository_owner       = var.defaults.github_organization
  ssh_key_id             = var.ssh_key_id
  terraform_organization = var.defaults.terraform_organization
  terraform_version      = var.terraform_version != null ? var.terraform_version : var.defaults.terraform_version
  trigger_prefixes       = var.trigger_prefixes
  username               = "TFEPipeline"
  working_directory      = var.environment != null ? "terraform/${var.environment}" : "terraform"
  tags                   = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "iam_activity" {
  for_each       = var.monitor_iam_activity_sns_topic_arn != null ? local.iam_activity : {}
  provider       = aws.managed_by_inception
  name           = "BaseLine-IAMActivity-${each.key}"
  pattern        = each.value
  log_group_name = data.aws_cloudwatch_log_group.cloudtrail.name

  metric_transformation {
    name      = "BaseLine-IAMActivity-${each.key}"
    namespace = "BaseLine-IAMActivity"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "iam_activity" {
  for_each                  = aws_cloudwatch_log_metric_filter.iam_activity
  provider                  = aws.managed_by_inception
  alarm_name                = each.value.name
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = each.value.name
  namespace                 = each.value.metric_transformation.0.namespace
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitors IAM activity for ${each.key}"
  alarm_actions             = [var.monitor_iam_activity_sns_topic_arn]
  insufficient_data_actions = []
}

resource "aws_config_aggregate_authorization" "default" {
  for_each   = { for aggregator in local.aws_config_aggregators : "${aggregator.account_id}-${aggregator.region}" => aggregator }
  provider   = aws.managed_by_inception
  account_id = each.value.account_id
  region     = each.value.region
}

resource "aws_iam_account_alias" "alias" {
  provider      = aws.managed_by_inception
  account_alias = local.prefixed_name
}

resource "aws_iam_account_password_policy" "default" {
  count                          = var.create_account_password_policy ? 1 : 0
  provider                       = aws.managed_by_inception
  allow_users_to_change_password = var.account_password_policy.allow_users_to_change
  max_password_age               = var.account_password_policy.max_age
  minimum_password_length        = var.account_password_policy.minimum_length
  password_reuse_prevention      = var.account_password_policy.reuse_prevention_history
  require_lowercase_characters   = var.account_password_policy.require_lowercase_characters
  require_numbers                = var.account_password_policy.require_numbers
  require_symbols                = var.account_password_policy.require_symbols
  require_uppercase_characters   = var.account_password_policy.require_uppercase_characters
}

resource "aws_ebs_encryption_by_default" "default" {
  provider = aws.managed_by_inception
  enabled  = var.aws_ebs_encryption_by_default
}
