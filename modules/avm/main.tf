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
  prefixed_email      = "${var.defaults.account_prefix}-aws-${local.name}"
  prefixed_name       = "${var.defaults.account_prefix}-${local.name}"
  organizational_unit = var.organizational_unit != null ? var.organizational_unit : var.environment == "prod" ? "Production" : "Non-Production"
}

module "account" {
  source                   = "github.com/schubergphilis/terraform-aws-mcaf-account?ref=v0.3.0"
  account                  = local.name
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
