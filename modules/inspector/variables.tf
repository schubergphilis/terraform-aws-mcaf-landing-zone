variable "enable_scan" {
  type = object({
    ec2         = optional(bool, true)
    ecr         = optional(bool, true)
    lambda      = optional(bool, true)
    lambda_code = optional(bool, true)
  })
  default     = {}
  description = "Type of resources to scan."

  validation {
    condition     = !(var.enable_scan.lambda_code && !var.enable_scan.lambda)
    error_message = "If enable_scan.lambda_code is true, enable_scan.lambda must also be true."
  }
}

variable "member_account_ids" {
  type        = list(string)
  default     = []
  description = "List of AWS account IDs to include in Inspector scans."
}

variable "resource_create_timeout" {
  type        = string
  default     = "15m"
  description = "Timeout for creating AWS Inspector resources."
}

variable "region" {
  type        = string
  default     = null
  description = "The AWS region where the resources will be created. If omitted, the default provider region is used."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Map of tags"
}
