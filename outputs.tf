output "kms_key_arn" {
  description = "ARN of KMS key for SSM encryption"
  value       = module.kms_key.arn
}

output "kms_key_id" {
  description = "ID of KMS key for SSM encryption"
  value       = module.kms_key.id
}
