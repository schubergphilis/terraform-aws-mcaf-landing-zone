# Upgrading to 0.10.x

Version `0.10.x` adds the possibility of assigning the same SSO Permission Set to different groups of accounts and SSO Groups. For example, the permission set `Administrator` can be assigned to group A for account 123 and for group B for account 456.

This required changing the variable `aws_sso_permission_sets` where the `accounts` attribute was renamed to `assignments` and changed to a list.

# Upgrading to 0.9.x

Removal of the local AVM module. Modify the source to the new [MCAF Account Vending Machine (AVM) module](https://github.com/schubergphilis/terraform-aws-mcaf-avm).

The following variables have been renamed:
- `sns_aws_config_subscription` -> `aws_config_sns_subscription`
- `security_hub_product_arns` -> `aws_security_hub_product_arns`
- `sns_aws_security_hub_subscription` -> `aws_security_hub_sns_subscription`
- `sns_monitor_iam_activity_subscription` -> `monitor_iam_activity_sns_subscription`

The following variable has been removed:
- `aws_create_account_password_policy`, if you do not want to enable the password policy set the `aws_account_password_policy` variable to `null`

The provider alias has changed. Change the following occurence for all accounts, as shown below for the `sandbox` AVM module instance.

```shell
module.sandbox.provider[\"registry.terraform.io/hashicorp/aws\"].managed_by_inception => module.sandbox.provider[\"registry.terraform.io/hashicorp/aws\"].account
```

Moreover, resources in the AVM module are now stored under `module.tfe_workspace[0]`, resulting in a plan wanting to destroy and recreate the existing Terraform Cloud workspace and IAM user used by the workspace which is undesirable.

To prevent this happening, simply move the resources in the state to their new location as shown below for the `sandbox` AVM module instance:

```shell
terraform state mv 'module.sandbox.module.workspace[0]' 'module.sandbox.module.tfe_workspace[0]'
```

Finally, if you are migrating to the [MCAF Account Baseline module](https://github.com/schubergphilis/terraform-aws-mcaf-account-baseline) as well. Then remove the following resources from the state and let these resource be managed by the baseline workspaces. Command shown below for the `sandbox` AVM module instance

```shell
terraform state mv -state-out=baseline-sandbox.tfstate 'module.sandbox.aws_cloudwatch_log_metric_filter.iam_activity' 'module.account_baseline.aws_cloudwatch_log_metric_filter.iam_activity'
terraform state mv -state-out=baseline-sandbox.tfstate 'module.sandbox.aws_cloudwatch_metric_alarm.iam_activity' 'module.account_baseline.aws_cloudwatch_metric_alarm.iam_activity'
terraform state mv -state-out=baseline-sandbox.tfstate 'module.sandbox.aws_iam_account_password_policy.default' 'module.account_baseline.aws_iam_account_password_policy.default'
terraform state mv -state-out=baseline-sandbox.tfstate 'module.sandbox.aws_ebs_encryption_by_default.default' 'module.account_baseline.aws_ebs_encryption_by_default.default'
```


# Upgrading to 0.8.x

Version `0.8.x` introduces the possibility of managing AWS SSO resources using this module. To avoid a race condition between Okta pushing groups to AWS SSO and Terraform trying to read them using data sources, the `okta_app_saml` resource has been removed from the module.

With this change, all Okta configuration can be managed in the way that best suits the user. It also makes it possible to use this module with any other identity provider that is able to create groups on AWS SSO.

# Upgrading to 0.7.x

From version `0.7.0`, the monitoring of IAM entities has changed from Event Bridge Rules to CloudWatch Alarms. This means that passing a list of IAM identities to the variable `monitor_iam_access` is no longer supported.

The name of the SNS Topic used for notifications has also changed from `LandingZone-MonitorIAMAccess` to `LandingZone-IAMActivity`. Since this is a new Topic, all pre-existing SNS Subscriptions should be configured again using the variable `sns_monitor_iam_activity_subscription`.

# Upgrading to 0.5.x

Since the `create_workspace` variable was added to the AVM module, resources in the included [terraform-aws-mcaf-workspace](https://github.com/schubergphilis/terraform-aws-mcaf-workspace) module are now stored under `module.workspace[0]`, resulting in a plan wanting to destroy and recreate the existing Terraform Cloud workspace and IAM user used by the workspace which is undesirable.

To prevent this happening, simply move the resources in the state to their new location as shown below for the `sandbox` AVM module instance:

```shell
terraform state mv 'module.sandbox.module.workspace' 'module.sandbox.module.workspace[0]'
```

# Upgrading from v0.1.x to v0.2.x

This section describes changes to be aware of when upgrading from v0.1.x to v0.2.x.

## Enhancements

### AWS Config Aggregator Accounts

Since version `0.2.x` supports multiple account IDs when configuring AWS Config Aggregator accounts, the identifier given to the multiple `aws_config_aggregate_authorization` resources had to change from `region_name` to `account_id-region_name`. This causes the authorizations created by version `0.1.x` to be destroyed and recreated with the new identifiers.

### AWS GuardDuty

In order to enable GuardDuty for the entire organization, all existing accounts except for the `master` and `logging` accounts have to be add as members in the `audit` account like explained [here](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_organizations.html#guardduty_add_orgs_accounts). If this step is not taken, only the core accounts will have GuardDuty enabled.

### TFE Workspaces

TFE Workspaces use version [0.3.0 of the terraform-aws-mcaf-workspace](https://github.com/schubergphilis/terraform-aws-mcaf-workspace/tree/v0.3.0) module which by default creates a Terraform backend file in the repository associated with the workspace.
