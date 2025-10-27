variable "ebs_malware_protection_status" {
  type        = bool
  default     = true
  description = "Whether EBS volume malware protection is enabled in GuardDuty."
}

variable "eks_audit_logs_status" {
  type        = bool
  default     = true
  description = "Whether EKS audit logs monitoring is enabled in GuardDuty."
}

variable "finding_publishing_frequency" {
  type        = string
  default     = "FIFTEEN_MINUTES"
  description = "Frequency at which GuardDuty findings are published."
}

variable "lambda_network_logs_status" {
  type        = bool
  default     = true
  description = "Whether Lambda network logs monitoring is enabled in GuardDuty."
}

variable "rds_login_events_status" {
  type        = bool
  default     = true
  description = "Whether RDS login events monitoring is enabled in GuardDuty."
}

variable "region" {
  type        = string
  default     = null
  description = "The AWS region where the resources will be created. If omitted, the default provider region is used."
}

variable "runtime_monitoring_status" {
  type = object({
    enabled                             = optional(bool, true)
    eks_addon_management_status         = optional(bool, true)
    ecs_fargate_agent_management_status = optional(bool, true)
    ec2_agent_management_status         = optional(bool, true)
  })
  default     = {}
  description = "Runtime monitoring configuration for GuardDuty."
}

variable "s3_data_events_status" {
  type        = bool
  default     = true
  description = "Whether S3 data event monitoring is enabled in GuardDuty."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Map of tags"
}
