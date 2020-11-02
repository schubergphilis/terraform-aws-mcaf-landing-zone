provider "aws" {
  alias = "logging"

  assume_role {
    role_arn = "arn:aws:iam::${var.control_tower_account_ids.logging}:role/AWSControlTowerExecution"
  }
}

module "security_hub_logging" {
  source    = "./modules/security_hub"
  providers = { aws = aws.logging }
}
