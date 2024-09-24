// AWS GuardDuty - Management account configuration
resource "aws_guardduty_organization_admin_account" "audit" {
  count = var.aws_guardduty.enabled == true ? 1 : 0

  admin_account_id = var.control_tower_account_ids.audit
}

// AWS GuardDuty - Audit account configuration
resource "aws_guardduty_detector" "audit" {
  provider = aws.audit

  enable                       = var.aws_guardduty.enabled
  finding_publishing_frequency = var.aws_guardduty.finding_publishing_frequency
  tags                         = var.tags
}

resource "aws_guardduty_organization_configuration" "default" {
  count    = var.aws_guardduty.enabled == true ? 1 : 0
  provider = aws.audit

  auto_enable_organization_members = var.aws_guardduty.enabled ? "ALL" : "NONE"
  detector_id                      = aws_guardduty_detector.audit.id

  depends_on = [aws_guardduty_organization_admin_account.audit]
}

resource "aws_guardduty_organization_configuration_feature" "ebs_malware_protection" {
  provider = aws.audit

  detector_id = aws_guardduty_detector.audit.id
  name        = "EBS_MALWARE_PROTECTION"
  auto_enable = var.aws_guardduty.ebs_malware_protection_status == true ? "ALL" : "NONE"
}

resource "aws_guardduty_organization_configuration_feature" "eks_audit_logs" {
  provider = aws.audit

  detector_id = aws_guardduty_detector.audit.id
  name        = "EKS_AUDIT_LOGS"
  auto_enable = var.aws_guardduty.eks_audit_logs_status == true ? "ALL" : "NONE"
}

resource "aws_guardduty_organization_configuration_feature" "lambda_network_logs" {
  provider = aws.audit

  detector_id = aws_guardduty_detector.audit.id
  name        = "LAMBDA_NETWORK_LOGS"
  auto_enable = var.aws_guardduty.lambda_network_logs_status == true ? "ALL" : "NONE"
}

resource "aws_guardduty_organization_configuration_feature" "rds_login_events" {
  provider = aws.audit

  detector_id = aws_guardduty_detector.audit.id
  name        = "RDS_LOGIN_EVENTS"
  auto_enable = var.aws_guardduty.rds_login_events_status == true ? "ALL" : "NONE"
}

resource "aws_guardduty_organization_configuration_feature" "s3_data_events" {
  provider = aws.audit

  detector_id = aws_guardduty_detector.audit.id
  name        = "S3_DATA_EVENTS"
  auto_enable = var.aws_guardduty.s3_data_events_status == true ? "ALL" : "NONE"
}

resource "aws_guardduty_organization_configuration_feature" "runtime_monitoring" {
  provider = aws.audit

  detector_id = aws_guardduty_detector.audit.id
  name        = "RUNTIME_MONITORING"
  auto_enable = var.aws_guardduty.runtime_monitoring_status.enabled == true ? "ALL" : "NONE"


  dynamic "additional_configuration" {
    for_each = {
      for name, status in {
        "EC2_AGENT_MANAGEMENT"         = var.aws_guardduty.runtime_monitoring_status.ec2_agent_management_status
        "ECS_FARGATE_AGENT_MANAGEMENT" = var.aws_guardduty.runtime_monitoring_status.ecs_fargate_agent_management_status
        "EKS_ADDON_MANAGEMENT"         = var.aws_guardduty.runtime_monitoring_status.eks_addon_management_status
      } : name => status if status == true
    }

    content {
      name        = additional_configuration.key
      auto_enable = "ALL"
    }
  }
}
