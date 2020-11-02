# terraform-aws-mcaf-landing-zone
Terraform module to setup and manage various components of the AWS Landing Zone.

## AWS Config Rules

This module provisions by default a set of basic AWS Config Rules. In order to add extra rules, a list of [rule identifiers](https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html) can be passed to the variable `aws_config_rules` like in the example below:

```hcl
aws_config_rules = ["ACCESS_KEYS_ROTATED", "ALB_WAF_ENABLED"]
```

## Okta Groups for AWS SSO

By default, this module will create an Okta Group called `AWSPlatformAdmins` and assign the group to the AWS SSO Okta App.

To add other groups, a map of key-value pairs (`group_name` and `group_description`) can be passed down to the variable `aws_okta_groups` like in the example below:

```hcl
aws_okta_groups = {
  "AWSAuditors"   = "Provides auditing access to AWS accounts" 
  "AWSDevelopers" = "Provides developer access to AWS accounts"
}
```

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
| aws\_sso\_acs\_url | AWS SSO ACS URL for the Okta App | `string` | n/a | yes |
| aws\_sso\_entity\_id | AWS SSO Entity ID for the Okta App | `string` | n/a | yes |
| control\_tower\_account\_ids | Control Tower core account IDs | <pre>object({<br>    audit   = string<br>    logging = string<br>  })</pre> | n/a | yes |
| tags | Map of tags | `map` | n/a | yes |
| aws\_config\_rules | List of managed AWS Config Rule identifiers that should be deployed across the organization | `list` | `[]` | no |
| aws\_okta\_groups | Map of Okta Groups that should have access to the AWS organization (format: name => description) | `map` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| kms\_key\_arn | ARN of KMS key for SSM encryption |

<!--- END_TF_DOCS --->
