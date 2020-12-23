# AWS AVM (Account Vending Machine)

Terraform module to provision an AWS account with a TFE workspace backed by a VCS project.

Overview of Account setup: 

<img src="../../images/MCAF_landing_zone_account_setup_v040.png" width="800"> 

## AWS Config Rules

If you would like to authorize other accounts to aggregate AWS Config data, the account IDs and regions can be passed via the variable `aws_config` using the attributes `aggregator_account_ids` and `aggregator_regions` respectively.

NOTE: Control Tower already authorizes the `audit` account to aggregate Config data from all other accounts in the organization, so there is no need to specify the `audit` account ID in the `aggregator_account_ids` list.

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
- `site_url`: set to `datadoghq.com` for US region or `datadoghq.eu` for EU region [Datadog Forwarder](https://docs.datadoghq.com/serverless/forwarder/)

In case you don't want to use the integration, you can configure the Datadog provider like in the example below:

```hcl
provider "datadog" {
  validate = false
}
```

This should prevent the provider from asking you for a Datadog API Key and allow the module to be provisioned without the integration resources.

## Monitoring IAM Access

This module offers the capability of monitoring IAM activity of both users and roles. To enable this feature, you have to provide the ARN of the EventBridge Event Bus that should receive events in case any activity is detected.

The event bus ARN can be set using the attribute `event_bus_arn` in the variable `monitor_iam_access`. In case the feature is enabled, the activity of the `root` user will be automatically monitored and reported.

If you would like to monitor other users or roles, a list can be passed using the attribute `identities` in the variable `monitor_iam_access`. All objects in the list should have the attributes `name` and `type` where `name` is either the name of the IAM Role or the IAM User and `type` is either `AssumedRole` or `IAMUser`. 

For more details regarding identities, please check [this link](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-event-reference-user-identity.html).

NOTE: Data Sources will be used to make sure that the identities provided actually exist in the account to avoid monitoring non-existent resources. In case an invalid identity is provided, a `NoSuchEntity` error will be thrown. 

Example:

```hcl
monitor_iam_access = {
  event_bus_arn = aws_cloudwatch_event_bus.monitor_iam_access.arn
  identities    = [
    {
      name = "AWSReservedSSO_AWSAdministratorAccess_123abc"
      type = "AssumedRole"
    }
  ]
}
```

<!--- BEGIN_TF_DOCS --->
Error: Function calls not allowed: Functions may not be called here.

<!--- END_TF_DOCS --->
