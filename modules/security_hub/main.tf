locals {
  standards_arns = [
    "arn:aws:securityhub:${var.region}::standards/aws-foundational-security-best-practices/v/1.0.0",
    "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0",
    "arn:aws:securityhub:${var.region}::standards/pci-dss/v/3.2.1"
  ]
}

resource "aws_securityhub_account" "default" {}

resource "aws_securityhub_member" "default" {
  for_each   = var.member_accounts
  account_id = each.key
  email      = each.value
  depends_on = [aws_securityhub_account.default]
}

resource "aws_securityhub_product_subscription" "default" {
  for_each    = toset(var.product_arns)
  product_arn = each.value
  depends_on  = [aws_securityhub_account.default]
}

resource "aws_securityhub_standards_subscription" "default" {
  for_each      = toset(local.standards_arns)
  standards_arn = each.value
  depends_on    = [aws_securityhub_account.default]
}

resource "aws_sns_topic_subscription" "datadog_security" {
  for_each   = toset(try(var.sns_subscription, []))
  endpoint   = each.value.endpoint
  protocol   = each.value.protocol
  topic_arn  = "arn:aws:sns:${var.region}:${each.value.account_id}:aws-controltower-AggregateSecurityNotifications"
  depends_on = [aws_securityhub_account.default]
}
