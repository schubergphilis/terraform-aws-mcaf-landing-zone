output "id" {
  value       = module.account.id
  description = "The AWS account ID"
}

output "workspace_id" {
  value       = module.workspace.workspace_id
  description = "The Terraform workspace ID"
}
