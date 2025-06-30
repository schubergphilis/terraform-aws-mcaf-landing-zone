output "aws_config_s3_bucket_arn" {
  description = "ARN of the AWS Config S3 bucket in the logging account"
  value       = module.aws_config_s3.arn
}

output "aws_config_s3_bucket_name" {
  description = "Name of the AWS Config S3 bucket in the logging account"
  value       = module.aws_config_s3.name
}

output "aws_config_iam_service_linked_role_arn" {
  description = "IAM Service Linked Role ARN for AWS Config in the management account"
  value       = aws_iam_service_linked_role.config.arn
}

output "kms_key_arn" {
  description = "ARN of KMS key for the management account"
  value       = module.kms_key.arn
}

output "kms_key_id" {
  description = "ID of KMS key for the management account"
  value       = module.kms_key.id
}

output "kms_key_audit_arn" {
  description = "ARN of KMS key for the audit account"
  value       = module.kms_key_audit.arn
}

output "kms_key_audit_id" {
  description = "ID of KMS key for the audit account"
  value       = module.kms_key_audit.id
}

output "kms_key_logging_arn" {
  description = "ARN of KMS key for the logging account"
  value       = module.kms_key_logging.arn
}

output "kms_key_logging_id" {
  description = "ID of KMS key for the logging account"
  value       = module.kms_key_logging.id
}

output "monitor_iam_activity_sns_topic_arn" {
  description = "ARN of the SNS Topic in the audit account for IAM activity monitoring notifications"
  value       = var.monitor_iam_activity ? aws_sns_topic.iam_activity[0].arn : ""
}
