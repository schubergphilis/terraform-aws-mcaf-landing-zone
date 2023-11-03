#tfsec:ignore:AWS065
resource "aws_cloudtrail" "additional_auditing_trail" {
  #checkov:skip=CKV_AWS_252: "Ensure CloudTrail defines an SNS Topic"
  #checkov:skip=CKV2_AWS_10: "Ensure CloudTrail trails are integrated with CloudWatch Logs"
  count = var.additional_auditing_trail != null ? 1 : 0

  name                       = var.additional_auditing_trail.name
  enable_log_file_validation = true
  is_multi_region_trail      = true
  is_organization_trail      = true
  s3_bucket_name             = var.additional_auditing_trail.bucket
  kms_key_id                 = var.additional_auditing_trail.kms_key_id
  tags                       = var.tags

  event_selector {
    dynamic "data_resource" {
      for_each = var.additional_auditing_trail.event_selector.data_resource != null ? { create = true } : {}

      content {
        type   = var.additional_auditing_trail.event_selector.data_resource.type
        values = var.additional_auditing_trail.event_selector.data_resource.values
      }

    }

    include_management_events        = var.additional_auditing_trail.event_selector.include_management_events
    exclude_management_event_sources = var.additional_auditing_trail.event_selector.exclude_management_event_sources
    read_write_type                  = var.additional_auditing_trail.event_selector.read_write_type
  }
}
