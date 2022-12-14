locals {
  ou_path = replace(var.ou_path, "/", "-")
}

// https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_supported-resources-enforcement.html
resource "aws_organizations_policy" "required_tags" {
  for_each = var.aws_ou_tags

  name = "LandingZone-RequiredTags-${local.ou_path}-${each.key}"
  type = "TAG_POLICY"
  tags = var.tags

  content = jsonencode(
    {
      tags = {
        (each.key) = merge(
          {
            tag_key = {
              "@@assign"                               = each.key,
              "@@operators_allowed_for_child_policies" = ["@@none"]
            }
          },
          try(each.value["values"] != null, false) ?
          {
            tag_value = { "@@assign" = each.value["values"] }
          } : {},
          try(each.value["enforced_for"] != null, false) ?
          {
            enforced_for = {
              "@@assign" = (each.value["enforced_for"][0] == "all" ?
              local.all_enforced_services : each.value["enforced_for"])
            }
          } : {},
        )
      }
    }
  )
}

resource "aws_organizations_policy_attachment" "required_tags" {
  for_each = var.aws_ou_tags

  policy_id = aws_organizations_policy.required_tags[each.key].id
  target_id = var.target_id
}
