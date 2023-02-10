module "ses-root-accounts-mail-alias" {
  #checkov:skip=CKV_AWS_273: IAM user is the only option for SMTP auth
  count     = var.ses_root_accounts_mail_forward != null ? 1 : 0
  providers = { aws = aws, aws.route53 = aws }

  source     = "github.com/schubergphilis/terraform-aws-mcaf-ses?ref=v0.1.3"
  dmarc      = var.ses_root_accounts_mail_forward.dmarc
  domain     = var.ses_root_accounts_mail_forward.domain
  kms_key_id = module.kms_key.id
  tags       = var.tags
}

module "ses-root-accounts-mail-forward" {
  #checkov:skip=CKV_AWS_19: False positive: https://github.com/bridgecrewio/checkov/issues/3847. The S3 bucket created by this module is encrypted with KMS. 
  #checkov:skip=CKV_AWS_145: False positive: https://github.com/bridgecrewio/checkov/issues/3847. The S3 bucket created by this module is encrypted with KMS. 
  #checkov:skip=CKV_AWS_272: This module does not support lambda code signing at the moment 
  count     = var.ses_root_accounts_mail_forward != null ? 1 : 0
  providers = { aws = aws, aws.lambda = aws }

  source            = "github.com/schubergphilis/terraform-aws-mcaf-ses-forwarder?ref=v0.2.4"
  bucket_name       = "ses-forwarder-${replace(var.ses_root_accounts_mail_forward.domain, ".", "-")}"
  from_email        = var.ses_root_accounts_mail_forward.from_email
  kms_key_arn       = module.kms_key.arn
  recipient_mapping = var.ses_root_accounts_mail_forward.recipient_mapping
  tags              = var.tags
}
