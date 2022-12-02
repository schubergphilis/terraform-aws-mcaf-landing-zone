# Usage
<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| mcaf | >= 0.4.2 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| mcaf | >= 0.4.2 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_ou\_tags | Map of AWS OU tags and their properties | <pre>map(object({<br>    values       = optional(list(string))<br>    enforced_for = optional(list(string))<br>  }))</pre> | n/a | yes |
| target\_id | The unique identifier (ID) organizational unit (OU) that you want to attach the policy to. | `string` | n/a | yes |
| tags | Map of AWS resource tags | `map(string)` | `{}` | no |

## Outputs

No output.

<!--- END_TF_DOCS --->
