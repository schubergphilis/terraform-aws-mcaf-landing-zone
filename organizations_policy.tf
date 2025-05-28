locals {
  ################################################################################
  # Allowed Regions SCP creation
  ################################################################################

  ################################################################################
  # 1) Core service lists
  ################################################################################

  # AWS services that exist only at the global (us-east-1) level
  global_service_actions = [
    "a4b:*",
    "account:*",
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
    "compute-optimizer:*",
    "consoleapp:*",
    "consolidatedbilling:*",
    "cur:*",
    "datapipeline:GetAccountLimits",
    "devicefarm:*",
    "directconnect:*",
    "discovery-marketplace:*",
    "ecr-public:*",
    "fms:*",
    "freetier:*",
    "globalaccelerator:*",
    "health:*",
    "iam:*",
    "invoicing:*",
    "iq:*",
    "license-manager:ListReceivedLicenses",
    "mobileanalytics:*",
    "networkmanager:*",
    "notifications-contacts:*",
    "notifications:*",
    "organizations:*",
    "payments:*",
    "pricing:*",
    "resource-explorer-2:*",
    "route53-recovery-cluster:*",
    "route53-recovery-control-config:*",
    "route53-recovery-readiness:*",
    "route53:*",
    "route53domains:*",
    "servicequotas:*",
    "shield:*",
    "sso:*",
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
  ]

  # AWS services that are typically used at the global (us-east-1) level, but also have regional endpoints.
  # Therefore need additional protection to ensure they are not allowed in regions outside of the allowed list.
  global_and_regional_service_actions = [
    "access-analyzer:*",
    "acm:*",
    "cloudtrail:Describe*",
    "cloudtrail:Get*",
    "cloudtrail:List*",
    "cloudtrail:LookupEvents",
    "cloudwatch:Describe*",
    "cloudwatch:Get*",
    "cloudwatch:List*",
    "config:*",
    "ec2:DescribeRegions",
    "ec2:DescribeTransitGateways",
    "ec2:DescribeVpnGateways",
    "importexport:*",
    "kms:*",
    "lightsail:Get*",
    "logs:*",
    "quicksight:DescribeAccountSubscription",
    "quicksight:DescribeTemplate",
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
    "sts:*",
    "supportplans:*",
    "wellarchitected:*",
  ]

  ################################################################################
  # 2) Region-specific whitelisting
  ################################################################################

  # Flattened list of *all* region-specific whitelisted actions
  all_region_whitelisted_actions = distinct(flatten(values(var.regions.additional_allowed_service_actions_per_region)))

  # List of regions that have extra whitelisted actions
  regions_with_whitelist_exceptions = keys(var.regions.additional_allowed_service_actions_per_region)

  ################################################################################
  # 3) Compute exemption sets for each Deny statement
  ################################################################################

  # A) Actions to exempt from the “DenyAllRegionsOutsideAllowedList” rule:
  #    global + multi-region + any region-specific whitelists
  exempted_actions_for_outside_deny = distinct(concat(
    local.global_service_actions,
    local.global_and_regional_service_actions,
    local.all_region_whitelisted_actions
  ))

  # B) For each exception region, the NotAction list in the per-region carve-out
  exempted_actions_per_region = {
    for region, service_action in var.regions.additional_allowed_service_actions_per_region :
    region => distinct(concat(
      local.global_and_regional_service_actions,
      service_action
    ))
  }

  # C) Actions to exempt from the “DenyAllOtherRegions” rule:
  #    only the multi-region services (no global or region-specific here)
  exempted_actions_for_other_regions_deny = local.global_and_regional_service_actions

  ################################################################################
  # 4) Build the sets of regions used in conditions
  ################################################################################

  # For Statement #1: allowed + exception regions
  allowed_plus_exception_regions = var.regions.allowed_regions != null ? distinct(concat(
    var.regions.allowed_regions,
    local.regions_with_whitelist_exceptions
  )) : []

  # For Statement #4: allowed + linked + exception regions + us-east-1
  # (us-east-1 is the default region for the global services, so we need to allow it)
  allowed_linked_exception_regions = var.regions.allowed_regions != null ? distinct(concat(
    var.regions.allowed_regions,
    var.regions.linked_regions,
    local.regions_with_whitelist_exceptions,
    ["us-east-1"]
  )) : []

  ################################################################################
  # 5) Assemble the 3 SCP statements
  ################################################################################

  allowed_regions_policy_statements = concat(
    # Deny any region not in your allowed regions + all regions in additional_allowed_service_actions_per_region, but exempt global, multi-region, and all per-region-whitelisted actions.
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

    # 2) In each additional_allowed_service_actions_per_region region, carve out its region-specific actions
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

    # Deny any region not in your allowed + linked + exception set, but exempt only the multi-region actions.
    # This statement is for leak prevention:
    # It explicitly denies any per-region-only services within your core allowed regions so they can’t slip in where you don’t want them.
    [
      {
        Sid       = "DenyOtherRegions"
        Effect    = "Deny"
        NotAction = local.exempted_actions_for_other_regions_deny
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
    enable = var.regions.allowed_regions != null ? true : false
    policy = var.regions.allowed_regions != null ? jsonencode({
      Version   = "2012-10-17"
      Statement = local.allowed_regions_policy_statements
    }) : null
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
