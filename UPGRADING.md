# Upgrading to 0.20.x

Resources managing permission sets in AWS IAM Identity Center have been moved to a sub-module, meaning you will need to create `moved` blocks to update the state. The user interface remains unchanged.

To move the resources to their new locations in the state, create a `moved.tf` in your workspace and add the following for each managed permission set (assuming your module is called `landing_zone`):

```hcl
moved {
  from = module.landing_zone.aws_ssoadmin_permission_set.default["<< PERMISSION SET NAME >>"]
  to   = module.landing_zone.module.aws_sso_permission_sets["<< PERMISSION SET NAME >>"].aws_ssoadmin_permission_set.default[0]
}

moved {
  from = module.landing_zone.aws_ssoadmin_permission_set_inline_policy.default["<< PERMISSION SET NAME >>"]
  to   = module.landing_zone.module.aws_sso_permission_sets["<< PERMISSION SET NAME >>"].aws_ssoadmin_permission_set_inline_policy.default[0]
}
```

Example, if you have a "PlatformAdmin" permission set:

```hcl
moved {
  from = module.landing_zone.aws_ssoadmin_permission_set.default["PlatformAdmin"]
  to   = module.landing_zone.module.aws_sso_permission_sets["PlatformAdmin"].aws_ssoadmin_permission_set.default[0]
}

moved {
  from = module.landing_zone.aws_ssoadmin_permission_set_inline_policy.default["PlatformAdmin"]
  to   = module.landing_zone.module.aws_sso_permission_sets["PlatformAdmin"].aws_ssoadmin_permission_set_inline_policy.default[0]
}
```

For each permission set assignment, add the following block and substitute the placeholders:

```hcl
moved {
  from = module.landing_zone.aws_ssoadmin_account_assignment.default["<< SSO GROUP NAME >>-<< AWS ACCOUNT ID >>-<< PERMISSION SET NAME >>"
  to   = module.landing_zone.module.aws_sso_permission_sets["PlatformAdmin"].aws_ssoadmin_account_assignment.default["<< SSO GROUP NAME >>:<< AWS ACCOUNT ID >>"]
}
```

Example:

```hcl
moved {
  from = module.landing_zone.aws_ssoadmin_account_assignment.default["PlatformAdminTeam-123456789012-PlatformAdmin"]
  to   = module.landing_zone.module.aws_sso_permission_sets["PlatformAdmin"].aws_ssoadmin_account_assignment.default["PlatformAdminTeam:123456789012"]
}
```

Repeat adding these `moved` blocks until `terraform plan` doesn't report any planned changed.

This version requires Terraform 1.3 or newer

# Upgrading to 0.19.x

Be aware that all tag policies will be recreated since they are now created per tag policy instead of per OU.

# Upgrading to 0.18.x

Version 0.18.x allows Tag Policies on nested Organizational units. Therefore the variable `aws_required_tags` needs the Organizational unit paths including 'Root', e.g.:

```hcl
module "landing_zone" {
  ...

  aws_required_tags = {
    "Root/Production" = [
      {
        name   = "Tag1"
        values = ["A", "B"]
      }
    ]
    "Root/Environments/Non-Production" = [
      {
        name   = "Tag2"
      }
    ]
  }
```

# Upgrading to 0.17.x

The following variables are now typed from string to list(string):

- `kms_key_policy`
- `kms_key_policy_audit`
- `kms_key_policy_logging`

The following default key policy has been removed from the audit KMS key and a more secure default has been provided:

```shell
 {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
          "AWS": [
            "arn:aws:iam::${audit_account_id}:root",
            "arn:aws:iam::${master_account_id}:root"
          ]
      },
      "Action": "kms:*",
      "Resource": "*"
    }
```

If this new key policy is too restrictive for your deployment add extra key policies statements using the `kms_key_policy_audit` variable.

# Upgrading to 0.16.x

Version `0.16` adds support for [AWS provider version 4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/version-4-upgrade)

Many parameters are removed from the `aws_s3_bucket` resource configuration, Terraform will not pick up on these changes on a subsequent terraform plan or terraform apply.

Please run the following commands before migrating to this version (assuming you have called the module `landing_zone`):

```shell
terraform import 'module.landing_zone.module.ses-root-accounts-mail-forward[0].module.s3_bucket.aws_s3_bucket_server_side_encryption_configuration.default' <bucket-name>

terraform import 'module.landing_zone.module.ses-root-accounts-mail-forward[0].module.s3_bucket.aws_s3_bucket_versioning.default' <bucket-name>

terraform import  'module.landing_zone.module.ses-root-accounts-mail-forward[0].module.s3_bucket.aws_s3_bucket_acl.default' <bucket-name>

terraform import 'module.landing_zone.module.ses-root-accounts-mail-forward[0].module.s3_bucket.aws_s3_bucket_policy.default' <bucket-name>

terraform import 'module.landing_zone.module.ses-root-accounts-mail-forward[0].module.s3_bucket.aws_s3_bucket_lifecycle_configuration.default[0]' <bucket-name>

```

# Upgrading to 0.15.x

Version `0.15` adds an optional mail forwarder using Amazon SES. Adding the `ses_root_accounts_mail_forward` variable creates the necessary resources to accept mail sent to a verified email address and forward it to an external recipient or recipients. Due to the usage of `configuration_aliases` in the provider configurations of some submodules, this module now requires to use Terraform version 1.0.0 or higher.

# Upgrading to 0.14.x

Version `0.14.x` introduces an account level S3 public access policy that blocks public access to all S3 buckets in the landing zone core accounts. Please make sure you have no S3 buckets that require public access in any of the landing zone core accounts before upgrading.

# Upgrading to 0.13.x

Version `0.13.x` adds support for managed policies. This required changing the variable `aws_sso_permission_sets` where each permission set now requires an additional field called `managed_policy_arns` which must be a list of strings or can be an empty list.

# Upgrading to 0.12.x

Version `0.12.x` automatically sets the audit account as security hub administrator account for the organization and automatically enables Security Hub for new accounts in the organization. In case you already configured this manually please import these resources:

```shell
terraform import aws_securityhub_organization_admin_account.default <account id of the master account>
terraform import aws_securityhub_organization_configuration.default <account id of the audit account>
```

# Upgrading to 0.11.x

Version `0.11.x` adds additional IAM activity monitors, these will be created automatically if you have the cis-aws-foundations-benchmark standard enabled. To disable the creation of these monitors set the variable `security_hub_create_cis_metric_filters` to false.

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
