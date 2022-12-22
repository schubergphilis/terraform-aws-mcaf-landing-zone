locals {
  aws_sso_account_assignments = flatten([
    for assignment in var.assignments : [
      for aws_account_id, sso_groups in assignment : [
        for sso_group in sso_groups : {
          aws_account_id = aws_account_id
          sso_group      = sso_group
        }
      ]
    ]
  ])
}

data "aws_ssoadmin_instances" "default" {}

data "aws_identitystore_group" "default" {
  for_each = toset(distinct([
    for assignment in local.aws_sso_account_assignments : assignment.sso_group
  ]))

  identity_store_id = tolist(data.aws_ssoadmin_instances.default.identity_store_ids)[0]

  filter {
    attribute_path  = "DisplayName"
    attribute_value = each.value
  }

  depends_on = [
    var.module_depends_on
  ]
}

data "aws_ssoadmin_permission_set" "default" {
  count = var.create ? 0 : 1

  instance_arn = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  name         = var.name

  depends_on = [
    var.module_depends_on
  ]
}

resource "aws_ssoadmin_permission_set" "default" {
  count = var.create ? 1 : 0

  name             = var.name
  instance_arn     = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  session_duration = var.session_duration

  depends_on = [
    var.module_depends_on
  ]
}

resource "aws_ssoadmin_account_assignment" "default" {
  for_each = {
    for assignment in local.aws_sso_account_assignments :
    "${assignment.sso_group}:${assignment.aws_account_id}" => assignment
  }

  instance_arn       = var.create ? aws_ssoadmin_permission_set.default[0].instance_arn : data.aws_ssoadmin_permission_set.default[0].instance_arn
  permission_set_arn = var.create ? aws_ssoadmin_permission_set.default[0].arn : data.aws_ssoadmin_permission_set.default[0].arn
  principal_id       = data.aws_identitystore_group.default[each.value.sso_group].group_id
  principal_type     = "GROUP"
  target_id          = each.value.aws_account_id
  target_type        = "AWS_ACCOUNT"

  depends_on = [
    var.module_depends_on
  ]
}

resource "aws_ssoadmin_permission_set_inline_policy" "default" {
  count = var.inline_policy != null ? 1 : 0

  inline_policy      = var.inline_policy
  instance_arn       = aws_ssoadmin_permission_set.default[0].instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.default[0].arn

  depends_on = [
    var.module_depends_on
  ]
}

resource "aws_ssoadmin_managed_policy_attachment" "default" {
  for_each = toset(var.managed_policy_arns)

  instance_arn       = aws_ssoadmin_permission_set.default[0].instance_arn
  managed_policy_arn = each.value
  permission_set_arn = aws_ssoadmin_permission_set.default[0].arn

  depends_on = [
    var.module_depends_on
  ]
}
