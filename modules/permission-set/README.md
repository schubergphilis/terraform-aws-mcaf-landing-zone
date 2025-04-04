# AWS IAM Identity Center Permission Set

Terraform module to create and/or manage a permission set in AWS IAM Identity Center (previously known as AWS SSO).

## Usage

This module creates a permission set, or uses an existing permission set, and manages its account and group assignments.

To just create a permissions set for it to be managed elsewhere:

```hcl
module "permission_set" {
  source = "https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone//modules/permission-set"

  name         = "PlatformAdmin"
  managed_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}
```

Use `assignments` to assign this accounts and groups combinations to the created permission set:

```hcl
module "permission_set" {
  source = "https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone//modules/permission-set"

  name         = "PlatformAdmin"
  managed_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]

  assignments = [
    {
      for account in ["11111111111", "22222222222", "33333333333"] :
      account => ["SSOgroup1"]
    },
  ]
}
```

To manage an existing permission set, set `create` to `false`:

```hcl
module "permission_set" {
  source = "https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone//modules/permission-set"

  name         = "PlatformAdmin"
  create       = false
  managed_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]

  assignments = [
    {
      for account in ["11111111111", "22222222222", "33333333333"] :
      account => ["SSOgroup1"]
    },
  ]
}
```

Add additional assignments to reuse the permission set across different account and SSO group combinations:

```hcl
module "permission_set" {
  source = "https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone//modules/permission-set"

  name         = "PlatformAdmin"
  managed_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]

  assignments = [
    {
      for account in ["11111111111", "22222222222", "33333333333"] :
      account => ["SSOgroup1"]
    },
    {
      for account in ["33333333333", "44444444444"] :
      account => ["SSOgroup2"]
    },
  ]
}
```

It's also possible to create your own inline policy instead if more fine grained access is required:

```hcl
module "permission_set" {
  source = "https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone//modules/permission-set"

  name         = "PlatformAdmin"
  managed_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]

  assignments = [
    {
      for account in ["11111111111", "22222222222", "33333333333"] :
      account => ["SSOgroup1"]
    },
  ]

  inline_policy = jsonencode({
    "Version"   = "2012-10-17"
    "Statement" = jsondecode(file("${path.module}/templates/sso_platform_admin.json.tftpl"))
  })
}
```

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| aws | >= 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.9.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the permission set | `string` | n/a | yes |
| assignments | List of account IDs and Identity Center groups to assign to the permission set | `list(map(list(string)))` | `[]` | no |
| create | Set to false to only manage assignments when the permission set already exists | `bool` | `true` | no |
| inline\_policy | The IAM inline policy to attach to a permission set | `string` | `null` | no |
| managed\_policy\_arns | List of IAM managed policy ARNs to be attached to the permission set | `list(string)` | `[]` | no |
| module\_depends\_on | A list of external resources the module depends\_on | `any` | `[]` | no |
| session\_duration | The length of time that the application user sessions are valid in the ISO-8601 standard | `string` | `"PT4H"` | no |

## Outputs

No output.

<!--- END_TF_DOCS --->

## License

**Copyright:** Schuberg Philis

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssoadmin_account_assignment.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_managed_policy_attachment.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment) | resource |
| [aws_ssoadmin_permission_set.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |
| [aws_ssoadmin_permission_set_inline_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set_inline_policy) | resource |
| [aws_identitystore_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_group) | data source |
| [aws_ssoadmin_instances.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |
| [aws_ssoadmin_permission_set.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_permission_set) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the permission set | `string` | n/a | yes |
| <a name="input_assignments"></a> [assignments](#input\_assignments) | List of account names and IDs and Identity Center groups to assign to the permission set | <pre>list(object({<br/>    account_id   = string<br/>    account_name = string<br/>    sso_groups   = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_create"></a> [create](#input\_create) | Set to false to only manage assignments when the permission set already exists | `bool` | `true` | no |
| <a name="input_inline_policy"></a> [inline\_policy](#input\_inline\_policy) | The IAM inline policy to attach to a permission set | `string` | `null` | no |
| <a name="input_managed_policy_arns"></a> [managed\_policy\_arns](#input\_managed\_policy\_arns) | List of IAM managed policy ARNs to be attached to the permission set | `list(string)` | `[]` | no |
| <a name="input_module_depends_on"></a> [module\_depends\_on](#input\_module\_depends\_on) | A list of external resources the module depends\_on | `any` | `[]` | no |
| <a name="input_session_duration"></a> [session\_duration](#input\_session\_duration) | The length of time that the application user sessions are valid in the ISO-8601 standard | `string` | `"PT4H"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->