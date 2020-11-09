variable "aws_allowed_regions" {
  type        = list(string)
  default     = null
  description = "List of AWS regions allowed to be used"
}

variable "aws_config" {
  type = object({
    aggregator_account_id = string
    aggregator_regions    = list(string)
    rule_identifiers      = list(string)
  })
  default     = null
  description = "AWS Config settings"
}

variable "aws_okta_group_ids" {
  type        = list
  default     = []
  description = "List of Okta group IDs that should be assigned the AWS SSO Okta app"
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
  })
  default     = null
  description = "Datadog integration options for the core accounts"
}

variable "tags" {
  type        = map
  description = "Map of tags"
}
