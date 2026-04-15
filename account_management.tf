locals {
  iam_activity_patterns = merge(
    local.iam_activity,
    local.cloudtrail_activity_cis_aws_foundations
  )

  iam_metric_filters_list = flatten([
    for log_group in data.aws_cloudwatch_log_groups.cloudtrail_master.log_group_names : [
      for pattern_key, pattern_value in local.iam_activity_patterns : {
        key            = "${log_group}-${pattern_key}"
        log_group_name = log_group
        pattern_key    = pattern_key
        pattern_value  = pattern_value
      }
    ]
  ])

  iam_metric_filters = var.monitor_iam_activity ? {
    for item in local.iam_metric_filters_list :
    item.key => {
      log_group_name = item.log_group_name
      pattern_key    = item.pattern_key
      pattern_value  = item.pattern_value
    }
  } : {}
}

resource "aws_cloudwatch_log_metric_filter" "iam_activity_master" {
  for_each = local.iam_metric_filters

  name           = "LandingZone-IAMActivity-${each.value.pattern_key}"
  pattern        = each.value.pattern_value
  log_group_name = each.value.log_group_name

  metric_transformation {
    name      = "LandingZone-IAMActivity-${each.value.pattern_key}"
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

resource "aws_account_alternate_contact" "management" {
  for_each = { for k, v in var.account_contacts : k => v if v != null }

  alternate_contact_type = upper(each.key)
  email_address          = each.value.email_address
  name                   = each.value.name
  phone_number           = each.value.phone_number
  title                  = each.value.title
}

resource "aws_account_alternate_contact" "audit" {
  for_each = { for k, v in var.account_contacts : k => v if v != null }

  provider = aws.audit

  alternate_contact_type = upper(each.key)
  email_address          = each.value.email_address
  name                   = each.value.name
  phone_number           = each.value.phone_number
  title                  = each.value.title
}

resource "aws_account_alternate_contact" "logging" {
  for_each = { for k, v in var.account_contacts : k => v if v != null }

  provider = aws.logging

  alternate_contact_type = upper(each.key)
  email_address          = each.value.email_address
  name                   = each.value.name
  phone_number           = each.value.phone_number
  title                  = each.value.title
}
