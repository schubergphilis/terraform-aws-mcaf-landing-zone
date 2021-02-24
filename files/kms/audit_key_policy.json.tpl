{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
          "AWS": [
            "arn:aws:iam::${audit_account_id}:root",
            "arn:aws:iam::${master_account_id}:root"
          ]
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow_CloudWatch_for_CMK",
      "Effect": "Allow",
      "Principal": {
        "Service":${services}
      },
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Resource": "*"
    }
  ]
}
