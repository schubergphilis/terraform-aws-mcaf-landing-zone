# terraform-aws-mcaf-landing-zone
Terraform module to setup and manage various components of the AWS Landing Zone.

## AWS Config Rules

This module provisions by default a set of basic AWS Config Rules. In order to add extra rules, a list of [rule identifiers](https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html) can be passed to the variable `aws_config_rules` like in the example below:

```hcl
aws_config_rules = ["ACCESS_KEYS_ROTATED", "ALB_WAF_ENABLED"]
```

## Datadog Integration

This module supports an optional Datadog-AWS integration. This integration makes it easier for you to forward metrics and logs from your AWS account to Datadog.

In order to enable the integration, you can pass an object to the variable `datadog_integration` containing the following attributes: (Note: `enabled` and `forward_logs` should be set for each core account)
- `api_key`: Datadog API Key.
- `enabled`: boolean indicating if the integration should be enabled.
- `forward_logs`: boolean indicating if logs should be forwarded to Datadog.

Example:
```hcl
datadog_integration = {
  api_key = "abc123"
  audit = {
    enabled      = true
    forward_logs = false
  }
  logging = {
    enabled      = true
    forward_logs = true
  }
  master = {
    enabled      = true
    forward_logs = false
  }
}
```

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
| datadog\_integration | Configuration for Datadog Integration | <pre>object({<br>    api_key = string<br>    audit = object({<br>      enabled      = bool<br>      forward_logs = bool<br>    })<br>    logging = object({<br>      enabled      = bool<br>      forward_logs = bool<br>    })<br>    master = object({<br>      enabled      = bool<br>      forward_logs = bool<br>    })<br>  })</pre> | <pre>{<br>  "api_key": null,<br>  "audit": {<br>    "enabled": false,<br>    "forward_logs": false<br>  },<br>  "logging": {<br>    "enabled": false,<br>    "forward_logs": false<br>  },<br>  "master": {<br>    "enabled": false,<br>    "forward_logs": false<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| kms\_key\_arn | ARN of KMS key for SSM encryption |

<!--- END_TF_DOCS --->
