module "aws_sso_permission_sets" {
  for_each = var.aws_sso_permission_sets

  source                                       = "./modules/permission-set"
  name                                         = each.key
  assignments                                  = each.value.assignments
  inline_policy                                = each.value.inline_policy
  managed_policy_arns                          = each.value.managed_policy_arns
  permissions_boundary_aws_managed_policy_arn  = each.value.permissions_boundary_aws_managed_policy_arn
  permissions_boundary_customer_managed_policy = each.value.permissions_boundary_customer_managed_policy
  session_duration                             = each.value.session_duration
}
