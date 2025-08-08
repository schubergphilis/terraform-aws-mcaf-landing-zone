resource "aws_iam_account_password_policy" "default" {
  count = var.security_baseline_input.aws_account_password_policy != null ? 1 : 0

  allow_users_to_change_password = var.security_baseline_input.aws_account_password_policy.allow_users_to_change
  max_password_age               = var.security_baseline_input.aws_account_password_policy.max_age
  minimum_password_length        = var.security_baseline_input.aws_account_password_policy.minimum_length
  password_reuse_prevention      = var.security_baseline_input.aws_account_password_policy.reuse_prevention_history
  require_lowercase_characters   = var.security_baseline_input.aws_account_password_policy.require_lowercase_characters
  require_numbers                = var.security_baseline_input.aws_account_password_policy.require_numbers
  require_symbols                = var.security_baseline_input.aws_account_password_policy.require_symbols
  require_uppercase_characters   = var.security_baseline_input.aws_account_password_policy.require_uppercase_characters
}

resource "aws_s3_account_public_access_block" "default" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "regional_resources_baseline" {
  for_each = var.security_baseline_input.regions

  source = "./../../modules/security-baseline-regional"

  region                        = each.value
  aws_ebs_encryption_by_default = var.security_baseline_input.aws_ebs_encryption_by_default
}
