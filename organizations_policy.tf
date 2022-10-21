locals {
  enabled_root_policies = {
    allowed_regions = {
      enable = var.aws_region_restrictions != null ? true : false
      policy = var.aws_region_restrictions != null ? templatefile("${path.module}/files/organizations/allowed_regions.json.tpl", {
        allowed    = var.aws_region_restrictions.allowed
        exceptions = var.aws_region_restrictions.exceptions
      }) : null
    }
    cloudtrail_log_stream = {
      enable = true // This is not configurable and will be applied all the time.
      policy = file("${path.module}/files/organizations/cloudtrail_log_stream.json")
    }
    deny_disabling_security_hub = {
      enable = var.aws_deny_disabling_security_hub
      policy = file("${path.module}/files/organizations/deny_disabling_security_hub.json")
    }
    deny_leaving_org = {
      enable = var.aws_deny_leaving_org
      policy = file("${path.module}/files/organizations/deny_leaving_org.json")
    }
    // https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ExamplePolicies_EC2.html#iam-example-instance-metadata-requireIMDSv2
    require_use_of_imdsv2 = {
      enable = var.aws_require_imdsv2
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
  target_id = data.aws_organizations_organization.default.roots.0.id
}

// https://summitroute.com/blog/2020/03/25/aws_scp_best_practices/#deny-ability-to-leave-organization
resource "aws_organizations_policy" "deny_root_user" {
  count   = length(var.aws_deny_root_user_ous) > 0 ? 1 : 0
  name    = "LandingZone-DenyRootUser"
  content = file("${path.module}/files/organizations/deny_root_user.json")
  tags    = var.tags
}

resource "aws_organizations_policy_attachment" "deny_root_user" {
  for_each = {
    for ou in data.aws_organizations_organizational_units.default.children : ou.name => ou if contains(var.aws_deny_root_user_ous, ou.name)
  }

  policy_id = aws_organizations_policy.deny_root_user.0.id
  target_id = each.value.id
}

// https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_supported-resources-enforcement.html
resource "aws_organizations_policy" "required_tags" {
  for_each = {
    for ou in data.aws_organizations_organizational_units.default.children : ou.name => ou if contains(keys(coalesce(var.aws_required_tags, {})), ou.name)
  }

  name = "LandingZone-RequiredTags-${each.key}"
  type = "TAG_POLICY"
  tags = var.tags

  content = merge(flatten([
    for tag in var.aws_required_tags[each.key] : {
      (tag.name) = merge(
        {
          tag_key = { "@@assign" = tag.name, "@@operators_allowed_for_child_policies" = ["@@none"] }
        },
        can(tag.values) ? {
          tag_value = { "@@assign" = tag.values }
      } : {})
    }
  ])...)
}

resource "aws_organizations_policy_attachment" "required_tags" {
  for_each = {
    for ou in data.aws_organizations_organizational_units.default.children : ou.name => ou if contains(keys(coalesce(var.aws_required_tags, {})), ou.name)
  }

  policy_id = aws_organizations_policy.required_tags[each.key].id
  target_id = each.value.id
}
