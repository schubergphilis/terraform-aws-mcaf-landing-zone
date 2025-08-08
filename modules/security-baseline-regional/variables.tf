variable "region" {
  type = string
}

variable "aws_ebs_encryption_by_default" {
  type = bool
}

variable "aws_ebs_snapshot_block_public_access_state" {
  type = string
}

variable "aws_ssm_documents_public_sharing_permission" {
  type = string
}
