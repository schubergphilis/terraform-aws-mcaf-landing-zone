# terraform-aws-mcaf-landing-zone
Terraform module to setup and manage various components of the AWS Landing Zone.

## AWS Config Rules

This module provisions by default a set of basic AWS Config Rules. In order to add extra rules, a list of [rule identifiers](https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html) can be passed to the variable `aws_config_rules` like in the example below:

```hcl
aws_config_rules = ["ACCESS_KEYS_ROTATED", "ALB_WAF_ENABLED"]
```

## Datadog Integration

This module supports an optional Datadog-AWS integration. This integration makes it easier for you to forward metrics and logs from your AWS account to Datadog.

In order to enable the integration, you can pass an object to the variable `datadog` containing the following attributes:
- `api_key`: sets the Datadog API key
- `enable_integration`: set to `true` to configure the [Datadog AWS integration](https://docs.datadoghq.com/integrations/amazon_web_services/)
- `install_log_forwarder`: set to `true` to install the [Datadog Forwarder](https://docs.datadoghq.com/serverless/forwarder/)

In case you don't want to use the integration, you can configure the Datadog provider like in the example below:

```hcl
provider "datadog" {
  validate = false
}
```

This should prevent the provider from asking you for a Datadog API Key and allow the module to be provisioned without the integration resources.

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
| aws\_okta\_group\_ids | List of Okta group IDs that should be assigned the AWS SSO Okta app | `list` | `[]` | no |
| datadog | Datadog integration options for the core accounts | <pre>object({<br>    api_key               = string<br>    enable_integration    = bool<br>    install_log_forwarder = bool<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| kms\_key\_arn | ARN of KMS key for SSM encryption |

<!--- END_TF_DOCS --->
