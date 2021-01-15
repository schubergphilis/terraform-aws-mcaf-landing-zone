output "id" {
  value       = module.account.id
  description = "The AWS account ID"
}

output "workspace_id" {
  value       = try(module.workspace.0.workspace_id, "")
  description = "The TFE workspace ID"
}
