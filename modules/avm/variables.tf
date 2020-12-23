variable "account_name" {
  type        = string
  default     = null
  description = "Name of the AWS Service Catalog provisioned account (overrides computed name from the `name` variable)"
}

variable "aws_config" {
  type = object({
    aggregator_account_ids = list(string)
    aggregator_regions     = list(string)
  })
  default     = null
  description = "AWS Config settings"
}

variable "datadog" {
  type = object({
    api_key               = string
    enable_integration    = bool
    install_log_forwarder = bool
    site_url              = string
  })
  default     = null
  description = "Datadog integration options"
}

variable "defaults" {
  type = object({
    account_iam_prefix     = string
    email_prefix           = string
    github_organization    = string
    sso_email              = string
    terraform_organization = string
    terraform_version      = string
  })
  description = "Default options for this module"
}

variable "environment" {
  type        = string
  default     = null
  description = "Stack environment"
}

variable "email" {
  type        = string
  default     = null
  description = "Email address of the account"
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "The KMS key ID used to encrypt the SSM parameters"
}

variable "name" {
  type        = string
  description = "Stack name"
}

variable "oauth_token_id" {
  type        = string
  description = "The OAuth token ID of the VCS provider"
}

variable "organizational_unit" {
  type        = string
  default     = null
  description = "Organizational Unit to place account in"
}

variable "provisioned_product_name" {
  type        = string
  default     = null
  description = "A custom name for the provisioned product"
}

variable "monitor_iam_access" {
  type = object({
    event_bus_arn = string
    identities = list(object({
      name = string
      type = string
    }))
  })
  default     = null
  description = "Object containing list of IAM Identities that should have their access monitored and the EventBridge Event Bus that should receive captured events"
}

variable "region" {
  type        = string
  default     = "eu-west-1"
  description = "The default region of the account"
}

variable "ssh_key_id" {
  type        = string
  default     = null
  description = "The SSH key ID to assign to the TFE workspace"
}

variable "sso_firstname" {
  type        = string
  default     = "AWS Control Tower"
  description = "The firstname of the Control Tower SSO account"
}

variable "sso_lastname" {
  type        = string
  default     = "Admin"
  description = "The lastname of the Control Tower SSO account"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags"
}

variable "terraform_auto_apply" {
  type        = bool
  default     = false
  description = "Whether to automatically apply changes when a Terraform plan is successful"
}

variable "tfe_vcs_branch" {
  type        = string
  default     = "master"
  description = "Terraform VCS branch to use"
}

variable "terraform_version" {
  type        = string
  default     = null
  description = "Terraform version to use"
}

variable "trigger_prefixes" {
  type        = list(string)
  default     = ["modules"]
  description = "List of repository-root-relative paths which should be tracked for changes"
}

variable "create_password_policy" {
  type        = bool
  description = "Define if the password policy should be created."
  default     = false
}

variable "password_policy" {
  type = object({
    allow_users_to_change        = bool
    max_age                      = int
    minimum_length               = int
    require_lowercase_characters = bool
    require_numbers              = bool
    require_symbols              = bool
    require_uppercase_characters = bool
    reuse_prevention_history     = int
  })
  description = "The password policy parameters to set."
  default = object({
    allow_users_to_change        = true
    max_age                      = 90
    minimum_length               = 14
    require_lowercase_characters = true
    require_numbers              = true
    require_symbols              = true
    require_uppercase_characters = true
    reuse_prevention_history     = 24
  })
}
