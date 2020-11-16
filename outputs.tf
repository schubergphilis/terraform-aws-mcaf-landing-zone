output "kms_key_arn" {
  description = "ARN of KMS key for SSM encryption"
  value       = module.kms_key.arn
}

output "kms_key_id" {
  description = "ID of KMS key for SSM encryption"
  value       = module.kms_key.id
}

output "monitor_iam_access_sns_topic_arn" {
  description = "ARN of the SNS Topic in the Audit account for IAM access monitoring notifications"
  value       = aws_sns_topic.monitor_iam_access.arn
}
