module "aws_sso_permission_sets" {
  for_each = var.aws_sso_permission_sets

  source = "./modules/permission-set"

  name                = each.key
  session_duration    = each.value.session_duration
  assignments         = each.value.assignments
  inline_policy       = each.value.inline_policy
  managed_policy_arns = each.value.managed_policy_arns
}
