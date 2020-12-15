resource "aws_organizations_policy" "allowed_regions" {
  count = var.aws_allowed_regions != null ? 1 : 0
  name  = "LandingZone-AllowedRegions"

  content = templatefile("${path.module}/files/organizations/allowed_regions_scp.json.tpl", {
    allowed_regions = jsonencode(var.aws_allowed_regions)
  })
}

resource "aws_organizations_policy_attachment" "allowed_regions" {
  count     = var.aws_allowed_regions != null ? 1 : 0
  policy_id = aws_organizations_policy.allowed_regions[0].id
  target_id = data.aws_organizations_organization.default.roots[0].id
}

resource "aws_organizations_policy" "deny_root_user" {
  count   = length(var.aws_deny_root_user_ous) > 0 ? 1 : 0
  name    = "LandingZone-DenyRootUser"
  content = file("${path.module}/files/organizations/deny_root_user.json")
}

resource "aws_organizations_policy_attachment" "deny_root_user" {
  for_each = {
    for ou in data.aws_organizations_organizational_units.default.children : ou.name => ou if contains(var.aws_deny_root_user_ous, ou.name)
  }

  policy_id = aws_organizations_policy.deny_root_user.0.id
  target_id = each.value.id
}
