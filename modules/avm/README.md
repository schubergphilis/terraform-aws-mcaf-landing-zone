# AWS AVM (Account Vending Machine)

Terraform module to provision an AWS account with a TFE workspace backed by a VCS project.

## AWS Config Rules

If you would like to authorize other accounts to aggregate AWS Config data, the account IDs and regions can be passed via the variable `aws_config` using the attributes `aggregator_account_ids` and `aggregator_regions` respectively.

Example:

```hcl
aws_config = {
  aggregator_account_ids = ["123456789012"]
  aggregator_regions     = ["eu-west-1"]
}
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

## Monitoring IAM Access

This module offers the capability of monitoring IAM activity of both users and roles. To enable this feature, you have to provide the ARN of the SNS Topic that should be notified in case any activity is detected.

The topic ARN can be set using the attribute `sns_topic_arn` in the variable `monitor_iam_access`. In case the feature is enabled, the activity of the `root` user will be automatically monitored and reported.

If you would like to monitor other users or roles, a list can be passed using the attribute `identities` in the variable `monitor_iam_access`. All objects in the list should have the attributes `name` and `type` where `name` is either the name of the IAM Role or the IAM User and `type` is either `AssumedRole` or `IAMUser`. 

For more details regarding identities, please check [this link](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-event-reference-user-identity.html).

NOTE: Data Sources will be used to make sure that the identities provided actually exist in the account to avoid monitoring non-existent resources. In case an invalid identity is provided, a `NoSuchEntity` error will be thrown. 

Example:

```hcl
monitor_iam_access = {
  sns_topic_arn = aws_sns_topic.monitor_iam_access.arn
  identities = [
    {
      name = "AWSReservedSSO_AWSAdministratorAccess_123abc"
      type = "AssumedRole"
    }
  ]
}
```

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | ~> 3.7.0 |
| datadog | ~> 2.14 |
| github | ~> 3.1.0 |
| mcaf | ~> 0.1.0 |
| tfe | ~> 0.21.0 |

## Providers

| Name | Version |
|------|---------|
| aws.managed\_by\_inception | ~> 3.7.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| defaults | Default options for this module | <pre>object({<br>    account_prefix         = string<br>    github_organization    = string<br>    sso_email              = string<br>    terraform_organization = string<br>    terraform_version      = string<br>  })</pre> | n/a | yes |
| name | Stack name | `string` | n/a | yes |
| oauth\_token\_id | The OAuth token ID of the VCS provider | `string` | n/a | yes |
| tags | Map of tags | `map(string)` | n/a | yes |
| account\_name | Name of the AWS Service Catalog provisioned account (overrides computed name from the `name` variable) | `string` | `null` | no |
| aws\_config | AWS Config settings | <pre>object({<br>    aggregator_account_ids = list(string)<br>    aggregator_regions     = list(string)<br>  })</pre> | `null` | no |
| datadog | Datadog integration options | <pre>object({<br>    api_key               = string<br>    enable_integration    = bool<br>    install_log_forwarder = bool<br>  })</pre> | `null` | no |
| email | Email address of the account | `string` | `null` | no |
| environment | Stack environment | `string` | `null` | no |
| kms\_key\_id | The KMS key ID used to encrypt the SSM parameters | `string` | `null` | no |
| monitor\_iam\_access | Object containing list of IAM Identities that should have their access monitored and the SNS Topic that should be notified | <pre>object({<br>    sns_topic_arn = string<br>    identities = list(object({<br>      name = string<br>      type = string<br>    }))<br>  })</pre> | `null` | no |
| organizational\_unit | Organizational Unit to place account in | `string` | `null` | no |
| provisioned\_product\_name | A custom name for the provisioned product | `string` | `null` | no |
| region | The default region of the account | `string` | `"eu-west-1"` | no |
| ssh\_key\_id | The SSH key ID to assign to the TFE workspace | `string` | `null` | no |
| sso\_firstname | The firstname of the Control Tower SSO account | `string` | `"AWS Control Tower"` | no |
| sso\_lastname | The lastname of the Control Tower SSO account | `string` | `"Admin"` | no |
| terraform\_auto\_apply | Whether to automatically apply changes when a Terraform plan is successful | `bool` | `false` | no |
| terraform\_version | Terraform version to use | `string` | `null` | no |
| tfe\_vcs\_branch | Terraform VCS branch to use | `string` | `"master"` | no |
| trigger\_prefixes | List of repository-root-relative paths which should be tracked for changes | `list(string)` | <pre>[<br>  "modules"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The AWS account ID |
| workspace\_id | The TFE workspace ID |

<!--- END_TF_DOCS --->
