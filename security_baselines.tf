locals {
  security_baseline_input = {
    regions                                     = toset(var.regions.allowed_regions)
    aws_ebs_encryption_by_default               = var.aws_ebs_encryption_by_default
    aws_ebs_snapshot_block_public_access_state  = var.aws_ebs_snapshot_block_public_access_state
    aws_ssm_documents_public_sharing_permission = var.aws_ssm_documents_public_sharing_permission
    aws_ec2_image_block_public_access_state     = var.aws_ec2_image_block_public_access_state
    aws_account_password_policy                 = var.aws_account_password_policy
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
