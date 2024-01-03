resource "aws_auditmanager_account_registration" "default" {
  count = var.aws_auditmanager_config.enabled == true ? 1 : 0

  delegated_admin_account = data.aws_caller_identity.audit.account_id
  deregister_on_destroy   = true
  kms_key                 = module.kms_key_audit.arn
}

module "audit-manager-reports" {
  count = var.aws_auditmanager_config.enabled == true ? 1 : 0

  providers = { aws = aws.audit }

  source  = "schubergphilis/mcaf-s3/aws"
  version = "0.12.1"

  name_prefix = var.aws_auditmanager_config.reports_bucket_name
  versioning  = true

  lifecycle_rule = [
    {
      id      = "retention"
      enabled = true

      abort_incomplete_multipart_upload = {
        days_after_initiation = 7
      }

      noncurrent_version_expiration = {
        noncurrent_days = 90
      }

      noncurrent_version_transition = {
        noncurrent_days = 30
        storage_class   = "ONEZONE_IA"
      }
    }
  ]
}
