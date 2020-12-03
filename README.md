# terraform-aws-mcaf-landing-zone
Terraform module to setup and manage various components of the AWS Landing Zone.

## AWS CloudTrail

By default, all CloudTrail logs will be stored in a S3 bucket in the `logging` account of your AWS Organization. However, this module also supports creating an additional CloudTrail configuration to publish logs to any S3 bucket chosen by you. This trail will be set at the Organization level, meaning that logs from all accounts will be published to the provided bucket.

Example:

```hcl
additional_auditing_trail = {
  name   = "additional_auditing_trail"
  bucket = "bucket_name"
}
```

## AWS Config Rules

This module provisions by default a set of basic AWS Config Rules. In order to add extra rules, a list of [rule identifiers](https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html) can be passed via the variable `aws_config` using the attribute `rule_identifiers`.

If you would like to authorize other accounts to aggregate AWS Config data, the account IDs and regions can also be passed via the variable `aws_config` using the attributes `aggregator_account_ids` and `aggregator_regions` respectively. 

NOTE: This module already authorizes the `audit` account to aggregate Config data from all other accounts in the organization, so there is no need to specify the `audit` account ID in the `aggregator_account_ids` list.

Example:

```hcl
aws_config = {
  aggregator_account_ids = ["123456789012"]
  aggregator_regions     = ["eu-west-1"]
  rule_identifiers       = ["ACCESS_KEYS_ROTATED", "ALB_WAF_ENABLED"]
}
```

## AWS GuardDuty

This module supports enabling GuardDuty at the organization level which means that all new accounts that are created in, or added to, the organization are added as a member accounts of the `audit` account GuardDuty detector.

This feature can be controlled via the `aws_guardduty` variable and is enabled by default.

Note: In case you are migrating an existing AWS organization to this module, all existing accounts except for the `master` and `logging` accounts have to be enabled like explained [here](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_organizations.html#guardduty_add_orgs_accounts).

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

This module automatically monitors and notifies all activities performed by the `root` user of all core accounts. All notifications will be sent to the SNS Topic `LandingZone-MonitorIAMAccess` in the `audit` account.

In case you would like to monitor other users or roles, a list can be passed using the variable `monitor_iam_access`. All objects in the list should have the attributes `account`, `name` and `type`. 

The allowed values are:

- `account`: `audit`, `logging` or `master`
- `name`: the name of the IAM Role or the IAM User
- `type`: `AssumedRole` or `IAMUser` 

For more details regarding identities, please check [this link](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-event-reference-user-identity.html).

NOTE: Data Sources will be used to make sure that the identities provided actually exist in each account to avoid monitoring non-existent resources. In case an invalid identity is provided, a `NoSuchEntity` error will be thrown. 

Example:

```hcl
monitor_iam_access = [
  {
    account = "master"
    name    = "AWSReservedSSO_AWSAdministratorAccess_123abc"
    type    = "AssumedRole"
  }
]
```

## Restricting AWS Regions

If you would like to define which AWS Regions can be used in your AWS Organization, you can pass a list of region names to the variable `aws_allowed_regions`. This will trigger this module to deploy a [Service Control Policy (SCP) designed by AWS](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps_examples.html#example-scp-deny-region) and attach it to the root of your AWS Organization.

Example:

```hcl
aws_allowed_regions = ["eu-west-1"]
```

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | ~> 3.16.0 |
| okta | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.16.0 |
| aws.audit | ~> 3.16.0 |
| aws.logging | ~> 3.16.0 |
| okta | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_sso\_acs\_url | AWS SSO ACS URL for the Okta App | `string` | n/a | yes |
| aws\_sso\_entity\_id | AWS SSO Entity ID for the Okta App | `string` | n/a | yes |
| control\_tower\_account\_ids | Control Tower core account IDs | <pre>object({<br>    audit   = string<br>    logging = string<br>  })</pre> | n/a | yes |
| tags | Map of tags | `map` | n/a | yes |
| additional\_auditing\_trail | CloudTrail configuration for additional auditing trail | <pre>object({<br>    name   = string<br>    bucket = string<br>  })</pre> | `null` | no |
| aws\_allowed\_regions | List of allowed AWS regions | `list(string)` | `null` | no |
| aws\_config | AWS Config settings | <pre>object({<br>    aggregator_account_ids = list(string)<br>    aggregator_regions     = list(string)<br>  })</pre> | `null` | no |
| aws\_guardduty | Whether AWS GuardDuty should be enabled | `bool` | `true` | no |
| aws\_okta\_group\_ids | List of Okta group IDs that should be assigned the AWS SSO Okta app | `list` | `[]` | no |
| datadog | Datadog integration options for the core accounts | <pre>object({<br>    api_key               = string<br>    enable_integration    = bool<br>    install_log_forwarder = bool<br>  })</pre> | `null` | no |
| monitor\_iam\_access | List of IAM Identities that should have their access monitored | <pre>list(object({<br>    account = string<br>    name    = string<br>    type    = string<br>  }))</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| kms\_key\_arn | ARN of KMS key for SSM encryption |
| kms\_key\_id | ID of KMS key for SSM encryption |
| monitor\_iam\_access\_sns\_topic\_arn | ARN of the SNS Topic in the Audit account for IAM access monitoring notifications |

<!--- END_TF_DOCS --->
