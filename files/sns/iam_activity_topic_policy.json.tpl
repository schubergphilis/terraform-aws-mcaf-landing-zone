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
          "AWS:SourceAccount": "${audit_account_id}"
        }
      }
    },
    {
      "Sid": "AllowServicesToPublishFromMgmtAccount",
      "Effect": "Allow",
      "Principal": {
        "Service": ${services_allowed_publish}
      },
      "Action": "sns:Publish",
      "Resource": "${sns_topic}",
      "Condition": {
        "StringEquals": {
          "AWS:SourceAccount": "${mgmt_account_id}"
        }
      }
    },
    {
      "Sid": "AllowMgmtMasterToListSubcriptions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${mgmt_account_id}:root"
      },
      "Action": "sns:ListSubscriptionsByTopic",
      "Resource": "${sns_topic}"
    }
    %{ if length(security_hub_roles) > 0 ~}
    ,
    {
      "Sid": "AllowListSubscribersBySecurityHub",
      "Effect": "Allow",
      "Principal": {
        "AWS": [ ${join(", ", security_hub_roles)} ]
      },
      "Action": "sns:ListSubscriptionsByTopic",
      "Resource": "${sns_topic}"
    }
    %{ endif ~}
  ]
}
