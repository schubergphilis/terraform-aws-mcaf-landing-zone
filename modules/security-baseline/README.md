<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ebs_encryption_by_default.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default) | resource |
| [aws_iam_account_password_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy) | resource |
| [aws_s3_account_public_access_block.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_account_public_access_block) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_security_baseline_input"></a> [security\_baseline\_input](#input\_security\_baseline\_input) | n/a | <pre>object({<br/>    aws_ebs_encryption_by_default = bool<br/>    aws_account_password_policy   = object({<br/>      allow_users_to_change        = bool<br/>      max_age                      = number<br/>      minimum_length               = number<br/>      require_lowercase_characters = bool<br/>      require_numbers              = bool<br/>      require_symbols              = bool<br/>      require_uppercase_characters = bool<br/>      reuse_prevention_history     = number<br/>    })<br/>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->