{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DenyAllRegionsOutsideAllowedList",
            "Effect": "Deny",
            "NotAction": [
                "a4b:*",
                "access-analyzer:*",
                "acm:*",
                "aws-marketplace-management:*",
                "aws-marketplace:*",
                "aws-portal:*",
                "awsbillingconsole:*",
                "budgets:*",
                "ce:*",
                "chatbot:*",
                "chime:*",
                "cloudfront:*",
                "cloudtrail:Describe*",
                "cloudtrail:Get*",
                "cloudtrail:List*",
                "cloudtrail:LookupEvents",
                "cloudwatch:Describe*",
                "cloudwatch:Get*",
                "cloudwatch:List*",
                "config:*",
                "cur:*",
                "directconnect:*",
                "ec2:DescribeRegions",
                "ec2:DescribeTransitGateways",
                "ec2:DescribeVpnGateways",
                "fms:*",
                "globalaccelerator:*",
                "health:*",
                "iam:*",
                "importexport:*",
                "kms:*",
                "mobileanalytics:*",
                "networkmanager:*",
                "organizations:*",
                "pricing:*",
                "route53-recovery-cluster:*",
                "route53-recovery-control-config:*",
                "route53-recovery-readiness:*",
                "route53:*",
                "route53domains:*",
                "s3:DeleteMultiRegionAccessPoint",
                "s3:DescribeMultiRegionAccessPointOperation",
                "s3:GetAccountPublic*",
                "s3:GetBucketPublicAccessBlock",
                "s3:GetMultiRegionAccessPoint",
                "s3:GetMultiRegionAccessPointPolicy",
                "s3:GetMultiRegionAccessPointPolicyStatus",
                "s3:GetStorageLensConfiguration",
                "s3:GetStorageLensDashboard",
                "s3:ListAllMyBuckets",
                "s3:ListMultiRegionAccessPoints",
                "s3:ListStorageLensConfigurations",
                "s3:PutAccountPublic*",
                "s3:PutAccountPublicAccessBlock",
                "shield:*",
                "sts:*",
                "support:*",
                "sustainability:*",
                "trustedadvisor:*",
                "waf-regional:*",
                "waf:*",
                "wafv2:*",
                "wellarchitected:*"
            ],
            "Resource": "*",
            "Condition": {
                "StringNotEquals": {
                    "aws:RequestedRegion": ${jsonencode(allowed)}
                }
                %{ if length(exceptions) > 0 ~}
                ,"ArnNotLike": {
                    "aws:PrincipalARN": ${jsonencode(exceptions)}
                }
                %{ endif ~}
            }
        }
    ]
}
