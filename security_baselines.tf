locals {
  kms_key_arns_management = {
    for region, module in module.kms_key :
    region => module.arn
  }

  kms_key_arns_audit = {
    for region, module in module.kms_key_audit :
    region => module.arn
  }

  kms_key_arns_logging = {
    for region, module in module.kms_key_logging :
    region => module.arn
  }
}

module "security_baseline_master" {
  source = "git::https://github.com/schubergphilis/terraform-aws-mcaf-account-baseline.git?ref=add-unblocked-ebs-snapshot-check"

  enable_additional_eu_regions                    = false
  extra_regions_to_baseline                       = local.all_governed_regions
  account_password_policy                         = var.aws_core_accounts_baseline_settings.account_password_policy
  aws_ebs_encryption_by_default                   = var.aws_core_accounts_baseline_settings.ebs_encryption_by_default
  aws_ebs_snapshot_block_public_access_state      = var.aws_core_accounts_baseline_settings.ebs_snapshot_block_public_access_state
  aws_ec2_image_block_public_access_state         = var.aws_core_accounts_baseline_settings.ec2_image_block_public_access_state
  aws_kms_key_arns                                = local.kms_key_arns_management
  aws_ssm_documents_public_sharing_permission     = var.aws_core_accounts_baseline_settings.ssm_documents_public_sharing_permission
  tags                                            = var.tags
}

module "security_baseline_audit" {
  providers = { aws = aws.audit }

  source = "git::https://github.com/schubergphilis/terraform-aws-mcaf-account-baseline.git?ref=add-unblocked-ebs-snapshot-check"

  enable_additional_eu_regions                    = false
  extra_regions_to_baseline                       = local.all_governed_regions
  account_password_policy                         = var.aws_core_accounts_baseline_settings.account_password_policy
  aws_ebs_encryption_by_default                   = var.aws_core_accounts_baseline_settings.ebs_encryption_by_default
  aws_ebs_snapshot_block_public_access_state      = var.aws_core_accounts_baseline_settings.ebs_snapshot_block_public_access_state
  aws_ec2_image_block_public_access_state         = var.aws_core_accounts_baseline_settings.ec2_image_block_public_access_state
  aws_kms_key_arns                                = local.kms_key_arns_audit
  aws_ssm_documents_public_sharing_permission     = var.aws_core_accounts_baseline_settings.ssm_documents_public_sharing_permission
  tags                                            = var.tags
}

module "security_baseline_logging" {
  providers = { aws = aws.logging }

  source = "git::https://github.com/schubergphilis/terraform-aws-mcaf-account-baseline.git?ref=add-unblocked-ebs-snapshot-check"

  enable_additional_eu_regions                    = false
  extra_regions_to_baseline                       = local.all_governed_regions
  account_password_policy                         = var.aws_core_accounts_baseline_settings.account_password_policy
  aws_ebs_encryption_by_default                   = var.aws_core_accounts_baseline_settings.ebs_encryption_by_default
  aws_ebs_snapshot_block_public_access_state      = var.aws_core_accounts_baseline_settings.ebs_snapshot_block_public_access_state
  aws_ec2_image_block_public_access_state         = var.aws_core_accounts_baseline_settings.ec2_image_block_public_access_state
  aws_kms_key_arns                                = local.kms_key_arns_logging
  aws_ssm_documents_public_sharing_permission     = var.aws_core_accounts_baseline_settings.ssm_documents_public_sharing_permission
  tags                                            = var.tags
}
