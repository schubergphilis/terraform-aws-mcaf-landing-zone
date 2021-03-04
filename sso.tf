resource "aws_ssoadmin_permission_set" "default" {
  for_each         = var.aws_sso_permission_sets
  name             = each.key
  instance_arn     = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  session_duration = each.value.session_duration
}

resource "aws_ssoadmin_account_assignment" "default" {
  for_each           = { for assignment in local.aws_sso_account_assignment : "${assignment.sso_group}-${assignment.aws_account_id}-${assignment.permission_set_name}" => assignment }
  instance_arn       = aws_ssoadmin_permission_set.default[each.value.permission_set_name].instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.default[each.value.permission_set_name].arn

  principal_id   = data.aws_identitystore_group.sso[each.value.sso_group].group_id
  principal_type = "GROUP"

  target_id   = each.value.aws_account_id
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_permission_set_inline_policy" "default" {
  for_each           = var.aws_sso_permission_sets
  inline_policy      = each.value.inline_policy
  instance_arn       = aws_ssoadmin_permission_set.default[each.key].instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.default[each.key].arn
}
