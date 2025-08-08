locals {
  security_baseline_input = {
    aws_ebs_encryption_by_default = var.aws_ebs_encryption_by_default
    aws_account_password_policy   = var.aws_account_password_policy
  }
}

module "security_baseline_master" {
  source = "./modules/security-baseline"

  security_baseline_input = local.security_baseline_input
}

module "security_baseline_audit" {
  providers = { aws = aws.audit }

  source = "./modules/security-baseline"

  security_baseline_input = local.security_baseline_input
}

module "security_baseline_logging" {
  providers = { aws = aws.logging }

  source = "./modules/security-baseline"

  security_baseline_input = local.security_baseline_input
}
