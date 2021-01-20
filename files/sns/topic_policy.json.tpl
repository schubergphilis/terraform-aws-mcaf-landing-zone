{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "__default_statement_ID",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "SNS:Subscribe",
        "SNS:SetTopicAttributes",
        "SNS:RemovePermission",
        "SNS:Receive",
        "SNS:Publish",
        "SNS:ListSubscriptionsByTopic",
        "SNS:GetTopicAttributes",
        "SNS:DeleteTopic",
        "SNS:AddPermission"
      ],
      "Resource": "${sns_topic}",
      "Condition": {
        "StringEquals": {
          "AWS:SourceOwner": "${account_id}"
        }
      }
    },
    {
      "Sid": "__events",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sns:Publish",
      "Resource": "${sns_topic}"
    }
  ]
}
