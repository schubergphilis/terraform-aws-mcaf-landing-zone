resource "aws_cloudwatch_log_metric_filter" "iam_activity_master" {
  for_each = var.monitor_iam_activity ? merge(local.iam_activity, local.cloudtrail_activity_cis_aws_foundations) : {}

  name           = "LandingZone-IAMActivity-${each.key}"
  pattern        = each.value
  log_group_name = data.aws_cloudwatch_log_group.cloudtrail_master[0].name

  metric_transformation {
    name      = "LandingZone-IAMActivity-${each.key}"
    namespace = "LandingZone-IAMActivity"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "iam_activity_master" {
  for_each = aws_cloudwatch_log_metric_filter.iam_activity_master

  alarm_name                = each.value.name
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = each.value.name
  namespace                 = each.value.metric_transformation[0].namespace
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitors IAM activity for ${each.key}"
  alarm_actions             = [aws_sns_topic.iam_activity[0].arn]
  insufficient_data_actions = []
  tags                      = var.tags
}

resource "aws_account_alternate_contact" "management_billing" {
  count = var.account_contacts.contact_billing == null ? 0 : 1

  alternate_contact_type = "BILLING"
  email_address          = var.account_contacts.contact_billing.email_address
  name                   = var.account_contacts.contact_billing.name
  phone_number           = var.account_contacts.contact_billing.phone_number
  title                  = var.account_contacts.contact_billing.title
}

resource "aws_account_alternate_contact" "management_operations" {
  count = var.account_contacts.contact_operations == null ? 0 : 1

  alternate_contact_type = "OPERATIONS"
  email_address          = var.account_contacts.contact_operations.email_address
  name                   = var.account_contacts.contact_operations.name
  phone_number           = var.account_contacts.contact_operations.phone_number
  title                  = var.account_contacts.contact_operations.title
}

resource "aws_account_alternate_contact" "management_security" {
  count = var.account_contacts.contact_security == null ? 0 : 1

  alternate_contact_type = "SECURITY"
  email_address          = var.account_contacts.contact_security.email_address
  name                   = var.account_contacts.contact_security.name
  phone_number           = var.account_contacts.contact_security.phone_number
  title                  = var.account_contacts.contact_security.title
}


resource "aws_account_alternate_contact" "logging_billing" {
  count    = var.account_contacts.contact_billing == null ? 0 : 1
  provider = aws.logging

  alternate_contact_type = "BILLING"
  email_address          = var.account_contacts.contact_billing.email_address
  name                   = var.account_contacts.contact_billing.name
  phone_number           = var.account_contacts.contact_billing.phone_number
  title                  = var.account_contacts.contact_billing.title
}

resource "aws_account_alternate_contact" "logging_operations" {
  count    = var.account_contacts.contact_operations == null ? 0 : 1
  provider = aws.logging

  alternate_contact_type = "OPERATIONS"
  email_address          = var.account_contacts.contact_operations.email_address
  name                   = var.account_contacts.contact_operations.name
  phone_number           = var.account_contacts.contact_operations.phone_number
  title                  = var.account_contacts.contact_operations.title
}

resource "aws_account_alternate_contact" "logging_security" {
  count    = var.account_contacts.contact_security == null ? 0 : 1
  provider = aws.logging

  alternate_contact_type = "SECURITY"
  email_address          = var.account_contacts.contact_security.email_address
  name                   = var.account_contacts.contact_security.name
  phone_number           = var.account_contacts.contact_security.phone_number
  title                  = var.account_contacts.contact_security.title
}


resource "aws_account_alternate_contact" "audit_billing" {
  count    = var.account_contacts.contact_billing == null ? 0 : 1
  provider = aws.audit

  alternate_contact_type = "BILLING"
  email_address          = var.account_contacts.contact_billing.email_address
  name                   = var.account_contacts.contact_billing.name
  phone_number           = var.account_contacts.contact_billing.phone_number
  title                  = var.account_contacts.contact_billing.title
}

resource "aws_account_alternate_contact" "audit_operations" {
  count    = var.account_contacts.contact_operations == null ? 0 : 1
  provider = aws.audit

  alternate_contact_type = "OPERATIONS"
  email_address          = var.account_contacts.contact_operations.email_address
  name                   = var.account_contacts.contact_operations.name
  phone_number           = var.account_contacts.contact_operations.phone_number
  title                  = var.account_contacts.contact_operations.title
}

resource "aws_account_alternate_contact" "audit_security" {
  count    = var.account_contacts.contact_security == null ? 0 : 1
  provider = aws.audit

  alternate_contact_type = "SECURITY"
  email_address          = var.account_contacts.contact_security.email_address
  name                   = var.account_contacts.contact_security.name
  phone_number           = var.account_contacts.contact_security.phone_number
  title                  = var.account_contacts.contact_security.title
}
