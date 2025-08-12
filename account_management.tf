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
