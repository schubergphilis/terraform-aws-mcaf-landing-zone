resource "aws_ebs_encryption_by_default" "default" {
  region = var.region

  enabled = var.aws_ebs_encryption_by_default
}
