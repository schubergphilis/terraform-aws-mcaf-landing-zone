output "kms_key_arn" {
  description = "ARN of KMS key for SSM encryption"
  value       = module.kms_key.arn
}

output "kms_key_id" {
  description = "ID of KMS key for SSM encryption"
  value       = module.kms_key.id
}

output "monitor_iam_access_event_bus_arn" {
  description = "ARN of the Event Bus in the Audit account for IAM access monitoring notifications"
  value       = aws_cloudwatch_event_bus.monitor_iam_access_audit.arn
}
