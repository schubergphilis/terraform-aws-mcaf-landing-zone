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

  monitor_iam_access = merge(
    {
      for identity in try(var.monitor_iam_access.identities, []) : identity.name => {
        "type"     = [identity.type]
        "userName" = identity.name
      } if identity.type == "IAMUser"
    },
    {
      for identity in try(var.monitor_iam_access.identities, []) : identity.name => {
        "type" = [identity.type]
        "sessionContext" = {
          "sessionIssuer" = {
            "userName" = identity.name
          }
        }
      } if identity.type == "AssumedRole"
    },
    {
      for identity in ["Root"] : identity => {
        "type" = [identity]
      } if try(var.monitor_iam_access.sns_topic_arn, null) != null
    }
  )
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

provider "aws" {
  alias  = "managed_by_inception"
  region = var.region

  assume_role {
    role_arn = "arn:aws:iam::${module.account.id}:role/AWSControlTowerExecution"
  }
}

data "aws_iam_role" "monitor_iam_access" {
  for_each = toset([for identity in try(var.monitor_iam_access.identities, []) : identity.name if identity.type == "AssumedRole"])
  provider = aws.managed_by_inception
  name     = each.value
}

data "aws_iam_user" "monitor_iam_access" {
  for_each  = toset([for identity in try(var.monitor_iam_access.identities, []) : identity.name if identity.type == "IAMUser"])
  provider  = aws.managed_by_inception
  user_name = each.value
}

resource "aws_cloudwatch_event_rule" "monitor_iam_access" {
  for_each    = local.monitor_iam_access
  provider    = aws.managed_by_inception
  name        = substr("LandingZone-MonitorIAMAccess-${each.key}", 0, 64)
  description = "Monitors IAM access for ${each.key}"

  event_pattern = templatefile("${path.module}/files/event_bridge/monitor_iam_access.json.tpl", {
    userIdentity = jsonencode(each.value)
  })

  depends_on = [data.aws_iam_role.monitor_iam_access, data.aws_iam_user.monitor_iam_access]
}

resource "aws_cloudwatch_event_target" "monitor_iam_access" {
  for_each  = aws_cloudwatch_event_rule.monitor_iam_access
  provider  = aws.managed_by_inception
  rule      = each.value.name
  target_id = "SendToSNS"
  arn       = var.monitor_iam_access.sns_topic_arn
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

module "security_hub" {
  source    = "../security_hub"
  providers = { aws = aws.managed_by_inception }
}

module "workspace" {
  source                 = "github.com/schubergphilis/terraform-aws-mcaf-workspace?ref=v0.2.2"
  providers              = { aws = aws.managed_by_inception }
  name                   = local.name
  auto_apply             = var.terraform_auto_apply
  branch                 = var.tfe_vcs_branch
  create_repository      = false
  github_organization    = var.defaults.github_organization
  github_repository      = var.name
  kms_key_id             = var.kms_key_id
  oauth_token_id         = var.oauth_token_id
  policy_arns            = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  region                 = var.region
  ssh_key_id             = var.ssh_key_id
  terraform_organization = var.defaults.terraform_organization
  terraform_version      = var.terraform_version != null ? var.terraform_version : var.defaults.terraform_version
  trigger_prefixes       = var.trigger_prefixes
  username               = "TFEPipeline"
  working_directory      = var.environment != null ? "terraform/${var.environment}" : "terraform"
  tags                   = var.tags
}
