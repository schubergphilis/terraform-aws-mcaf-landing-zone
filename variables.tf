variable "additional_auditing_trail" {
  type = object({
    name   = string
    bucket = string
  })
  default     = null
  description = "CloudTrail configuration for additional auditing trail"
}

variable "aws_config" {
  type = object({
    aggregator_account_ids = list(string)
    aggregator_regions     = list(string)
  })
  default     = null
  description = "AWS Config settings"
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

variable "aws_guardduty" {
  type        = bool
  default     = true
  description = "Whether AWS GuardDuty should be enabled"
}

variable "aws_okta_group_ids" {
  type        = list(string)
  default     = []
  description = "List of Okta group IDs that should be assigned the AWS SSO Okta app"
}

variable "aws_region_restrictions" {
  type = object({
    allowed    = list(string)
    exceptions = list(string)
  })
  default     = null
  description = "List of allowed AWS regions and principals that are exempt from the restriction"
}

variable "aws_require_imdsv2" {
  type        = bool
  default     = true
  description = "Enable SCP which requires EC2 instances to use V2 of the Instance Metadata Service"
}

variable "aws_sso_acs_url" {
  type        = string
  description = "AWS SSO ACS URL for the Okta App"
}

variable "aws_sso_entity_id" {
  type        = string
  description = "AWS SSO Entity ID for the Okta App"
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

variable "monitor_iam_access" {
  type = list(object({
    account = string
    name    = string
    type    = string
  }))
  default     = null
  description = "List of IAM Identities that should have their access monitored"

  validation {
    condition = length(setsubtract(toset([
      for identity in coalesce(var.monitor_iam_access, []) : identity.account
    ]), ["audit", "logging", "master"])) == 0
    error_message = "Invalid account. The allowed values are \"audit\", \"logging\" or \"master\"."
  }
}

variable "sns_endpoint" {
  type        = string
  description = "Endpoint for SNS topic subscription"
}

variable "sns_endpoint_protocol" {
  type        = string
  description = "Endpoint protocol for SNS topic subscription"
}

variable "sns_security_topic_subscription" {
  type        = bool
  description = "Enable SNS aggregated security topic subscription"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags"
}
