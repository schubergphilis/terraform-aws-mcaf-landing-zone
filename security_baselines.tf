module "security_baseline_master" {
  source  = "schubergphilis/mcaf-account-baseline/aws"
  version = "~> 6.0"

  account_password_policy                     = var.aws_account_password_policy
  aws_ebs_encryption_by_default               = var.aws_ebs_encryption_by_default
  aws_ebs_snapshot_block_public_access_state  = var.aws_ebs_snapshot_block_public_access_state
  aws_ec2_image_block_public_access_state     = var.aws_ec2_image_block_public_access_state
  aws_ssm_documents_public_sharing_permission = var.aws_ssm_documents_public_sharing_permission
  extra_regions_to_baseline                   = local.all_governed_regions
  tags                                        = var.tags
}

module "security_baseline_audit" {
  providers = { aws = aws.audit }

  source  = "schubergphilis/mcaf-account-baseline/aws"
  version = "~> 6.0"

  account_password_policy                     = var.aws_account_password_policy
  aws_ebs_encryption_by_default               = var.aws_ebs_encryption_by_default
  aws_ebs_snapshot_block_public_access_state  = var.aws_ebs_snapshot_block_public_access_state
  aws_ec2_image_block_public_access_state     = var.aws_ec2_image_block_public_access_state
  aws_ssm_documents_public_sharing_permission = var.aws_ssm_documents_public_sharing_permission
  extra_regions_to_baseline                   = local.all_governed_regions
  tags                                        = var.tags
}

module "security_baseline_logging" {
  providers = { aws = aws.logging }

  source  = "schubergphilis/mcaf-account-baseline/aws"
  version = "~> 6.0"

  account_password_policy                     = var.aws_account_password_policy
  aws_ebs_encryption_by_default               = var.aws_ebs_encryption_by_default
  aws_ebs_snapshot_block_public_access_state  = var.aws_ebs_snapshot_block_public_access_state
  aws_ec2_image_block_public_access_state     = var.aws_ec2_image_block_public_access_state
  aws_ssm_documents_public_sharing_permission = var.aws_ssm_documents_public_sharing_permission
  extra_regions_to_baseline                   = local.all_governed_regions
  tags                                        = var.tags
}
