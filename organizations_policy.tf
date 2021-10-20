locals {

  enabled_policies = {
    deny_disabling_security_hub = var.aws_deny_disabling_security_hub
    deny_leaving_org            = var.aws_deny_leaving_org
    cloudtrail_log_stream       = true // This is not configurable and will be applied all the time.
  }

  iam_policies_to_merge = [for src in local.merge_policies : jsondecode(
    file(local.enabled_policies[src] == true ? "${path.module}/files/organizations/${src}.json" : "${path.module}/files/organizations/empty_policy.json")
  )]

  merged_iam_policy_statements = flatten([
    for policy in local.iam_policies_to_merge : policy.Statement
  ])

  merge_policies = [
    "deny_disabling_security_hub",
    "deny_leaving_org",
    "cloudtrail_log_stream"
  ]
  merged_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.merged_iam_policy_statements
  })
}

resource "aws_organizations_policy" "allowed_regions" {
  count = var.aws_region_restrictions != null ? 1 : 0
  name  = "LandingZone-AllowedRegions"
  tags  = var.tags

  content = templatefile("${path.module}/files/organizations/allowed_regions_scp.json.tpl", {
    allowed    = var.aws_region_restrictions.allowed
    exceptions = var.aws_region_restrictions.exceptions
  })
}

resource "aws_organizations_policy_attachment" "allowed_regions" {
  count     = var.aws_region_restrictions != null ? 1 : 0
  policy_id = aws_organizations_policy.allowed_regions.0.id
  target_id = data.aws_organizations_organization.default.roots.0.id
}

resource "aws_organizations_policy" "deny_policies" {
  name        = "LandingZone-MergedDenyPolicies"
  description = "Conditionally merged: DenyDisableSecurityHub, DenyLeavingOrg and DenyDeletingCloudTrailLogStream"
  content     = local.merged_policy
  tags        = var.tags
}

resource "aws_organizations_policy_attachment" "deny_policies" {
  policy_id = aws_organizations_policy.deny_policies.id
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

// https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ExamplePolicies_EC2.html#iam-example-instance-metadata-requireIMDSv2
resource "aws_organizations_policy" "require_use_of_imdsv2" {
  count   = var.aws_require_imdsv2 == true ? 1 : 0
  name    = "LandingZone-RequireUseOfIMDSv2"
  content = file("${path.module}/files/organizations/require_use_of_imdsv2.json")
  tags    = var.tags
}

resource "aws_organizations_policy_attachment" "require_use_of_imdsv2" {
  count     = var.aws_require_imdsv2 == true ? 1 : 0
  policy_id = aws_organizations_policy.require_use_of_imdsv2.0.id
  target_id = data.aws_organizations_organization.default.roots.0.id
}

// https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_supported-resources-enforcement.html
resource "aws_organizations_policy" "required_tags" {
  for_each = {
    for ou in data.aws_organizations_organizational_units.default.children : ou.name => ou if contains(keys(coalesce(var.aws_required_tags, {})), ou.name)
  }

  name = "LandingZone-RequiredTags-${each.key}"
  type = "TAG_POLICY"
  tags = var.tags

  content = templatefile("${path.module}/files/organizations/required_tags.json.tpl", {
    tags = var.aws_required_tags[each.key]
  })
}

resource "aws_organizations_policy_attachment" "required_tags" {
  for_each = {
    for ou in data.aws_organizations_organizational_units.default.children : ou.name => ou if contains(keys(coalesce(var.aws_required_tags, {})), ou.name)
  }

  policy_id = aws_organizations_policy.required_tags[each.key].id
  target_id = each.value.id
}
