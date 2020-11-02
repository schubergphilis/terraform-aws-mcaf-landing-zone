variable "audit_account_id" {
  type        = string
  description = "Account ID of AWS audit account"
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
