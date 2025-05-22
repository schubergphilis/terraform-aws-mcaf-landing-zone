locals {
  # 1) your original “management & read-only” actions
  default_notactions_base = ["a4b:*"]

  # 2) the built-in “other-regions” actions
  other_default_notactions_base = ["supportplans:*"]

  # 3) per-region extra services (only ever here now)
  regional_exceptions = var.regions.allowed_regions_additional_service_exceptions_per_region

  # 4) flatten all per-region extras into one list
  all_exception_services = distinct(flatten(values(local.regional_exceptions)))

  # 5) for the first Deny, we allow base + other-regions base + all extras
  default_notactions = distinct(concat(
    local.default_notactions_base,
    local.other_default_notactions_base,
    local.all_exception_services
  ))

  # 6) for each exception region, its own carve-out in the first rule
  regional_notactions = {
    for region, extras in local.regional_exceptions :
    region => distinct(concat(local.other_default_notactions_base, extras))
  }

  # 7) lists to drive region checks
  allowed           = var.regions.allowed_regions # ["eu-central-1"]
  exception_regions = keys(var.regions.allowed_regions_additional_service_exceptions_per_region)
  # ["us-west-2"]
  linked = var.regions.linked_regions # ["us-east-1"]

  # 8) combine for “deny outside allowed+exceptions”
  allowed_and_exceptions = distinct(concat(local.allowed, local.exception_regions))
  # 9) combine for “deny other regions” (allowed + us-east-1 + exceptions)
  allowed_plus_linked_and_exceptions = distinct(concat(local.allowed, local.linked, local.exception_regions))

  exceptions = local.aws_service_control_policies_principal_exceptions
  # 10) build the JSON Statement array

  statements = concat(
    # 1) Deny everything outside [eu-central-1, us-west-2]
    [
      {
        Sid       = "DenyAllRegionsOutsideAllowedList"
        Effect    = "Deny"
        NotAction = local.default_notactions
        Resource  = "*"
        Condition = {
          StringNotEquals = { "aws:RequestedRegion" = local.allowed_and_exceptions }
          ArnNotLike      = { "aws:PrincipalARN" = local.exceptions }
        }
      }
    ],

    # 2) In us-west-2, carve out its extra services (dms:*)
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

    # 3) Explicitly Deny dms:* in the allowed region(s) (eu-central-1)
    [
      {
        Sid      = "DenyExceptionServiceInAllowedRegions"
        Effect   = "Deny"
        Action   = local.all_exception_services
        Resource = "*"
        Condition = {
          StringEquals = { "aws:RequestedRegion" = local.allowed }
          ArnNotLike   = { "aws:PrincipalARN" = local.exceptions }
        }
      }
    ],

    # 4) Deny all other regions outside [eu-central-1, us-east-1, us-west-2]
    [
      {
        Sid       = "DenyAllOtherRegions"
        Effect    = "Deny"
        NotAction = local.other_default_notactions_base
        Resource  = "*"
        Condition = {
          StringNotEquals = { "aws:RequestedRegion" = local.allowed_plus_linked_and_exceptions }
          ArnNotLike      = { "aws:PrincipalARN" = local.exceptions }
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
