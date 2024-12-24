locals {
  control_tower_account_ids = {
    audit   = "012345678902"
    logging = "012345678903"
  }
}

provider "aws" {
  region = "eu-central-1"
}

provider "aws" {
  alias  = "audit"
  region = "eu-central-1"

  assume_role {
    role_arn = "arn:aws:iam::${local.control_tower_account_ids.audit}:role/AWSControlTowerExecution"
  }
}

provider "aws" {
  alias  = "logging"
  region = "eu-central-1"

  assume_role {
    role_arn = "arn:aws:iam::${local.control_tower_account_ids.logging}:role/AWSControlTowerExecution"
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

  source = "../../"

  control_tower_account_ids = local.control_tower_account_ids

  regions = {
    allowed_regions = ["eu-central-1"]
    home_region     = "eu-central-1"
  }
}
