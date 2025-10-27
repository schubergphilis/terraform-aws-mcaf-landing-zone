variable "enable_scan_ec2" {
  type        = bool
  default     = true
  description = "Whether AWS Inspector scans EC2 instances."
}

variable "enable_scan_ecr" {
  type        = bool
  default     = true
  description = "Whether AWS Inspector scans ECR repositories."
}

variable "enable_scan_lambda" {
  type        = bool
  default     = true
  description = "Whether AWS Inspector scans Lambda functions."
}

variable "enable_scan_lambda_code" {
  type        = bool
  default     = true
  description = "Whether AWS Inspector scans Lambda function code."

  validation {
    condition     = !(var.enable_scan_lambda_code && !var.enable_scan_lambda)
    error_message = "If 'enable_scan_lambda_code' is true, 'enable_scan_lambda' must also be true."
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
