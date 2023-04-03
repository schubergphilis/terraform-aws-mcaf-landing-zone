#tfsec:ignore:AWS065
resource "aws_cloudtrail" "additional_auditing_trail" {
  #checkov:skip=CKV_AWS_252: "Ensure CloudTrail defines an SNS Topic"
  #checkov:skip=CKV_AWS_35: "Ensure CloudTrail logs are encrypted at rest using KMS CMKs"
  #checkov:skip=CKV2_AWS_10: "Ensure CloudTrail trails are integrated with CloudWatch Logs"
  count = var.additional_auditing_trail != null ? 1 : 0

  name                       = var.additional_auditing_trail.name
  enable_log_file_validation = true
  is_multi_region_trail      = true
  is_organization_trail      = true
  s3_bucket_name             = var.additional_auditing_trail.bucket
  kms_key_id                 = var.additional_auditing_trail.kms_key_id
  tags                       = var.tags
}
