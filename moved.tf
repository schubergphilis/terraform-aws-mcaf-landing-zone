# Landing Zone 4.0 support for changes CloudTrail log group names
moved {
  from = aws_cloudwatch_log_metric_filter.iam_activity_master["AwsConfigConfigChange"]
  to   = aws_cloudwatch_log_metric_filter.iam_activity_master["aws-controltower/CloudTrailLogs-AwsConfigConfigChange"]
}

moved {
  from = aws_cloudwatch_log_metric_filter.iam_activity_master["AwsConfigConfigChange"]
  to   = aws_cloudwatch_log_metric_filter.iam_activity_master["aws-controltower/CloudTrailLogs-AwsConfigConfigChange"]
}

moved {
  from = aws_cloudwatch_log_metric_filter.iam_activity_master["CloudTrailConfigChange"]
  to   = aws_cloudwatch_log_metric_filter.iam_activity_master["aws-controltower/CloudTrailLogs-CloudTrailConfigChange"]
}

moved {
  from = aws_cloudwatch_log_metric_filter.iam_activity_master["IamPolicyChanges"]
  to   = aws_cloudwatch_log_metric_filter.iam_activity_master["aws-controltower/CloudTrailLogs-IamPolicyChanges"]
}

moved {
  from = aws_cloudwatch_log_metric_filter.iam_activity_master["KmsKeyDisableOrDeletion"]
  to   = aws_cloudwatch_log_metric_filter.iam_activity_master["aws-controltower/CloudTrailLogs-KmsKeyDisableOrDeletion"]
}

moved {
  from = aws_cloudwatch_log_metric_filter.iam_activity_master["ManagementConsoleAuthFailure"]
  to   = aws_cloudwatch_log_metric_filter.iam_activity_master["aws-controltower/CloudTrailLogs-ManagementConsoleAuthFailure"]
}

moved {
  from = aws_cloudwatch_log_metric_filter.iam_activity_master["NaclChange"]
  to   = aws_cloudwatch_log_metric_filter.iam_activity_master["aws-controltower/CloudTrailLogs-NaclChange"]
}

moved {
  from = aws_cloudwatch_log_metric_filter.iam_activity_master["NetworkGatewayChange"]
  to   = aws_cloudwatch_log_metric_filter.iam_activity_master["aws-controltower/CloudTrailLogs-NetworkGatewayChange"]
}

moved {
  from = aws_cloudwatch_log_metric_filter.iam_activity_master["RootActivity"]
  to   = aws_cloudwatch_log_metric_filter.iam_activity_master["aws-controltower/CloudTrailLogs-RootActivity"]
}

moved {
  from = aws_cloudwatch_log_metric_filter.iam_activity_master["RouteTableChange"]
  to   = aws_cloudwatch_log_metric_filter.iam_activity_master["aws-controltower/CloudTrailLogs-RouteTableChange"]
}

moved {
  from = aws_cloudwatch_log_metric_filter.iam_activity_master["S3BucketPolicyChange"]
  to   = aws_cloudwatch_log_metric_filter.iam_activity_master["aws-controltower/CloudTrailLogs-S3BucketPolicyChange"]
}

moved {
  from = aws_cloudwatch_log_metric_filter.iam_activity_master["SecurityGroupChange"]
  to   = aws_cloudwatch_log_metric_filter.iam_activity_master["aws-controltower/CloudTrailLogs-SecurityGroupChange"]
}

moved {
  from = aws_cloudwatch_log_metric_filter.iam_activity_master["SSO"]
  to   = aws_cloudwatch_log_metric_filter.iam_activity_master["aws-controltower/CloudTrailLogs-SSO"]
}

moved {
  from = aws_cloudwatch_log_metric_filter.iam_activity_master["UnauthorizedApiCalls"]
  to   = aws_cloudwatch_log_metric_filter.iam_activity_master["aws-controltower/CloudTrailLogs-UnauthorizedApiCalls"]
}

moved {
  from = aws_cloudwatch_log_metric_filter.iam_activity_master["VpcChange"]
  to   = aws_cloudwatch_log_metric_filter.iam_activity_master["aws-controltower/CloudTrailLogs-VpcChange"]
}

moved {
  from = aws_cloudwatch_metric_alarm.iam_activity_master["AwsConfigConfigChange"]
  to   = aws_cloudwatch_metric_alarm.iam_activity_master["aws-controltower/CloudTrailLogs-AwsConfigConfigChange"]
}

moved {
  from = aws_cloudwatch_metric_alarm.iam_activity_master["AwsConfigConfigChange"]
  to   = aws_cloudwatch_metric_alarm.iam_activity_master["aws-controltower/CloudTrailLogs-AwsConfigConfigChange"]
}

moved {
  from = aws_cloudwatch_metric_alarm.iam_activity_master["CloudTrailConfigChange"]
  to   = aws_cloudwatch_metric_alarm.iam_activity_master["aws-controltower/CloudTrailLogs-CloudTrailConfigChange"]
}

moved {
  from = aws_cloudwatch_metric_alarm.iam_activity_master["IamPolicyChanges"]
  to   = aws_cloudwatch_metric_alarm.iam_activity_master["aws-controltower/CloudTrailLogs-IamPolicyChanges"]
}

moved {
  from = aws_cloudwatch_metric_alarm.iam_activity_master["KmsKeyDisableOrDeletion"]
  to   = aws_cloudwatch_metric_alarm.iam_activity_master["aws-controltower/CloudTrailLogs-KmsKeyDisableOrDeletion"]
}

moved {
  from = aws_cloudwatch_metric_alarm.iam_activity_master["ManagementConsoleAuthFailure"]
  to   = aws_cloudwatch_metric_alarm.iam_activity_master["aws-controltower/CloudTrailLogs-ManagementConsoleAuthFailure"]
}

moved {
  from = aws_cloudwatch_metric_alarm.iam_activity_master["NaclChange"]
  to   = aws_cloudwatch_metric_alarm.iam_activity_master["aws-controltower/CloudTrailLogs-NaclChange"]
}

moved {
  from = aws_cloudwatch_metric_alarm.iam_activity_master["NetworkGatewayChange"]
  to   = aws_cloudwatch_metric_alarm.iam_activity_master["aws-controltower/CloudTrailLogs-NetworkGatewayChange"]
}

moved {
  from = aws_cloudwatch_metric_alarm.iam_activity_master["RootActivity"]
  to   = aws_cloudwatch_metric_alarm.iam_activity_master["aws-controltower/CloudTrailLogs-RootActivity"]
}

moved {
  from = aws_cloudwatch_metric_alarm.iam_activity_master["RouteTableChange"]
  to   = aws_cloudwatch_metric_alarm.iam_activity_master["aws-controltower/CloudTrailLogs-RouteTableChange"]
}

moved {
  from = aws_cloudwatch_metric_alarm.iam_activity_master["S3BucketPolicyChange"]
  to   = aws_cloudwatch_metric_alarm.iam_activity_master["aws-controltower/CloudTrailLogs-S3BucketPolicyChange"]
}

moved {
  from = aws_cloudwatch_metric_alarm.iam_activity_master["SecurityGroupChange"]
  to   = aws_cloudwatch_metric_alarm.iam_activity_master["aws-controltower/CloudTrailLogs-SecurityGroupChange"]
}

moved {
  from = aws_cloudwatch_metric_alarm.iam_activity_master["SSO"]
  to   = aws_cloudwatch_metric_alarm.iam_activity_master["aws-controltower/CloudTrailLogs-SSO"]
}

moved {
  from = aws_cloudwatch_metric_alarm.iam_activity_master["UnauthorizedApiCalls"]
  to   = aws_cloudwatch_metric_alarm.iam_activity_master["aws-controltower/CloudTrailLogs-UnauthorizedApiCalls"]
}

moved {
  from = aws_cloudwatch_metric_alarm.iam_activity_master["VpcChange"]
  to   = aws_cloudwatch_metric_alarm.iam_activity_master["aws-controltower/CloudTrailLogs-VpcChange"]
}
