variable "security_baseline_input" {
  type = object({
    aws_ebs_encryption_by_default = bool
    aws_account_password_policy   = object({
      allow_users_to_change        = bool
      max_age                      = number
      minimum_length               = number
      require_lowercase_characters = bool
      require_numbers              = bool
      require_symbols              = bool
      require_uppercase_characters = bool
      reuse_prevention_history     = number
    })
  })
}
