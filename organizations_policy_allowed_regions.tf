locals {
  ################################################################################
  # 1) Core service lists
  ################################################################################

  # AWS services that need to be allowed in the us-east-1 ("global") region.
  # These services are typically used for account management, billing, and other global operations.
  # Mirrors roughly: https://docs.aws.amazon.com/controltower/latest/controlreference/primary-region-deny-policy.html
  us_east_1_global_service_actions = [
    "a4b:*",
    "access-analyzer:*",
    "account:*",
    "acm:*",
    "activate:*",
    "artifact:*",
    "aws-marketplace-management:*",
    "aws-marketplace:*",
    "aws-portal:*",
    "billing:*",
    "billingconductor:*",
    "budgets:*",
    "ce:*",
    "chatbot:*",
    "chime:*",
    "cloudfront:*",
    "cloudtrail:Describe*",
    "cloudtrail:Get*",
    "cloudtrail:List*",
    "cloudtrail:LookupEvents",
    "cloudwatch:*",
    "compute-optimizer:*",
    "config:*",
    "consoleapp:*",
    "consolidatedbilling:*",
    "cur:*",
    "datapipeline:GetAccountLimits",
    "devicefarm:*",
    "directconnect:*",
    "ec2:DescribeRegions",
    "ec2:DescribeTransitGateways",
    "ec2:DescribeVpnGateways",
    "ecr-public:*",
    "fms:*",
    "freetier:*",
    "globalaccelerator:*",
    "health:*",
    "iam:*",
    "importexport:*",
    "invoicing:*",
    "iq:*",
    "kms:*",
    "lambda:*", // Needed for Lambda@Edge
    "license-manager:ListReceivedLicenses",
    "lightsail:Get*",
    "logs:*",
    "mobileanalytics:*",
    "networkmanager:*",
    "notifications-contacts:*",
    "notifications:*",
    "organizations:*",
    "payments:*",
    "pricing:*",
    "quicksight:DescribeAccountSubscription",
    "quicksight:DescribeTemplate",
    "resource-explorer-2:*",
    "route53-recovery-cluster:*",
    "route53-recovery-control-config:*",
    "route53-recovery-readiness:*",
    "route53:*",
    "route53domains:*",
    "s3:CreateMultiRegionAccessPoint",
    "s3:DeleteMultiRegionAccessPoint",
    "s3:DescribeMultiRegionAccessPointOperation",
    "s3:GetAccountPublicAccessBlock",
    "s3:GetBucketLocation",
    "s3:GetBucketPolicy",
    "s3:GetBucketPolicyStatus",
    "s3:GetBucketPublicAccessBlock",
    "s3:GetMultiRegionAccessPoint",
    "s3:GetMultiRegionAccessPointPolicy",
    "s3:GetMultiRegionAccessPointPolicyStatus",
    "s3:GetStorageLensConfiguration",
    "s3:GetStorageLensDashboard",
    "s3:ListAllMyBuckets",
    "s3:ListMultiRegionAccessPoints",
    "s3:ListStorageLensConfigurations",
    "s3:PutAccountPublicAccessBlock",
    "s3:PutMultiRegionAccessPointPolicy",
    "savingsplans:*",
    "servicequotas:*",
    "shield:*",
    "sso:*",
    "sts:*",
    "support:*",
    "supportapp:*",
    "supportplans:*",
    "sustainability:*",
    "tag:GetResources",
    "tax:*",
    "trustedadvisor:*",
    "vendor-insights:ListEntitledSecurityProfiles",
    "waf-regional:*",
    "waf:*",
    "wafv2:*",
    "wellarchitected:*",
  ]

  # Required AWS actions in us-east-1 for CDK/CloudFormation to deploy global services.
  us_east_1_cdk_service_actions = var.region.enable_cdk_service_actions ? [
    "cloudformation:*",
    "s3:Abort*",
    "s3:DeleteObject*",
    "s3:GetBucket*",
    "s3:GetEncryptionConfiguration",
    "s3:GetObject*",
    "s3:List*",
    "s3:PutObject*",
    "sns:*",
    "ssm:AddTagsToResource",
    "ssm:DeleteParameter",
    "ssm:DeleteParameters",
    "ssm:DescribeParameters",
    "ssm:GetParameter",
    "ssm:GetParameterHistory",
    "ssm:GetParameters",
    "ssm:GetParametersByPath",
    "ssm:ListTagsForResource",
    "ssm:PutParameter",
    "ssm:RemoveTagsFromResource"
  ] : []

  # AWS Security lake S3 replication actions to allow S3 replication from the us-east-1 bucket to the bucket in the home region.
  # Reference https://docs.aws.amazon.com/security-lake/latest/userguide/add-rollup-region.html#iam-role-replication
  # Additionally 'glue:Get*' and 'lakeformation:List*' actions are added to prevent Security Lake UI from showing permission denied in us-east-1
  us_east_1_security_lake_aggregation_service_actions = var.regions.enable_security_lake_aggregation_service_actions ? [
    "s3:GetReplicationConfiguration",
    "s3:ReplicateObject",
    "s3:ReplicateDelete",
    "s3:ReplicateTags",
    "sqs:ReceiveMessage",
    "sqs:DeleteMessage",
    "sqs:GetQueueAttributes",
    "glue:Get*",
    "lakeformation:List*"
  ] : []

  # AWS services that are inherently multi-region, meaning they can operate across multiple regions.
  multi_region_service_actions = [
    "supportplans:*"
  ]

  ################################################################################
  # 2) Build the regions & exemption sets used in the SCP Statements
  ################################################################################

  # List of regions that have extra whitelisted actions
  regions_with_whitelist_exceptions = keys(var.regions.additional_allowed_service_actions_per_region)

  # Statement #1:
  allowed_plus_exception_regions = var.regions.allowed_regions != null ? distinct(concat(
    var.regions.allowed_regions,
    local.regions_with_whitelist_exceptions
  )) : []

  exempted_actions_us_east_1 = distinct(concat(
    local.multi_region_service_actions,
    local.us_east_1_global_service_actions,
    local.us_east_1_cdk_service_actions,
    local.us_east_1_security_lake_aggregation_service_actions,
  ))

  # Statement #2:
  exempted_actions_per_region = {
    for region, service_action in var.regions.additional_allowed_service_actions_per_region :
    region => distinct(concat(
      local.multi_region_service_actions,
      service_action
    ))
  }

  # To keep the SCP as small as possible and avoid duplication, regions with exactly the same allowed service actions are grouped together.
  exempted_actions_per_region_grouped = [
    for actions in distinct(values(local.exempted_actions_per_region)) : {
      actions = actions
      regions = [
        for region, service_action in local.exempted_actions_per_region :
        region if service_action == actions
      ]
    }
  ]

  # Statement #3:
  allowed_plus_linked_plus_exception_plus_us_east_1_regions = var.regions.allowed_regions != null ? distinct(concat(
    var.regions.allowed_regions,
    var.regions.linked_regions,
    local.regions_with_whitelist_exceptions,
    ["us-east-1"] # (us-east-1 is the default region for the global services, so we need to allow it)
  )) : []

  ################################################################################
  # 3) Assemble the 3 SCP statements
  ################################################################################

  allowed_regions_policy_statements = concat(
    # Statement (1) explanation:
    # Allow all services in your `allowed_regions` & regions listed in the `additional_allowed_service_actions_per_region`,
    # For all other regions, every service action is denied except for global & multi-region service actions.
    [
      {
        Sid       = "DenyAllRegionsOutsideAllowedList"
        Effect    = "Deny"
        NotAction = local.exempted_actions_us_east_1
        Resource  = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = local.allowed_plus_exception_regions
          }
          ArnNotLike = {
            "aws:PrincipalARN" = local.aws_service_control_policies_principal_exceptions
          }
        }
      }
    ],

    # Statement (2) explanation:
    # In each `additional_allowed_service_actions_per_region` region,
    # only allow the actions listed in the `additional_allowed_service_actions_per_region` map & the `multi_region_service_actions`.
    [
      for group in local.exempted_actions_per_region_grouped : {
        Sid       = "DenyOutsideAllowedList${replace(replace(join("_", group.regions), "-", ""), "_", "")}"
        Effect    = "Deny"
        NotAction = group.actions
        Resource  = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = group.regions
          }
          ArnNotLike = {
            "aws:PrincipalARN" = local.aws_service_control_policies_principal_exceptions
          }
        }
      }
    ],

    # Statement (3) explanation:
    # Deny all service actions except for the `multi_region_service_actions` in any region not in your allowed + linked + exception + [us-east-1] set.
    # This statement is for leak prevention: It explicitly denies any per-region-only services within your core allowed regions so they can’t slip in where you don’t want them;
    # as some services like acm & logs are both global and regional specific services.
    [
      {
        Sid       = "DenyAllOtherRegions"
        Effect    = "Deny"
        NotAction = local.multi_region_service_actions
        Resource  = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = local.allowed_plus_linked_plus_exception_plus_us_east_1_regions
          }
          ArnNotLike = {
            "aws:PrincipalARN" = local.aws_service_control_policies_principal_exceptions
          }
        }
      }
    ]
  )

  allowed_regions_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.allowed_regions_policy_statements
  })
}

resource "aws_organizations_policy" "allowed_regions" {
  count = var.regions.allowed_regions != null ? 1 : 0

  name        = "LandingZone-AllowedRegions"
  content     = local.allowed_regions_policy
  description = "LandingZone allowed regions"
  tags        = var.tags
}

resource "aws_organizations_policy_attachment" "allowed_regions" {
  count = var.regions.allowed_regions != null ? 1 : 0

  policy_id = aws_organizations_policy.allowed_regions[0].id
  target_id = data.aws_organizations_organization.default.roots[0].id
}
