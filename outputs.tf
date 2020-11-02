output "kms_key_arn" {
  description = "ARN of KMS key for SSM encryption"
  value       = module.kms_key.arn
}
