data "aws_caller_identity" "delegated_admin" {
  provider = aws.delegated_admin
}

// AWS GuardDuty - Management account configuration
// https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_organizations.html - A delegated GuardDuty administrator account is Regional
resource "aws_guardduty_organization_admin_account" "default" {
  provider = aws.management

  region           = var.region
  admin_account_id = data.aws_caller_identity.delegated_admin.account_id
}

// AWS GuardDuty - Delegated administrator account configuration
resource "aws_guardduty_detector" "delegated_admin" {
  #checkov:skip=CKV_AWS_238: "Ensure that GuardDuty detector is enabled" - False positive, GuardDuty is enabled by default.
  #checkov:skip=CKV2_AWS_3: "Ensure GuardDuty is enabled to specific org/region" - False positive, GuardDuty is enabled by default.
  provider = aws.delegated_admin

  region                       = var.region
  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
  tags                         = var.tags
}

resource "aws_guardduty_organization_configuration" "default" {
  provider = aws.delegated_admin

  region                           = var.region
  auto_enable_organization_members = "ALL"
  detector_id                      = aws_guardduty_detector.delegated_admin.id

  depends_on = [aws_guardduty_organization_admin_account.default]
}

resource "aws_guardduty_organization_configuration_feature" "ebs_malware_protection" {
  provider = aws.delegated_admin

  region      = var.region
  detector_id = aws_guardduty_detector.delegated_admin.id
  name        = "EBS_MALWARE_PROTECTION"
  auto_enable = var.ebs_malware_protection_status == true ? "ALL" : "NONE"
}

resource "aws_guardduty_organization_configuration_feature" "eks_audit_logs" {
  provider = aws.delegated_admin

  region      = var.region
  detector_id = aws_guardduty_detector.delegated_admin.id
  name        = "EKS_AUDIT_LOGS"
  auto_enable = var.eks_audit_logs_status == true ? "ALL" : "NONE"
}

resource "aws_guardduty_organization_configuration_feature" "lambda_network_logs" {
  provider = aws.delegated_admin

  region      = var.region
  detector_id = aws_guardduty_detector.delegated_admin.id
  name        = "LAMBDA_NETWORK_LOGS"
  auto_enable = var.lambda_network_logs_status == true ? "ALL" : "NONE"
}

resource "aws_guardduty_organization_configuration_feature" "rds_login_events" {
  provider = aws.delegated_admin

  region      = var.region
  detector_id = aws_guardduty_detector.delegated_admin.id
  name        = "RDS_LOGIN_EVENTS"
  auto_enable = var.rds_login_events_status == true ? "ALL" : "NONE"
}

resource "aws_guardduty_organization_configuration_feature" "s3_data_events" {
  provider = aws.delegated_admin

  region      = var.region
  detector_id = aws_guardduty_detector.delegated_admin.id
  name        = "S3_DATA_EVENTS"
  auto_enable = var.s3_data_events_status == true ? "ALL" : "NONE"
}

resource "aws_guardduty_organization_configuration_feature" "runtime_monitoring" {
  provider = aws.delegated_admin

  region      = var.region
  detector_id = aws_guardduty_detector.delegated_admin.id
  name        = "RUNTIME_MONITORING"
  auto_enable = var.runtime_monitoring_status.enabled == true ? "ALL" : "NONE"

  additional_configuration {
    name        = "ECS_FARGATE_AGENT_MANAGEMENT"
    auto_enable = var.runtime_monitoring_status.ecs_fargate_agent_management_status == true ? "ALL" : "NONE"
  }

  additional_configuration {
    name        = "EC2_AGENT_MANAGEMENT"
    auto_enable = var.runtime_monitoring_status.ec2_agent_management_status == true ? "ALL" : "NONE"
  }

  additional_configuration {
    name        = "EKS_ADDON_MANAGEMENT"
    auto_enable = var.runtime_monitoring_status.eks_addon_management_status == true ? "ALL" : "NONE"
  }
}
