# Landing Zone 4.0: The custom AWS Config S3 bucket is no longer managed by this
# module. The new Control Tower config logs bucket is used instead. This removed block
# ensures Terraform drops the old bucket from state without destroying it.
removed {
  from = module.aws_config_s3

  lifecycle {
    destroy = false
  }
}
