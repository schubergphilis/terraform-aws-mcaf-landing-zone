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
| assignments | List of account IDs and SSO groups to assign to the Permission Set | `list(map(list(string)))` | `[]` | no |
| create | Set to false to only manage assignments when the permission set already exists | `bool` | `true` | no |
| inline\_policy | The IAM inline policy to attach to a Permission Set | `string` | `null` | no |
| managed\_policy\_arns | List of IAM managed policy ARNs to be attached to the Permission Set | `list(string)` | `[]` | no |
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
