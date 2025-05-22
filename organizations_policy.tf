locals {
  # your existing static NotAction list:
  default_notactions = [
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
    "cloudwatch:Describe*",
    "cloudwatch:Get*",
    "cloudwatch:List*",
    "compute-optimizer:*",
    "config:*",
    "consoleapp:*",
    "consolidatedbilling:*",
    "cur:*",
    "datapipeline:GetAccountLimits",
    "devicefarm:*",
    "directconnect:*",
    "discovery-marketplace:*",
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
    "s3:PutBucketPolicy",
    "s3:PutMultiRegionAccessPointPolicy",
    "savingsplans:*",
    "servicequotas:*",
    "shield:*",
    "sso:*",
    "sts:*",
    "support:*",
    "supportapp:*",
    "sustainability:*",
    "tag:GetResources",
    "tax:*",
    "trustedadvisor:*",
    "vendor-insights:ListEntitledSecurityProfiles",
    "waf-regional:*",
    "waf:*",
    "wafv2:*",
    "wellarchitected:*"
  ]

  # 2) pull in your per-region exception map
  regional_exceptions = var.regions.allowed_regions_additional_service_exceptions_per_region

  # 3) for each region, build the combined NotAction list
  regional_notactions = {
    for region, extras in local.regional_exceptions :
    region => distinct(concat(local.default_notactions, extras))
  }

  # 4) the “other-regions” base list
  other_default_notactions = ["supportplans:*"]

  # 5) for each region, the “other-regions” carve-out
  other_regional_notactions = {
    for region, extras in local.regional_exceptions :
    region => distinct(concat(local.other_default_notactions, extras))
  }

  allowed              = var.regions.allowed_regions != null ? var.regions.allowed_regions : []
  allowed_plus_us_east = var.regions.allowed_regions != null ? distinct(concat(var.regions.allowed_regions, ["us-east-1"])) : []
  exceptions           = local.aws_service_control_policies_principal_exceptions

  statements = concat(
    [
      {
        Sid       = "DenyAllRegionsOutsideAllowedList"
        Effect    = "Deny"
        NotAction = local.default_notactions
        Resource  = "*"
        Condition = {
          StringNotEquals = { "aws:RequestedRegion" = local.allowed }
          ArnNotLike      = { "aws:PrincipalARN" = local.exceptions }
        }
      }
    ],
    [
      for region, na in local.regional_notactions : {
        Sid       = "DenyAllRegionsOutsideAllowedList_${region}"
        Effect    = "Deny"
        NotAction = na
        Resource  = "*"
        Condition = {
          StringEquals = { "aws:RequestedRegion" = [region] }
          ArnNotLike   = { "aws:PrincipalARN" = local.exceptions }
        }
      }
    ],
    [
      {
        Sid       = "DenyAllOtherRegions"
        Effect    = "Deny"
        NotAction = local.other_default_notactions
        Resource  = "*"
        Condition = {
          StringNotEquals = { "aws:RequestedRegion" = local.allowed_plus_us_east }
          ArnNotLike      = { "aws:PrincipalARN" = local.exceptions }
        }
      }
    ],
    [
      for region, na in local.other_regional_notactions : {
        Sid       = "DenyAllOtherRegions_${region}"
        Effect    = "Deny"
        NotAction = na
        Resource  = "*"
        Condition = {
          StringEquals = { "aws:RequestedRegion" = [region] }
          ArnNotLike   = { "aws:PrincipalARN" = local.exceptions }
        }
      }
    ]
  )

  enabled_root_policies = {
    allowed_regions = {
      enable = var.regions.allowed_regions != null ? true : false
      policy = var.regions.allowed_regions != null ? jsonencode({
        Version   = "2012-10-17"
        Statement = local.statements
      }) : null
    }
    cloudtrail_log_stream = {
      enable = true // This is not configurable and will be applied all the time.
      policy = file("${path.module}/files/organizations/cloudtrail_log_stream.json")
    }
    deny_disabling_security_hub = {
      enable = var.aws_service_control_policies.aws_deny_disabling_security_hub
      policy = var.aws_service_control_policies.aws_deny_disabling_security_hub != false ? templatefile("${path.module}/files/organizations/deny_disabling_security_hub.json.tpl", {
        exceptions = local.aws_service_control_policies_principal_exceptions
      }) : null
    }
    deny_leaving_org = {
      enable = var.aws_service_control_policies.aws_deny_leaving_org
      policy = var.aws_service_control_policies.aws_deny_leaving_org != false ? templatefile("${path.module}/files/organizations/deny_leaving_org.json.tpl", {
        exceptions = local.aws_service_control_policies_principal_exceptions
      }) : null
    }
    // https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ExamplePolicies_EC2.html#iam-example-instance-metadata-requireIMDSv2
    require_use_of_imdsv2 = {
      enable = var.aws_service_control_policies.aws_require_imdsv2
      policy = file("${path.module}/files/organizations/require_use_of_imdsv2.json")
    }
  }

  root_policies_to_merge = [for key, value in local.enabled_root_policies : jsondecode(
    value.enable == true ? value.policy : "{\"Statement\": []}"
  )]

  root_policies_merged = flatten([
    for policy in local.root_policies_to_merge : policy.Statement
  ])
}

resource "aws_organizations_policy" "lz_root_policies" {
  name = "LandingZone-RootPolicies"
  content = jsonencode({
    Version   = "2012-10-17"
    Statement = local.root_policies_merged
  })
  description = "LandingZone enabled Root OU policies"
  tags        = var.tags
}

resource "aws_organizations_policy_attachment" "lz_root_policies" {
  policy_id = aws_organizations_policy.lz_root_policies.id
  target_id = data.aws_organizations_organization.default.roots[0].id
}

// https://summitroute.com/blog/2020/03/25/aws_scp_best_practices/#deny-ability-to-leave-organization
resource "aws_organizations_policy" "deny_root_user" {
  count = length(var.aws_service_control_policies.aws_deny_root_user_ous) > 0 ? 1 : 0

  name    = "LandingZone-DenyRootUser"
  content = file("${path.module}/files/organizations/deny_root_user.json")
  tags    = var.tags
}

resource "aws_organizations_policy_attachment" "deny_root_user" {
  for_each = {
    for ou in data.aws_organizations_organizational_units.default.children : ou.name => ou if contains(var.aws_service_control_policies.aws_deny_root_user_ous, ou.name)
  }

  policy_id = aws_organizations_policy.deny_root_user[0].id
  target_id = each.value.id
}

module "tag_policy_assignment" {
  for_each = {
    for ou in data.mcaf_aws_all_organizational_units.default.organizational_units : ou.path => ou if contains(keys(coalesce(var.aws_required_tags, {})), ou.path)
  }

  source      = "./modules/tag-policy-assignment"
  aws_ou_tags = { for k, v in var.aws_required_tags[each.key] : v.name => v }
  target_id   = each.value.id
  ou_path     = each.key
  tags        = var.tags
}
