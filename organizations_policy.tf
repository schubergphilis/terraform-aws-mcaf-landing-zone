locals {
  ################################################################################
  # Allowed Regions SCP creation
  ################################################################################

  ################################################################################
  # 1) Core service lists
  ################################################################################

  # AWS services that need to be allowed in the global (us-east-1) region.
  # These services are typically used for account management, billing, and other global operations.
  global_service_actions = [
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

  exempted_actions_global = distinct(concat(
    local.global_service_actions,
    local.multi_region_service_actions,
  ))

  # Statement #2:
  exempted_actions_per_region = {
    for region, service_action in var.regions.additional_allowed_service_actions_per_region :
    region => distinct(concat(
      local.multi_region_service_actions,
      service_action
    ))
  }

  per_region_lists = [
    for region, svc in var.regions.additional_allowed_service_actions_per_region : {
      region  = region
      actions = distinct(concat(local.multi_region_service_actions, svc))
    }
  ]

  unique_action_lists = distinct([
    for entry in local.per_region_lists : entry.actions
  ])

  per_region_grouped = [
    for actions in local.unique_action_lists : {
      actions = actions
      regions = [
        for entry in local.per_region_lists : entry.region if entry.actions == actions
      ]
    }
  ]

  # Statement #3:
  allowed_plus_linked_plus_exception_plus_global_regions = var.regions.allowed_regions != null ? distinct(concat(
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
        NotAction = local.exempted_actions_global
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
      for grp in local.per_region_grouped : {
        Sid       = "DenyOutsideAllowedList_${join("_", grp.regions)}"
        Effect    = "Deny"
        NotAction = grp.actions
        Resource  = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = grp.regions
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
            "aws:RequestedRegion" = local.allowed_plus_linked_plus_exception_plus_global_regions
          }
          ArnNotLike = {
            "aws:PrincipalARN" = local.aws_service_control_policies_principal_exceptions
          }
        }
      }
    ]
  )

  allowed_regions_policy = {
    enable = var.regions.allowed_regions != null ? true : false
    policy = var.regions.allowed_regions != null ? {
      Version   = "2012-10-17"
      Statement = local.allowed_regions_policy_statements
    } : null
  }

  ################################################################################
  # Enabled Root Policies
  ################################################################################

  enabled_root_policies = {
    allowed_regions = local.allowed_regions_policy
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

  root_policies_to_merge = [for key, value in local.enabled_root_policies :
    value.enable == true ? value.policy : { Statement : [] }
  ]

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
