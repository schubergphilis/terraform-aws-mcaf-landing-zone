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

output "kms_key_arns_management_account" {
  description = "Map of region => ARN of KMS key for the core management account"
  value       = { for region, module in module.kms_key : region => module.arn }
}

output "kms_key_ids_management_account" {
  description = "Map of region => ID of KMS key for the core management account"
  value       = { for region, module in module.kms_key : region => module.id }
}

output "kms_key_arns_audit_account" {
  description = "Map of region => ARN of KMS key for the core audit account"
  value       = { for region, module in module.kms_key_audit : region => module.arn }
}

output "kms_key_ids_audit_account" {
  description = "Map of region => ID of KMS key for the core audit account"
  value       = { for region, module in module.kms_key_audit : region => module.id }
}

output "kms_key_arns_logging_account" {
  description = "Map of region => ARN of KMS key for the core logging account"
  value       = { for region, module in module.kms_key_logging : region => module.arn }
}

output "kms_key_ids_logging_account" {
  description = "Map of region => ID of KMS key for the core logging account"
  value       = { for region, module in module.kms_key_logging : region => module.id }
}

output "monitor_iam_activity_sns_topic_arn" {
  description = "ARN of the SNS Topic in the audit account for IAM activity monitoring notifications"
  value       = var.monitor_iam_activity ? aws_sns_topic.iam_activity[0].arn : ""
}
