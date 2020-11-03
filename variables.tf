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

variable "datadog_integration" {
  type = object({
    audit = object({
      enabled      = bool
      forward_logs = bool
    })
    logging = object({
      enabled      = bool
      forward_logs = bool
    })
    master = object({
      enabled      = bool
      forward_logs = bool
    })
  })
  default = {
    audit = {
      enabled      = false
      forward_logs = false
    }
    logging = {
      enabled      = false
      forward_logs = false
    }
    master = {
      enabled      = false
      forward_logs = false
    }
  }
  description = "Configuration for Datadog Integration"
}

variable "tags" {
  type        = map
  description = "Map of tags"
}
