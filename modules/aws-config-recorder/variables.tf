variable "delivery_frequency" {
  type        = string
  description = "The frequency with which AWS Config recurringly delivers configuration snapshots"
  default     = "TwentyFour_Hours"
}

variable "iam_service_linked_role_arn" {
  type        = string
  description = "The ARN for the AWS Config IAM Service Linked Role"
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key for AWS Config"
}

variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for AWS Config"
}

variable "s3_key_prefix" {
  type        = string
  description = "The S3 key prefix for AWS Config"
}

variable "sns_topic_arn" {
  type        = string
  description = "The ARN of the SNS topic that AWS Config delivers notifications to."
}
