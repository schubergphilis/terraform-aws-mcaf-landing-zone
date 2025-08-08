resource "aws_ebs_encryption_by_default" "default" {
  region = var.region

  enabled = var.aws_ebs_encryption_by_default
}

resource "aws_ebs_snapshot_block_public_access" "default" {
  region = var.region

  state = var.aws_ebs_snapshot_block_public_access_state
}

resource "aws_ssm_service_setting" "documents_public_sharing_permission" {
  region = var.region

  setting_id    = "/ssm/documents/console/public-sharing-permission"
  setting_value = var.aws_ssm_documents_public_sharing_permission
}
