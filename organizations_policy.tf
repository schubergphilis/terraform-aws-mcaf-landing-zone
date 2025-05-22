locals {

  ################################################################################
  # Allowed Regions SCP creation
  ################################################################################

  ################################################################################
  # 1) Core service lists
  ################################################################################

  # AWS services that exist only at the global (non-regional) level
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

  # AWS services that are inherently multi-region
  multi_region_service_actions = [
    "supportplans:*"
  ]

  ################################################################################
  # 2) Region-specific whitelisting
  ################################################################################

  # Map of region → extra actions to allow there
  per_region_whitelist_map = var.regions.additional_allowed_service_actions_per_region

  # Flattened list of *all* region-specific whitelisted actions
  all_region_whitelisted_actions = distinct(flatten(values(local.per_region_whitelist_map)))

  # List of regions that have extra whitelisted actions
  regions_with_whitelist_exceptions = keys(local.per_region_whitelist_map)

  ################################################################################
  # 3) Compute exemption sets for each Deny statement
  ################################################################################

  # A) Actions to exempt from the “DenyAllRegionsOutsideAllowedList” rule:
  #    global + multi-region + any region-specific whitelists
  exempted_actions_for_outside_deny = distinct(concat(
    local.global_service_actions,
    local.multi_region_service_actions,
    local.all_region_whitelisted_actions
  ))

  # B) For each exception region, the NotAction list in the per-region carve-out
  exempted_actions_per_region = {
    for region, service_action in local.per_region_whitelist_map :
    region => distinct(concat(
      local.multi_region_service_actions,
      service_action
    ))
  }

  # C) Actions to exempt from the “DenyAllOtherRegions” rule:
  #    only the multi-region services (no global or region-specific here)
  exempted_actions_for_other_deny = local.multi_region_service_actions

  ################################################################################
  # 4) Build the sets of regions used in conditions
  ################################################################################

  # For Statement #1: allowed + exception regions
  allowed_plus_exception_regions = distinct(concat(
    var.regions.allowed_regions,
    local.regions_with_whitelist_exceptions
  ))

  # For Statement #4: allowed + linked + exception regions
  allowed_linked_exception_regions = distinct(concat(
    var.regions.allowed_regions,
    var.regions.linked_regions,
    local.regions_with_whitelist_exceptions
  ))

  ################################################################################
  # 5) Assemble the 4 SCP statements
  ################################################################################

  statements = concat(
    # 1) Deny everywhere *except* allowed + exception regions,
    #    but exempt the “exempted_actions_for_outside_deny”
    [
      {
        Sid       = "DenyOutsideAllowedAndExceptionRegions"
        Effect    = "Deny"
        NotAction = local.exempted_actions_for_outside_deny
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

    # 2) In each exception region, carve out its region-specific actions
    [
      for region, notactions in local.exempted_actions_per_region : {
        Sid       = "DenyOutsideAllowedList_${region}"
        Effect    = "Deny"
        NotAction = notactions
        Resource  = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = [region]
          }
          ArnNotLike = {
            "aws:PrincipalARN" = local.aws_service_control_policies_principal_exceptions
          }
        }
      }
    ],

    # 3) Explicitly Deny the whitelisted services *within* your allowed regions
    [
      {
        Sid      = "DenyRegionSpecificWhitelistInAllowedRegions"
        Effect   = "Deny"
        Action   = local.all_region_whitelisted_actions
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = var.regions.allowed_regions
          }
          ArnNotLike = {
            "aws:PrincipalARN" = local.aws_service_control_policies_principal_exceptions
          }
        }
      }
    ],

    # 4) Deny all other regions (outside allowed + linked + exception),
    #    exempting only the multi-region services
    [
      {
        Sid       = "DenyOtherRegions"
        Effect    = "Deny"
        NotAction = local.exempted_actions_for_other_deny
        Resource  = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = local.allowed_linked_exception_regions
          }
          ArnNotLike = {
            "aws:PrincipalARN" = local.aws_service_control_policies_principal_exceptions
          }
        }
      }
    ]
  )

  allowed_regions_policy = {
    enable = length(var.regions.allowed_regions) > 0
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = local.statements
    })
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
