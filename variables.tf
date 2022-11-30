variable "additional_auditing_trail" {
  type = object({
    name   = string
    bucket = string
  })
  default     = null
  description = "CloudTrail configuration for additional auditing trail"
}

variable "aws_account_password_policy" {
  type = object({
    allow_users_to_change        = bool
    max_age                      = number
    minimum_length               = number
    require_lowercase_characters = bool
    require_numbers              = bool
    require_symbols              = bool
    require_uppercase_characters = bool
    reuse_prevention_history     = number
  })
  default = {
    allow_users_to_change        = true
    max_age                      = 90
    minimum_length               = 14
    require_lowercase_characters = true
    require_numbers              = true
    require_symbols              = true
    require_uppercase_characters = true
    reuse_prevention_history     = 24
  }
  description = "AWS account password policy parameters for the audit, logging and master account"
}

variable "aws_config" {
  type = object({
    aggregator_account_ids = list(string)
    aggregator_regions     = list(string)
  })
  default     = null
  description = "AWS Config settings"
}

variable "aws_config_sns_subscription" {
  type = map(object({
    endpoint = string
    protocol = string
  }))
  default     = {}
  description = "Subscription options for the aws-controltower-AggregateSecurityNotifications (AWS Config) SNS topic"
}

variable "aws_deny_disabling_security_hub" {
  type        = bool
  default     = true
  description = "Enable SCP that denies accounts the ability to disable Security Hub"
}

variable "aws_deny_leaving_org" {
  type        = bool
  default     = true
  description = "Enable SCP that denies accounts the ability to leave the AWS organisation"
}

variable "aws_deny_root_user_ous" {
  type        = list(string)
  default     = []
  description = "List of AWS Organisation OUs to apply the \"DenyRootUser\" SCP to"
}

variable "aws_ebs_encryption_by_default" {
  type        = bool
  default     = true
  description = "Set to true to enable AWS Elastic Block Store encryption by default"
}

variable "aws_guardduty" {
  type        = bool
  default     = true
  description = "Whether AWS GuardDuty should be enabled"
}

variable "aws_guardduty_s3_protection" {
  type        = bool
  default     = true
  description = "Whether AWS GuardDuty S3 protection should be enabled"
}

variable "aws_region_restrictions" {
  type = object({
    allowed    = list(string)
    exceptions = list(string)
  })
  default     = null
  description = "List of allowed AWS regions and principals that are exempt from the restriction"
}

variable "aws_required_tags" {
  type = map(list(object({
    name   = string
    values = optional(list(string))
  })))
  default     = null
  description = "AWS Required tags settings"
}

variable "aws_require_imdsv2" {
  type        = bool
  default     = true
  description = "Enable SCP which requires EC2 instances to use V2 of the Instance Metadata Service"
}

variable "aws_security_hub_product_arns" {
  type        = list(string)
  default     = []
  description = "A list of the ARNs of the products you want to import into Security Hub"
}

variable "aws_security_hub_sns_subscription" {
  type = map(object({
    endpoint = string
    protocol = string
  }))
  default     = {}
  description = "Subscription options for the LandingZone-SecurityHubFindings SNS topic"
}

variable "security_hub_standards_arns" {
  type        = list(string)
  default     = null
  description = "A list of the ARNs of the standards you want to enable in Security Hub"
}

variable "security_hub_create_cis_metric_filters" {
  type        = bool
  default     = true
  description = "Enable the creation of metric filters related to the CIS AWS Foundation Security Hub Standard"
}

variable "aws_sso_permission_sets" {
  type = map(object({
    assignments         = list(map(list(string)))
    inline_policy       = string
    managed_policy_arns = list(string)
    session_duration    = string
  }))
  default     = {}
  description = "Map of AWS SSO Permission Sets with the AWS Accounts and the names of the AWS SSO Groups that should be granted access to each account"
}

variable "control_tower_account_ids" {
  type = object({
    audit   = string
    logging = string
  })
  description = "Control Tower core account IDs"
}

variable "datadog" {
  type = object({
    api_key               = string
    enable_integration    = bool
    install_log_forwarder = bool
    site_url              = string
  })
  default     = null
  description = "Datadog integration options for the core accounts"
}

variable "datadog_excluded_regions" {
  type        = list(string)
  description = "List of regions where metrics collection will be disabled."
  default     = []
}

variable "kms_key_policy" {
  type        = list(string)
  default     = []
  description = "A list of valid KMS key policy JSON documents"
}

variable "kms_key_policy_audit" {
  type        = list(string)
  default     = []
  description = "A list of valid KMS key policy JSON document for use with audit KMS key"
}

variable "kms_key_policy_logging" {
  type        = list(string)
  default     = []
  description = "A list of valid KMS key policy JSON document for use with logging KMS key"
}

variable "monitor_iam_activity" {
  type        = bool
  default     = true
  description = "Whether IAM activity should be monitored"
}

variable "monitor_iam_activity_sns_subscription" {
  type = map(object({
    endpoint = string
    protocol = string
  }))
  default     = {}
  description = "Subscription options for the LandingZone-IAMActivity SNS topic"
}

variable "ses_root_accounts_mail_forward" {
  type = object({
    domain            = string
    from_email        = string
    recipient_mapping = map(any)
  })
  default     = null
  description = "SES config to receive and forward root account emails"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags"
}
