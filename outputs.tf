output "kms_key_arn" {
  description = "ARN of KMS key for master account"
  value       = module.kms_key.arn
}

output "kms_key_id" {
  description = "ID of KMS key for master account"
  value       = module.kms_key.id
}

output "kms_key_audit_arn" {
  description = "ARN of KMS key for audit account"
  value       = module.kms_key_audit.arn
}

output "kms_key_audit_id" {
  description = "ID of KMS key for audit account"
  value       = module.kms_key_audit.id
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
  value       = var.monitor_iam_activity ? aws_sns_topic.iam_activity[0].arn : ""
}
