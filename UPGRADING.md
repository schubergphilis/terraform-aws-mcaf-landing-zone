# Upgrading Notes

This document captures required refactoring on your part when upgrading to a module version that contains breaking changes.

## Upgrading to v5.0.0

### Key Changes

#### Transition to Centralized Security Hub Configuration

This version transitions Security Hub configuration from **Local** to **Central**. Learn more in the [AWS Security Hub Documentation](https://docs.aws.amazon.com/securityhub/latest/userguide/central-configuration-intro.html).

**Default Behavior:**

- Security Hub Findings Aggregation is enabled for regions defined in:
  - `regions.home_region`
  - `regions.linked_regions`. `us-east-1` is automatically included for global services.

#### Dropping Support for Local Configuration

**Local configurations are no longer supported.** Centralized configuration aligns with AWS best practices and reduces complexity.

### Variables

The following variables have been replaced:
* `aws_service_control_policies.allowed_regions` → `regions.allowed_regions`
* `aws_config.aggregator_regions` → the union of `regions.home_region` and `regions.linked_regions`

The following variables have been introduced:
* `aws_security_hub.aggregator_linking_mode`. Indicates whether to aggregate findings from all of the available Regions or from a specified list.
* `aws_security_hub.disabled_control_identifiers`. List of Security Hub control IDs that are disabled in the organisation.
* `aws_security_hub.enabled_control_identifiers`. List of Security Hub control IDs that are enabled in the organisation.

The following variables have been removed:
* `aws_security_hub.auto_enable_new_accounts`. This variable is not configurable anymore using security hub central configuration.
* `aws_security_hub.auto_enable_default_standards`. This variable is not configurable anymore using security hub central configuration.

### How to upgrade.

1. Verify Control Tower Governed Regions.

    Ensure your AWS Control Tower Landing Zone regions includes `us-east-1`.  

    To check:
    1. Log in to the **core-management account**.
    2. Navigate to **AWS Control Tower** → **Landing Zone Settings**.
    3. Confirm `us-east-1` is listed under **Landing Zone Regions**.

    If `us-east-1` is missing, update your AWS Control Tower settings **before upgrading**.

> [!NOTE]
> For more details on the `regions` variable, refer to the [Specifying the correct regions section in the readme](README.md).

2. Update the variables according to the variables section above. 

3. Manually Removing Local Security Hub Standards

    Previous versions managed `aws_securityhub_standards_subscription` resources locally in core accounts. These are now centrally configured using `aws_securityhub_configuration_policy`. **Terraform will attempt to remove these resources from the state**. To prevent disabling them, the resources must be manually removed from the Terraform state.

    *Steps to Remove Resources:*

    a. Generate Removal Commands. Run the following shell snippet:

    ```shell
    terraform init
    for local_standard in $(terraform state list | grep "module.landing_zone.aws_securityhub_standards_subscription"); do
      echo "terraform state rm '$local_standard'"
    done
    ```

    b. Execute Commands: Evaluate and run the generated statements. They will look like:

    ```shell
    terraform state rm 'module.landing_zone.aws_securityhub_standards_subscription.logging["arn:aws:securityhub:eu-central-1::standards/pci-dss/v/3.2.1"]'
    ...
    ```

    *Why Manual Removal is Required*

    Terraform cannot handle `for_each` loops in `removed` statements ([HashiCorp Issue #34439](https://github.com/hashicorp/terraform/issues/34439)). Therefore the resources created with a `for_each` loop on `local.security_hub_standards_arns` must be manually removed from the Terraform state to prevent unintended deletions.

4. Upgrade your mcaf-landing-zone module to v5.x.x. 

5. Upgrade your [mcaf-account-baseline](https://github.com/schubergphilis/terraform-aws-mcaf-account-baseline) deployments to v2.0.0 or higher. 

### Troubleshooting

#### Issue: AWS Security Hub control "AWS Config should be enabled and use the service-linked role for resource recording" fails for multiple accounts after upgrade

#### Resolution Steps

1. **Verify `regions.linked_regions`:**
   - Ensure that `regions.linked_regions` matches the AWS Control Tower Landing Zone regions.
   - For guidance, refer to the [Specifying the correct regions section in the README](README.md).

2. **Check Organizational Units (OUs):**
   - Log in to the **core-management account**.
   - Navigate to **AWS Control Tower** → **Organization**.
   - Confirm all OUs have the **Baseline state** set to `Succeeded`.

3. **Check Account Baseline States:**
   - In **AWS Control Tower** → **Organization**, verify that all accounts show a **Baseline state** of `Succeeded`.
   - If any accounts display `Update available`:
     - Select the account.
     - Go to **Actions** → **Update**.

4. **Allow Time for Changes to Propagate:**
   - Wait up to **24 hours** for updates to propagate and resolve the Security Hub findings.

If all steps are completed and the issue persists, review AWS Control Tower settings and logs for additional troubleshooting.

### Known Issues

**Issue:** The AWS Security Hub control "AWS Config should be enabled and use the service-linked role for resource recording" fails for the core-management account after the upgrade.

**Cause:** AWS Control Tower does not enable AWS Config in the core-management account. While this module enables AWS Config in the home region of the core-management account, it does not cover the linked regions.

**Workaround:** Suppress these findings or enable AWS Config yourself in the linked regions for the core-management account.


## Upgrading to v4.0.0

> [!WARNING]
> **Read the diagram in [PR 210](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/210) and the guide below! If you currently have EKS Runtime Monitoring enabled, you need to perform MANUAL steps after you have migrated to this version.** 

### Behaviour

Using the default `aws_guardduty` values:
* `EKS_RUNTIME_MONITORING` gets removed from the state (but not disabled)
* `RUNTIME_MONITORING` is enabled including `ECS_FARGATE_AGENT_MANAGEMENT`, `EC2_AGENT_MANAGEMENT`, and `EKS_ADDON_MANAGEMENT`.
* Minimum required AWS provider has been set to `v5.54.0`, and minimum required Terraform version has been set to `v1.6`.

### Variables

The following variables have been replaced:
* `aws_guardduty.eks_runtime_monitoring_status` -> `aws_guardduty.runtime_monitoring_status.enabled`
* `aws_guardduty.eks_addon_management_status` -> `aws_guardduty.runtime_monitoring_status.eks_addon_management_status`

The following variables have been introduced:
* `aws_guardduty.runtime_monitoring_status.ecs_fargate_agent_management_status`
* `aws_guardduty.runtime_monitoring_status.ec2_agent_management_status`

### EKS Runtime Monitoring to Runtime Monitoring migration

#### The issue
After you upgraded to this version. **RUNTIME_MONITORING is enabled. But  EKS_RUNTIME_MONITORING is not disabled** as is written in the [guardduty_detector_feature documentation](https://registry.terraform.io/providers/hashicorp/aws/5.68.0/docs/resources/guardduty_detector_feature): _Deleting this resource does not disable the detector feature, the resource in simply removed from state instead._

To prevent duplicated costs please **disable** EKS_RUNTIME_MONITORING manually after upgrading.

> [!IMPORTANT]
> Run all the commands with valid credentials in the AWS account where guardduty is delegated administrator. By default this is the **control tower audit** account. 
> It's not possible to execute these steps from the AWS Console as the EKS Runtime Monitoring protection plan has already been removed from the GUI. The only way to control this feature is via the CLI.

#### Step 1: get the GuardDuty detector id

```
aws guardduty list-detectors
```

Should display:

```
{
    "DetectorIds": [
        "12abc34d567e8fa901bc2d34e56789f0"
    ]
}
```

> [!IMPORTANT]
> Ensure you run this command in the right region! If GuardDuty is enabled in multiple regions then execute all steps for all enabled regions. 

#### Step 2: update the GuardDuty detector 

_Replace 12abc34d567e8fa901bc2d34e56789f0 with your own regional detector-id. Execute these commands in the audit account:_

```
aws guardduty update-detector --detector-id 12abc34d567e8fa901bc2d34e56789f0 --features '[{"Name" : "EKS_RUNTIME_MONITORING", "Status" : "DISABLED"}]'
```

#### Step 3: update the GuardDuty organization settings

Replace the `<<EXISTING_VALUE>>` with your current configuration for auto-enabling GuardDuty. By default this should be set to `ALL`.

```
aws guardduty update-organization-configuration --detector-id 12abc34d567e8fa901bc2d34e56789f0 --auto-enable-organization-members <<EXISTING_VALUE>>  --features '[{"Name" : "EKS_RUNTIME_MONITORING", "AutoEnable": "NONE"}]'
```


#### Step 4: update the GuardDuty member accounts

Disable EKS Runtime Monitoring for **all** member accounts in your organization, for example:

```
aws guardduty update-member-detectors --detector-id 12abc34d567e8fa901bc2d34e56789f0 --account-ids 111122223333 --features '[{"Name" : "EKS_RUNTIME_MONITORING", "Status" : "DISABLED"}]'
```

#### Troubleshooting

> An error occurred (BadRequestException) when calling the UpdateMemberDetectors operation: The request is rejected because a feature cannot be turned off for a member while organization has the feature flag set to 'All Accounts'.

Change these options on the AWS console by following the steps below: 

1. Go to the GuardDuty Console.
2. On left navigation bar, under protection plans, select `Runtime Monitoring`.
3. Under the `Configuration` tab, in `Runtime Monitoring configuration` click `Edit` and here you need to select the option `Configure accounts manually` for `Automated agent configuration - Amazon EKS`.

Once complete, please allow a minute for the changes to update, you should now be able to execute the command from step 3. When you have executed this command for all AWS accounts, set this option back to `Enable for all accounts`.

> Even after following all steps I still see the message `Your organization has auto-enable preferences set for EKS Runtime Monitoring. This feature has been removed from console experience and can now be managed as part of the Runtime Monitoring feature. Learn more`.

We have checked in with AWS and this behaviour is expected, this is a static message that is displayed currently on the AWS Management Console. AWS could not confirm how to hide this message or how long it will be visible.

#### Verification

Review the GuardDuty organization settings:

```
aws guardduty describe-organization-configuration --detector-id 12abc34d567e8fa901bc2d34e56789f0
```

Should display:

```
...
    "Features": [
...
        {
            "Name": "EKS_RUNTIME_MONITORING",
            "AutoEnable": "NONE",
            "AdditionalConfiguration": [
                {
                    "Name": "EKS_ADDON_MANAGEMENT",
                    "AutoEnable": "ALL"
                }
            ]
        },
...
```

Review the GuardDuty detector settings:

```
aws guardduty get-detector --detector-id 12abc34d567e8fa901bc2d34e56789f0
```

Should display:

```
...
 "Features": [
...
        {
            "Name": "EKS_RUNTIME_MONITORING",
            "Status": "DISABLED",
            "UpdatedAt": "2024-10-16T14:12:31+02:00",
            "AdditionalConfiguration": [
                {
                    "Name": "EKS_ADDON_MANAGEMENT",
                    "Status": "ENABLED",
                    "UpdatedAt": "2024-10-16T14:24:43+02:00"
                }
            ]
        },
...
```

> [!NOTE]
> If you want to be really sure all member accounts have the right settings you can run the `aws guardduty get-detector` for member accounts as well. Ensure you have valid credentials for the member account and replace the `detector-id` with the GuardDuty `detector-id` of the member account.

## Upgrading to v3.0.0

### Behaviour

This version add Control Tower 3.x support. Upgrade to Control Tower 3.x before upgrading to this version.

## Upgrading to v2.0.0

### Behaviour

This version sets the minimum required aws provider version from v4 to v5.

### Variables

The following variables have been replaced:
* `aws_guardduty.datasources.malware_protection` -> `aws_guardduty.ebs_malware_protection_status`
* `aws_guardduty.datasources.kubernetes` -> `aws_guardduty.eks_audit_logs_status`
* `aws_guardduty.datasources.s3_logs` -> `aws_guardduty.s3_data_events_status`

The following variables have been introduced:
* `aws_guardduty.eks_addon_management_status`
* `aws_guardduty.eks_runtime_monitoring_status`
* `aws_guardduty.lambda_network_logs_status`
* `aws_guardduty.rds_login_events_status`

## Upgrading to v1.0.0

### Behaviour

In previous versions of this module, `auto-enable default standards` was enabled by default. From v1.0.0 this behaviour has been changed to disabled by default (controlled via `var.aws_security_hub.auto_enable_default_standards`) since the default standards are not updated regularly enough.

At time of writing only the `AWS Foundational Security Best Practices v1.0.0 standard` and the `CIS AWS Foundations Benchmark v1.2.0` are enabled by [by default](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-enable-disable.html) while this module enables the following standards:

- `AWS Foundational Security Best Practices v1.0.0`
- `CIS AWS Foundations Benchmark v1.4.0`
- `PCI DSS v3.2.1`

The enabling of the standards in all member account is now controlled via [mcaf-account-baseline](https://github.com/schubergphilis/terraform-aws-mcaf-account-baseline).

### Variables

The following variables have been replaced by a new variable `aws_security_hub`:

- `aws_security_hub_product_arns` -> `aws_security_hub.product_arns`
- `security_hub_standards_arns` -> `aws_security_hub.standards_arns`
- `security_hub_create_cis_metric_filters` -> `aws_security_hub.create_cis_metric_filters`

## Upgrading to v0.25.x

Version `0.25.x` has added support for specifying a kms_key_id in the `var.additional_auditing_trail`. This variable is mandatory, if you already have additional cloudtrail configurations created using this variable encryption is now mandatory.

```hcl
module "landing_zone"
...
  additional_auditing_trail = {
    name       = "audit-trail-name"
    bucket     = "audit-trail-s3-bucket-name"
    kms_key_id = "arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
  }
...
}
```

## Upgrading to v0.24.x

Version `0.24.x` changes the AWS nested providers to provider aliases. Define the providers outside the module and reference them when calling this module. For an example, see `examples/basic`.

## Upgrading to v0.23.x

Version `0.23.x` introduces a change in behaviour of AWS Config:

- By default the `aggregator_regions` were set to eu-west-1 and eu-central-1, this has been changed to only enable the current region. Provide a list of regions to `var.aws_config.aggregator_regions` if you want to enable AWS Config in multiple regions.
- Previously the `aws-controltower-logs` bucket was used to store CloudTrail and AWS Config logs, this version introduces a separate bucket for AWS Config. You are able to override the bucket name by setting `var.aws_config.delivery_channel_s3_bucket_name`.

## Upgrading to v0.21.x

Version `0.21.x` introduces exceptions for IAM entities on the `DenyDisablingSecurityHub` and `DenyLeavingOrg` SCP. The following variables have been merged into a new variable `aws_service_control_policies`:

- `aws_deny_disabling_security_hub`
- `aws_deny_leaving_org`
- `aws_deny_root_user_ous`
- `aws_region_restrictions`
- `aws_require_imdsv2`

## Upgrading to v0.20.x

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

This version requires Terraform 1.3 or newer.

## Upgrading to v0.19.x

Be aware that all tag policies will be recreated since they are now created per tag policy instead of per OU.

## Upgrading to v0.18.x

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

## Upgrading to v0.17.x

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

## Upgrading to v0.16.x

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

## Upgrading to v0.15.x

Version `0.15` adds an optional mail forwarder using Amazon SES. Adding the `ses_root_accounts_mail_forward` variable creates the necessary resources to accept mail sent to a verified email address and forward it to an external recipient or recipients. Due to the usage of `configuration_aliases` in the provider configurations of some submodules, this module now requires to use Terraform version 1.0.0 or higher.

## Upgrading to v0.14.x

Version `0.14.x` introduces an account level S3 public access policy that blocks public access to all S3 buckets in the landing zone core accounts. Please make sure you have no S3 buckets that require public access in any of the landing zone core accounts before upgrading.

## Upgrading to v0.13.x

Version `0.13.x` adds support for managed policies. This required changing the variable `aws_sso_permission_sets` where each permission set now requires an additional field called `managed_policy_arns` which must be a list of strings or can be an empty list.

## Upgrading to v0.12.x

Version `0.12.x` automatically sets the audit account as security hub administrator account for the organization and automatically enables Security Hub for new accounts in the organization. In case you already configured this manually please import these resources:

```shell
terraform import aws_securityhub_organization_admin_account.default <account id of the master account>
terraform import aws_securityhub_organization_configuration.default <account id of the audit account>
```

## Upgrading to v0.11.x

Version `0.11.x` adds additional IAM activity monitors, these will be created automatically if you have the cis-aws-foundations-benchmark standard enabled. To disable the creation of these monitors set the variable `security_hub_create_cis_metric_filters` to false.

## Upgrading to v0.10.x

Version `0.10.x` adds the possibility of assigning the same SSO Permission Set to different groups of accounts and SSO Groups. For example, the permission set `Administrator` can be assigned to group A for account 123 and for group B for account 456.

This required changing the variable `aws_sso_permission_sets` where the `accounts` attribute was renamed to `assignments` and changed to a list.

## Upgrading to v0.9.x

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

## Upgrading to v0.8.x

Version `0.8.x` introduces the possibility of managing AWS SSO resources using this module. To avoid a race condition between Okta pushing groups to AWS SSO and Terraform trying to read them using data sources, the `okta_app_saml` resource has been removed from the module.

With this change, all Okta configuration can be managed in the way that best suits the user. It also makes it possible to use this module with any other identity provider that is able to create groups on AWS SSO.

## Upgrading to v0.7.x

From version `0.7.0`, the monitoring of IAM entities has changed from Event Bridge Rules to CloudWatch Alarms. This means that passing a list of IAM identities to the variable `monitor_iam_access` is no longer supported.

The name of the SNS Topic used for notifications has also changed from `LandingZone-MonitorIAMAccess` to `LandingZone-IAMActivity`. Since this is a new Topic, all pre-existing SNS Subscriptions should be configured again using the variable `sns_monitor_iam_activity_subscription`.

## Upgrading to v0.5.x

Since the `create_workspace` variable was added to the AVM module, resources in the included [terraform-aws-mcaf-workspace](https://github.com/schubergphilis/terraform-aws-mcaf-workspace) module are now stored under `module.workspace[0]`, resulting in a plan wanting to destroy and recreate the existing Terraform Cloud workspace and IAM user used by the workspace which is undesirable.

To prevent this happening, simply move the resources in the state to their new location as shown below for the `sandbox` AVM module instance:

```shell
terraform state mv 'module.sandbox.module.workspace' 'module.sandbox.module.workspace[0]'
```

## Upgrading from v0.1.x to v0.2.x

This section describes changes to be aware of when upgrading from v0.1.x to v0.2.x.

### Enhancements

#### AWS Config Aggregator Accounts

Since version `0.2.x` supports multiple account IDs when configuring AWS Config Aggregator accounts, the identifier given to the multiple `aws_config_aggregate_authorization` resources had to change from `region_name` to `account_id-region_name`. This causes the authorizations created by version `0.1.x` to be destroyed and recreated with the new identifiers.

#### AWS GuardDuty

In order to enable GuardDuty for the entire organization, all existing accounts except for the `master` and `logging` accounts have to be add as members in the `audit` account like explained [here](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_organizations.html#guardduty_add_orgs_accounts). If this step is not taken, only the core accounts will have GuardDuty enabled.

#### TFE Workspaces

TFE Workspaces use version [0.3.0 of the terraform-aws-mcaf-workspace](https://github.com/schubergphilis/terraform-aws-mcaf-workspace/tree/v0.3.0) module which by default creates a Terraform backend file in the repository associated with the workspace.
