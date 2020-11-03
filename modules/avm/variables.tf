variable "datadog_api_key" {
  type        = string
  default     = null
  description = "Datadog API key"
}

variable "datadog_integration" {
  type = object({
    enabled      = bool
    forward_logs = bool
  })
  default = {
    enabled      = false
    forward_logs = false
  }
  description = "Configuration for Datadog Integration"
}

variable "defaults" {
  type = object({
    account_prefix         = string
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

variable "region" {
  type        = string
  default     = "eu-west-1"
  description = "The default region of the account"
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
