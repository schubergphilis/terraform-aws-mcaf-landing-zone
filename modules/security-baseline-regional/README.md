<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.7.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ebs_encryption_by_default.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default) | resource |
| [aws_ebs_snapshot_block_public_access.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_snapshot_block_public_access) | resource |
| [aws_ssm_service_setting.documents_public_sharing_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_service_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_ebs_encryption_by_default"></a> [aws\_ebs\_encryption\_by\_default](#input\_aws\_ebs\_encryption\_by\_default) | n/a | `bool` | n/a | yes |
| <a name="input_aws_ebs_snapshot_block_public_access_state"></a> [aws\_ebs\_snapshot\_block\_public\_access\_state](#input\_aws\_ebs\_snapshot\_block\_public\_access\_state) | n/a | `string` | n/a | yes |
| <a name="input_aws_ssm_documents_public_sharing_permission"></a> [aws\_ssm\_documents\_public\_sharing\_permission](#input\_aws\_ssm\_documents\_public\_sharing\_permission) | n/a | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->