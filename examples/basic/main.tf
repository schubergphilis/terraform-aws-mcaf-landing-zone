locals {
  core_accounts = {
    audit   = "012345678902"
    logging = "012345678903"
  }
}

provider "aws" {}

provider "aws" {
  alias = "audit"

  assume_role {
    role_arn = "arn:aws:iam::${local.core_accounts.audit}:role/AWSControlTowerExecution"
  }
}

provider "aws" {
  alias = "logging"

  assume_role {
    role_arn = "arn:aws:iam::${local.core_accounts.logging}:role/AWSControlTowerExecution"
  }
}

provider "datadog" {
  validate = false
}

provider "mcaf" {
  aws {}
}

module "landing_zone" {
  providers = { aws = aws, aws.audit = aws.audit, aws.logging = aws.logging }

  source = "github.com/schubergphilis/terraform-aws-mcaf-landing-zone?ref=aliases"
  tags   = { Terraform = true }

  control_tower_account_ids = {
    audit   = local.core_accounts.audit
    logging = local.core_accounts.logging
  }
}
