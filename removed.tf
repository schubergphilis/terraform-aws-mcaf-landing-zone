# Landing Zone 4.0: The custom AWS Config S3 bucket is no longer managed by this
# module. The new Control Tower config logs bucket is used instead. This removed block
# ensures Terraform drops the old bucket from state without destroying it.
removed {
  from = module.aws_config_s3

  lifecycle {
    destroy = false
  }
}

# AWS Audit Manager is no longer supported as the service is closed to new customers
# as of April 30, 2026. These removed blocks ensure Terraform drops the resources
# from state. Users should deregister and clean up Audit Manager resources manually.
removed {
  from = aws_auditmanager_account_registration.default

  lifecycle {
    destroy = false
  }
}

removed {
  from = module.audit_manager_reports

  lifecycle {
    destroy = false
  }
}

# Security Hub membership is handled by the "mcaf-lz" Security Hub Configuration Policy.
removed {
  from = aws_securityhub_member.management

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_securityhub_member.logging

  lifecycle {
    destroy = false
  }
}
