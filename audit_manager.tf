resource "aws_auditmanager_account_registration" "default" {
  count = var.aws_auditmanager.enabled == true ? 1 : 0

  delegated_admin_account = data.aws_caller_identity.audit.account_id
  deregister_on_destroy   = true
  kms_key                 = module.kms_key_audit[var.regions.home_region].arn
}

module "audit_manager_reports" {
  count     = var.aws_auditmanager.enabled == true ? 1 : 0
  providers = { aws = aws.audit }

  source  = "schubergphilis/mcaf-s3/aws"
  version = "~> 0.14.1"

  kms_key_arn = module.kms_key_audit[var.regions.home_region].arn
  name_prefix = var.aws_auditmanager.reports_bucket_prefix
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
