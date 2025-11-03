# Amazon Inspector

This module enables Amazon Inspector across all accounts in an AWS Organization, following the AWS-recommended delegated administrator model.

Inspector operates as a Regional service — meaning the delegated administrator must be configured per region.  

The setup uses two providers:

- `aws.management` → the management (payer) account, which designates the delegated Inspector administrator.  
- `aws.delegated_admin` → the delegated administrator account, where Inspector is actually managed and organization-wide features are enabled.

For detailed background on how Inspector integrates with AWS Organizations, see the AWS documentation:  
🔗 [Inspector and AWS Organizations (AWS Docs)](https://docs.aws.amazon.com/inspector/latest/user/designating-admin.html)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |
| <a name="provider_aws.delegated_admin"></a> [aws.delegated\_admin](#provider\_aws.delegated\_admin) | >= 6.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_inspector2_delegated_admin_account.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/inspector2_delegated_admin_account) | resource |
| [aws_inspector2_enabler.delegated_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/inspector2_enabler) | resource |
| [aws_inspector2_enabler.member_accounts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/inspector2_enabler) | resource |
| [aws_inspector2_member_association.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/inspector2_member_association) | resource |
| [aws_inspector2_organization_configuration.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/inspector2_organization_configuration) | resource |
| [aws_caller_identity.delegated_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_scan"></a> [enable\_scan](#input\_enable\_scan) | Type of resources to scan. | <pre>object({<br/>    ec2         = optional(bool, true)<br/>    ecr         = optional(bool, true)<br/>    lambda      = optional(bool, true)<br/>    lambda_code = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_member_account_ids"></a> [member\_account\_ids](#input\_member\_account\_ids) | List of AWS account IDs to include in Inspector scans. | `list(string)` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region where the resources will be created. If omitted, the default provider region is used. | `string` | `null` | no |
| <a name="input_resource_create_timeout"></a> [resource\_create\_timeout](#input\_resource\_create\_timeout) | Timeout for creating AWS Inspector resources. | `string` | `"15m"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->