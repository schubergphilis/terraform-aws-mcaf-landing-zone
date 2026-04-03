locals {
  aws_sso_account_assignments = flatten([
    for assignment in var.assignments : [
      for sso_group in assignment.sso_groups : {
        aws_account_id   = assignment.account_id
        aws_account_name = assignment.account_name
        sso_group        = sso_group
      }
    ]
  ])

  instance_arn       = var.create ? aws_ssoadmin_permission_set.default[0].instance_arn : data.aws_ssoadmin_permission_set.default[0].instance_arn
  permission_set_arn = var.create ? aws_ssoadmin_permission_set.default[0].arn : data.aws_ssoadmin_permission_set.default[0].arn
}

data "aws_ssoadmin_instances" "default" {}

data "aws_identitystore_group" "default" {
  for_each = toset(flatten([
    for assignment in var.assignments : assignment.sso_groups
  ]))

  identity_store_id = tolist(data.aws_ssoadmin_instances.default.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.value
    }
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
    "${assignment.sso_group}:${assignment.aws_account_name}" => assignment
  }

  instance_arn       = local.instance_arn
  permission_set_arn = local.permission_set_arn
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
  instance_arn       = local.instance_arn
  permission_set_arn = local.permission_set_arn

  depends_on = [
    var.module_depends_on
  ]
}

resource "aws_ssoadmin_managed_policy_attachment" "default" {
  for_each = toset(var.managed_policy_arns)

  instance_arn       = local.instance_arn
  managed_policy_arn = each.value
  permission_set_arn = local.permission_set_arn

  depends_on = [
    var.module_depends_on
  ]
}

resource "aws_ssoadmin_permissions_boundary_attachment" "aws_managed_policy" {
  count = var.permissions_boundary_aws_managed_policy_arn != null ? 1 : 0

  instance_arn       = local.instance_arn
  permission_set_arn = local.permission_set_arn

  permissions_boundary {
    managed_policy_arn = var.permissions_boundary_aws_managed_policy_arn
  }

  depends_on = [
    var.module_depends_on
  ]
}

resource "aws_ssoadmin_permissions_boundary_attachment" "customer_managed_policy" {
  count = var.permissions_boundary_customer_managed_policy != null ? 1 : 0

  instance_arn       = local.instance_arn
  permission_set_arn = local.permission_set_arn

  permissions_boundary {
    customer_managed_policy_reference {
      name = var.permissions_boundary_customer_managed_policy.name
      path = var.permissions_boundary_customer_managed_policy.path
    }
  }

  depends_on = [
    var.module_depends_on
  ]
}
