variable "region" {
  type = string
}

variable "aws_ebs_encryption_by_default" {
  type = bool
}

variable "aws_ebs_snapshot_block_public_access_config" {
  type = object({
    enabled = optional(bool, true)
    state   = optional(string, "block-new-sharing")
  })
}

variable "aws_ssm_documents_public_sharing_permission" {
  type = string
}
