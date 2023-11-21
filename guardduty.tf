// AWS GuardDuty - Management account configuration
resource "aws_guardduty_organization_admin_account" "audit" {
  count = var.aws_guardduty.enabled == true ? 1 : 0

  admin_account_id = var.control_tower_account_ids.audit
}

// AWS GuardDuty - Audit account configuration
resource "aws_guardduty_organization_configuration" "default" {
  count    = var.aws_guardduty.enabled == true ? 1 : 0
  provider = aws.audit

  auto_enable = var.aws_guardduty.enabled
  detector_id = aws_guardduty_detector.audit.id

  depends_on = [aws_guardduty_organization_admin_account.audit]
}

resource "aws_guardduty_detector" "audit" {
  provider = aws.audit

  enable                       = var.aws_guardduty.enabled
  finding_publishing_frequency = var.aws_guardduty.finding_publishing_frequency
  tags                         = var.tags
}

resource "aws_guardduty_detector_feature" "ebs_malware_protection" {
  detector_id = aws_guardduty_detector.audit.id
  name        = "EBS_MALWARE_PROTECTION"
  status      = var.aws_guardduty.ebs_malware_protection_status
}

resource "aws_guardduty_detector_feature" "eks_audit_logs" {
  detector_id = aws_guardduty_detector.audit.id
  name        = "EKS_AUDIT_LOGS"
  status      = var.aws_guardduty.eks_audit_logs_status
}

resource "aws_guardduty_detector_feature" "eks_runtime_monitoring" {
  detector_id = aws_guardduty_detector.audit.id
  name        = "EKS_RUNTIME_MONITORING"
  status      = var.aws_guardduty.eks_runtime_monitoring_status

  additional_configuration {
    name   = "EKS_ADDON_MANAGEMENT"
    status = var.aws_guardduty.eks_addon_management_status
  }
}

resource "aws_guardduty_detector_feature" "lambda_network_logs" {
  detector_id = aws_guardduty_detector.audit.id
  name        = "LAMBDA_NETWORK_LOGS"
  status      = var.aws_guardduty.lambda_network_logs_status
}

resource "aws_guardduty_detector_feature" "rds_login_events" {
  detector_id = aws_guardduty_detector.audit.id
  name        = "RDS_LOGIN_EVENTS"
  status      = var.aws_guardduty.rds_login_events_status
}

resource "aws_guardduty_detector_feature" "s3_data_events" {
  detector_id = aws_guardduty_detector.audit.id
  name        = "S3_DATA_EVENTS"
  status      = var.aws_guardduty.s3_data_events_status
}
