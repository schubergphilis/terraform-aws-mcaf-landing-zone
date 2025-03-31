# Usage
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
| aws\_ou\_tags | Map of AWS OU names and their tag policies | <pre>map(object({<br>    values       = optional(list(string))<br>    enforced_for = optional(list(string))<br>  }))</pre> | n/a | yes |
| ou\_path | Path of the organizational unit (OU) | `string` | n/a | yes |
| target\_id | The unique identifier (ID) organizational unit (OU) that you want to attach the policy to. | `string` | n/a | yes |
| tags | Map of AWS resource tags | `map(string)` | `{}` | no |

## Outputs

No output.

<!--- END_TF_DOCS --->

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
| [aws_organizations_policy.required_tags](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy_attachment.required_tags](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_ou_tags"></a> [aws\_ou\_tags](#input\_aws\_ou\_tags) | Map of AWS OU names and their tag policies | <pre>map(object({<br/>    values       = optional(list(string))<br/>    enforced_for = optional(list(string))<br/>  }))</pre> | n/a | yes |
| <a name="input_ou_path"></a> [ou\_path](#input\_ou\_path) | Path of the organizational unit (OU) | `string` | n/a | yes |
| <a name="input_target_id"></a> [target\_id](#input\_target\_id) | The unique identifier (ID) organizational unit (OU) that you want to attach the policy to. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of AWS resource tags | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->