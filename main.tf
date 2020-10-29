provider "aws" {
  alias = "audit"

  assume_role {
    role_arn = "arn:aws:iam::${var.audit_account_id}:role/AWSControlTowerExecution"
  }
}

module "kms_key" {
  source      = "github.com/schubergphilis/terraform-aws-mcaf-kms?ref=v0.1.5"
  name        = "inception"
  description = "KMS key used for encrypting SSM parameters"
  tags        = var.tags
}

module "security_hub" {
  source    = "./modules/security_hub"
  providers = { aws = aws.audit }
}
