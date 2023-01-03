module "ses-root-accounts-mail-alias" {
  count     = var.ses_root_accounts_mail_forward != null ? 1 : 0
  providers = { aws = aws, aws.route53 = aws }
  source    = "github.com/schubergphilis/terraform-aws-mcaf-ses?ref=v0.1.2"

  dmarc      = var.ses_root_accounts_mail_forward.dmarc
  domain     = var.ses_root_accounts_mail_forward.domain
  kms_key_id = module.kms_key.id
  tags       = var.tags
}

module "ses-root-accounts-mail-forward" {
  count     = var.ses_root_accounts_mail_forward != null ? 1 : 0
  providers = { aws = aws, aws.lambda = aws }
  source    = "github.com/schubergphilis/terraform-aws-mcaf-ses-forwarder?ref=v0.2.2"

  bucket_name       = "ses-forwarder-${replace(var.ses_root_accounts_mail_forward.domain, ".", "-")}"
  from_email        = var.ses_root_accounts_mail_forward.from_email
  kms_key_arn       = module.kms_key.arn
  recipient_mapping = var.ses_root_accounts_mail_forward.recipient_mapping
  tags              = var.tags
}
