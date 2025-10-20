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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_regional_resources_baseline"></a> [regional\_resources\_baseline](#module\_regional\_resources\_baseline) | ./../../modules/security-baseline-regional | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_image_block_public_access.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_image_block_public_access) | resource |
| [aws_iam_account_password_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy) | resource |
| [aws_s3_account_public_access_block.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_account_public_access_block) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_security_baseline_input"></a> [security\_baseline\_input](#input\_security\_baseline\_input) | n/a | <pre>object({<br/>    regions                                     = set(string)<br/>    aws_ebs_encryption_by_default               = bool<br/>    aws_ebs_snapshot_block_public_access_state  = string<br/>    aws_ec2_image_block_public_access_state     = string<br/>    aws_ssm_documents_public_sharing_permission = string<br/>    aws_account_password_policy = object({<br/>      allow_users_to_change        = bool<br/>      max_age                      = number<br/>      minimum_length               = number<br/>      require_lowercase_characters = bool<br/>      require_numbers              = bool<br/>      require_symbols              = bool<br/>      require_uppercase_characters = bool<br/>      reuse_prevention_history     = number<br/>    })<br/>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->