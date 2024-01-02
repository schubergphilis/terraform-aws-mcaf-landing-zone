resource "aws_auditmanager_account_registration" "default" {
  count = var.aws_auditmanager_by_default == true ? 1 : 0

  delegated_admin_account = data.aws_caller_identity.audit.account_id
  deregister_on_destroy   = true
  kms_key                 = module.kms_key_audit.arn
}
