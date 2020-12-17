variable "account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "member_accounts" {
  type        = map(string)
  default     = {}
  description = "A map of accounts that should be added as SecurityHub Member Accounts (format: account_id = email)"
}

variable "product_arns" {
  type        = list(string)
  default     = []
  description = "A list of the ARNs of the products you want to import into Security Hub"
}

variable "region" {
  type        = string
  default     = "eu-west-1"
  description = "The name of the AWS region where SecurityHub will be enabled"
}

variable "sns_endpoint" {
  type        = string
  description = "Endpoint for SNS topic subscription"
}

variable "sns_endpoint_protocol" {
  type        = string
  description = "Endpoint protocol for SNS topic subscription"
}

variable "sns_security_topic_subscription" {
  type        = bool
  default     = false
  description = "Enable SNS aggregated security topic subscription"
}
