variable "name" {
  type        = string
  description = "Name of the permission set"
}

variable "assignments" {
  type = list(object({
    account_id   = string
    account_name = string
    sso_groups   = list(string)
  }))
  default     = []
  description = "List of account names and IDs and Identity Center groups to assign to the permission set"
}

variable "create" {
  type        = bool
  default     = true
  description = "Set to false to only manage assignments when the permission set already exists"
}

variable "inline_policy" {
  type        = string
  default     = null
  description = "The IAM inline policy to attach to a permission set"
}

variable "module_depends_on" {
  type        = any
  description = "A list of external resources the module depends_on"
  default     = []
}

variable "managed_policy_arns" {
  type        = list(string)
  default     = []
  description = "List of IAM managed policy ARNs to be attached to the permission set"
}

variable "session_duration" {
  type        = string
  default     = "PT4H"
  description = "The length of time that the application user sessions are valid in the ISO-8601 standard"
}
