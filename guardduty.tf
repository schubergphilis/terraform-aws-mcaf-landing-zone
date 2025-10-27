module "guardduty" {
  for_each = var.aws_guardduty.enabled == true ? local.all_organisation_regions : []

  providers = {
    aws.management      = aws
    aws.delegated_admin = aws.audit
  }

  source = "./modules/guardduty"

  region = each.value

  ebs_malware_protection_status = var.aws_guardduty.ebs_malware_protection_status
  eks_audit_logs_status         = var.aws_guardduty.eks_audit_logs_status
  finding_publishing_frequency  = var.aws_guardduty.finding_publishing_frequency
  lambda_network_logs_status    = var.aws_guardduty.lambda_network_logs_status
  rds_login_events_status       = var.aws_guardduty.rds_login_events_status
  s3_data_events_status         = var.aws_guardduty.s3_data_events_status
  tags                          = var.tags

  runtime_monitoring_status = {
    enabled                             = var.aws_guardduty.runtime_monitoring_status.enabled
    eks_addon_management_status         = var.aws_guardduty.runtime_monitoring_status.eks_addon_management_status
    ecs_fargate_agent_management_status = var.aws_guardduty.runtime_monitoring_status.ecs_fargate_agent_management_status
    ec2_agent_management_status         = var.aws_guardduty.runtime_monitoring_status.ec2_agent_management_status
  }
}
