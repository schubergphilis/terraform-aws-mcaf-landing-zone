variable "aws_config_rules" {
  type        = list
  default     = []
  description = "List of managed AWS Config Rule identifiers that should be deployed across the organization"
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

variable "datadog_api_key" {
  type        = string
  default     = null
  description = "Datadog API key"
}

variable "datadog_install_log_forwarder" {
  type = object({
    audit   = bool
    logging = bool
    master  = bool
  })
  default = {
    audit   = false
    logging = false
    master  = false
  }
  description = "Set to true to install Datadog AWS Log Forwarder for each of the core accounts"
}

variable "datadog_integration" {
  type        = bool
  default     = false
  description = "Whether the Datadog integration should be enabled or not"
}

variable "tags" {
  type        = map
  description = "Map of tags"
}
