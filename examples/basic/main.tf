locals {
  control_tower_account_ids = {
    audit   = "012345678902"
    logging = "012345678903"
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias  = "audit"
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::${local.control_tower_account_ids.audit}:role/AWSControlTowerExecution"
  }
}

provider "aws" {
  alias  = "logging"
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::${local.control_tower_account_ids.logging}:role/AWSControlTowerExecution"
  }
}

provider "datadog" {
  validate = false
}

provider "mcaf" {
  aws {
    region = "eu-west-1"
  }
}

module "landing_zone" {
  providers = { aws = aws, aws.audit = aws.audit, aws.logging = aws.logging }

  source = "../../"
  aws_security_hub = {
    disabled_standards_arns = [{
      standards_control_arn = "bla"
      disabled_reason       = "Daarom"
      }, {
      standards_control_arn = "bla"
      disabled_reason       = "Daarom"
    }]
  }
  control_tower_account_ids = local.control_tower_account_ids
  tags                      = { Terraform = true }
}
