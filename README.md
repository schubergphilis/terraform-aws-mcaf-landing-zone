# terraform-aws-mcaf-landing-zone
Terraform module to setup and manage various components of the AWS Landing Zone.

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | ~> 3.7.0 |
| okta | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.7.0 |
| okta | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| audit\_account\_id | Account ID of AWS audit account | `string` | n/a | yes |
| aws\_sso\_acs\_url | AWS SSO ACS URL for the Okta App | `string` | n/a | yes |
| aws\_sso\_entity\_id | AWS SSO Entity ID for the Okta App | `string` | n/a | yes |
| control\_tower\_account\_ids | Control Tower core account IDs | <pre>object({<br>    audit   = string<br>    logging = string<br>  })</pre> | n/a | yes |
| tags | Map of tags | `map` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| kms\_key\_arn | ARN of KMS key for SSM encryption |

<!--- END_TF_DOCS --->
