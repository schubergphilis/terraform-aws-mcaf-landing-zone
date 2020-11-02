variable "aws_config_rules" {
  type        = list
  default     = []
  description = "List of managed AWS Config Rule identifiers that should be deployed across the organization"
}

variable "aws_okta_groups" {
  type        = map
  default     = {}
  description = "Map of Okta Groups that should have access to the AWS organization (format: name => description)"
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

variable "tags" {
  type        = map
  description = "Map of tags"
}
