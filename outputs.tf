output "kms_key_arn" {
  description = "ARN of KMS key for SSM encryption"
  value       = module.kms_key.arn
}

output "kms_key_id" {
  description = "ID of KMS key for SSM encryption"
  value       = module.kms_key.id
}

output "kms_key_logging_arn" {
  description = "ARN of KMS key for logging account"
  value       = module.kms_key_logging.arn
}

output "kms_key_logging_id" {
  description = "ID of KMS key for logging account"
  value       = module.kms_key_logging.id
}

output "monitor_iam_activity_sns_topic_arn" {
  description = "ARN of the SNS Topic in the Audit account for IAM activity monitoring notifications"
  value       = aws_sns_topic.iam_activity.arn
}
