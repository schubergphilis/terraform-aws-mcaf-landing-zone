# terraform-aws-mcaf-landing-zone

Terraform module to setup and manage various components of the SBP AWS Landing Zone.

Overview of Landing Zone tools & services:

<img src="images/MCAF_landing_zone_tools_and_services_v040.png" width="600">

The SBP AWS Landing Zone consists of 3 repositories:

- [MCAF Landing Zone module (current repository)](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone): the foundation of the Landing Zone and manages the 3 core accounts: audit, logging, management
- [MCAF Account Vending Machine (AVM) module](https://github.com/schubergphilis/terraform-aws-mcaf-avm): providing an AWS AVM. This module sets up an AWS account with one or more Terraform Cloud/Enterprise (TFE) workspace(s) backed by a VCS project
- [MCAF Account Baseline module](https://github.com/schubergphilis/terraform-aws-mcaf-account-baseline): optional module providing baseline configuration for AWS accounts

## Pre-Requisites

> [!IMPORTANT]
> Before deploying this module, ensure the following pre-requisites are met:
>
> - AWS Control Tower is deployed in the `core-management` account.
> - AWS Control Tower governed regions include at least `us-east-1` (and your designated home region).

## Basic configuration

Refer to [examples/basic](examples/basic/main.tf) for an example of minimal setup.

### Specifying the correct regions

**Home Region**

The mandatory `regions.home_region` variable specifies the AWS Control Tower home region. This must match the region defined in your AWS provider that deploys this module.

To find your home region:

1. Log in to the **core-management account**.
2. Navigate to **AWS Control Tower** → **Landing Zone Settings**.
3. The home region is listed under **Home Region**.

**Linked Regions**

The optional `regions.linked_regions` variable defines the AWS Control Tower governed regions. This module ensures proper configuration of AWS Security Hub and AWS Config for all specified linked regions to collect data from them.

To find your linked regions:

1. Log in to the **core-management account**.
2. Navigate to **AWS Control Tower** → **Landing Zone Settings**.
3. Linked regions are listed under **Landing Zone Regions**.

> [!NOTE]
> By default, `us-east-1` is included as a linked region to ensure data collection from global services. To restrict deployment of non-global resources in this region, use the `allowed_regions` functionality described in the section below.

> [!IMPORTANT]
> All specified linked regions need to be an AWS Control Tower governed region. This ensures that an AWS Config recorder is enabled by AWS Control Tower in all governed regions. AWS Security Hub will only function correctly if an AWS Config recorder exists in all linked regions.

**Allowed Regions**

The `regions.allowed_regions` variable defines the allowed regions within your AWS Organization. This triggers the deployment of a [Service Control Policy (SCP)](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps_examples.html#example-scp-deny-region), which is attached to the root of your AWS Organization.

**Additional per-region service action exceptions**

Sometimes you need to allow a handful of service actions in a region that you haven’t fully “opened up.” Use the variable:

```hcl
regions.additional_allowed_service_actions_per_region = {
  "<region-name>" = [ "<service-action-pattern>", … ]
}
``

for example:

```hcl
regions = {
...
    additional_allowed_service_actions_per_region = {
      "us-west-2" = ["dms:*"],
    }
  }
```

**Security Lake service action exception in us-east-1**

If you have enabled AWS Security Lake in the `us-east-1` region and have configured [Rollup regions](https://docs.aws.amazon.com/security-lake/latest/userguide/add-rollup-region.html), you may need to perform additional configuration steps to allow proper S3 replication. This is necessary to replicate objects from the Security Lake S3 bucket in `us-east-1` to a central bucket in the home region, as required by the rollup configuration.

Be default, the necessary actions for S3 replication are not present in the `DenyAllRegionsOutsideAllowedList` SCP statement. To resolve this, you should enable additional actions in this SCP statement by setting the following optional variable in your configuration:

```hcl
regions = {
...
    enable_security_lake_aggregation_service_actions = true,
  }
```

#### Configuration Scenarios

**Scenario 1: Home region only (no deployment in other regions)**

- **Home region:** `eu-central-1`
- **Requirement:** Prevent deployment in all other regions

You need to configure the `regions` variable as follows:

```hcl
regions = {
  allowed_regions = ["eu-central-1"]
  home_region     = "eu-central-1"
}
```

> [!NOTE]
> Ensure that `us-east-1` is included as a governed region in AWS Control Tower since the `linked_region` variable defaults to this value.

**Scenario 2: Home region with additional governed regions**

- **Home region:** `eu-central-1`
- **Requirement:** Also allow deploying resources in `eu-west-1`

You need to configure the `regions` variable as follows:

```hcl
regions = {
  allowed_regions = ["eu-central-1", "eu-west-1]
  home_region     = "eu-central-1"
  linked_regions = ["eu-west-1", "us-east-1"]
}
```

## Detailed configuration

### AWS SES Root Accounts mail forwarder

Setting the `ses_root_accounts_mail_forward` variable creates the necessary AWS Simple Email Service (SES) resources to accept mail sent to an AWS hosted domain and forward it to an external recipient or recipients. This can be used to enable secure mailboxes/IT service catalog aliases for all root accounts. Emails are received via AWS SES and forwarded to an email forwarder lambda which sends the email to the destination email server as specified in the `recipient_mapping` variable of `ses_root_accounts_mail_forward`.

Before setting the `ses_root_accounts_mail_forward` variable, make sure that an AWS Route53 hosted zone is created. For example aws.yourcompany.com. Pass this domain using the `domain` variable of `ses_root_accounts_mail_forward`.

Example:

```hcl
ses_root_accounts_mail_forward = {
  domain     = "aws.yourcompany.com"
  from_email = "root@aws.yourcompany.com"

  recipient_mapping = {
    "root@aws.yourcompany.com" = [
      "inbox@yourcompany.com"
    ]
  }
}
```

By default, you have to create the email addresses for the accounts created using the [MCAF Account Vending Machine (AVM) module](https://github.com/schubergphilis/terraform-aws-mcaf-avm) yourself. Using this functionality you can pass aliases of the mailbox created. E.g. root+\<account-name\>@aws.yourcompany.com.

### AWS CloudTrail

By default, all CloudTrail logs will be stored in a S3 bucket in the `logging` account of your AWS Organization. However, this module also supports creating an additional CloudTrail configuration to publish logs to any S3 bucket chosen by you. This trail will be set at the Organization level, meaning that logs from all accounts will be published to the provided bucket.

> [!NOTE]
> Before enabling this feature, make sure that the [bucket policy authorizing CloudTrail to deliver logs](https://aws.amazon.com/premiumsupport/knowledge-center/change-cloudtrail-trail/) is in place and that you have enabled [trusted access between AWS Organizations and CloudTrail](https://docs.aws.amazon.com/organizations/latest/userguide/services-that-can-integrate-cloudtrail.html#integrate-enable-ta-cloudtrail). If these two steps are not in place, Terraform will fail to create the trail.

Example:

```hcl
additional_auditing_trail = {
  name   = "additional_auditing_trail"
  bucket = "bucket_name"
}
```

### AWS Config Rules

This module provisions by default a set of basic AWS Config Rules. In order to add extra rules, a list of [rule identifiers](https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html) can be passed via the variable `aws_config.rule_identifiers`.

If you would like to authorize other accounts to aggregate AWS Config data, the account IDs can also be passed via the variable `aws_config.aggregator_account_ids`.

> [!NOTE]
> This module already authorizes the `audit` account to aggregate Config data from all other accounts in the organization, so there is no need to specify the `audit` account ID in the `aggregator_account_ids` list.

Example:

```hcl
aws_config = {
  aggregator_account_ids = ["123456789012"]
  rule_identifiers       = ["ACCESS_KEYS_ROTATED", "ALB_WAF_ENABLED"]
}
```

### AWS GuardDuty

This module supports enabling GuardDuty at the organization level which means that all new accounts that are created in, or added to, the organization are added as member accounts to the `audit` account GuardDuty detector.

The feature can be controlled via the `aws_guardduty` variable and is enabled by default.

Note: In case you are migrating an existing AWS organization to this module, all existing accounts except for the `management` and `logging` accounts have to be enabled like explained [here](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_organizations.html#guardduty_add_orgs_accounts).

## AWS KMS

The module creates 3 AWS KMS keys, one for the management account, one for the audit account, and one for the log archive account. We recommend to further scope down the AWS KMS key policy in the management account by providing a secure policy using `kms_key_policy`. The default policy "Base Permissions" can be overwritten and should be limited to the root account only, for example by using the statement below:

```hcl
  statement {
    sid       = "Base Permissions"
    actions   = ["kms:*"]
    effect    = "Allow"
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalType"
      values   = ["Account"]
    }

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.management.account_id}:root"
      ]
    }
  }
```

Note that you have to add additional policies allowing for example access to the pipeline user or role. Only applying this policy will result in a `The new key policy will not allow you to update the key policy in the future` exception.

### AWS Security Hub

This module supports enabling Security Hub at an organization level, meaning all accounts that are created in or enrolled to the organization will be added as member accounts to the `audit` account Security Hub delegated administrator.

The feature can be controlled via the `aws_security_hub` variable and is enabled by default.

Note: by default `auto-enable default standards` has been turned off since the default standards are not updated regularly enough. At time of writing only the `AWS Foundational Security Best Practices v1.0.0 standard` and the `CIS AWS Foundations Benchmark v1.2.0 standard` are enabled by [by default](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-enable-disable.html) while this module enables the following standards:

- `AWS Foundational Security Best Practices v1.0.0`
- `CIS AWS Foundations Benchmark v1.4.0`
- `PCI DSS v3.2.1`

The enabling of the standards in all member account is controlled via [mcaf-account-baseline](https://github.com/schubergphilis/terraform-aws-mcaf-account-baseline).

### AWS SSO

This module supports managing AWS SSO resources to control user access to all accounts belonging to the AWS Organization.

This feature can be controlled via the `aws_sso_permission_sets` variable by passing a map (key-value pair) where every key corresponds to an AWS SSO Permission Set name and the value follows the structure below:

- `assignments`: list of objects, where each object represents an AWS account with its `account_id`, `account_name`, and a list of AWS SSO Group names (`sso_groups`) that should have access to the account using the defined permission set
- `inline_policy`: valid IAM policy in JSON format (maximum length of 10240 characters)
- `managed_policy_arns`: list of strings that contain the ARN's of the managed policies that should be attached to the permission set
- `session_duration`: length of time in the ISO-8601 standard

Example:

```hcl
  aws_sso_permission_sets = {
    PlatformAdmin = {
      inline_policy    = file("${path.module}/template_files/sso/platform_admin.json")
      session_duration = "PT2H"

      managed_policy_arns = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]

      assignments = [
        for account in [
          { id = "123456789012", name = "ProductionAccount" },
          { id = "012456789012", name = "DevelopmentAccount" }
        ] : {
          account_id   = account.id
          account_name = account.name
          sso_groups   = [okta_group.aws["AWSPlatformAdmins"].name]
        }
      ]
    }
    PlatformUser = {
      session_duration = "PT12H"

      managed_policy_arns = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess",
        "arn:aws:iam::aws:policy/AWSSupportAccess"
      ]

      assignments = [
        for account in [
          { id = "123456789012", name = "ProductionAccount" },
          { id = "012456789012", name = "DevelopmentAccount" },
        ] : {
          account_id   = account.id
          account_name = account.name
          sso_groups   = [okta_group.aws["AWSPlatformAdmins"].name, okta_group.aws["AWSPlatformUsers"].name]
        }
      ]

      inline_policy = jsonencode(
        {
          Version = "2012-10-17",
          Statement = concat(
            [
              {
                Effect   = "Allow",
                Action   = "support:*",
                Resource = "*"
              }
            ],
            jsondecode(data.aws_iam_policy.lambda_readonly.policy).Statement
          )
        }
      )
    }
  }
```

### Datadog Integration

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

### Monitoring IAM Activity

By default, this module monitors and notifies activities performed by the `root` user of all core accounts and AWS SSO Roles. All notifications will be sent to the SNS Topic `LandingZone-IAMActivity` in the `audit` account.

These are the type of events that will be monitored:

- Any activity made by the root user of the account.
- Any manual changes made by AWS SSO roles (read-only operations and console logins are not taken into account).

In case you would like to disable this functionality, you can set the variable `monitor_iam_activity` to `false`.

### Organizations Policies: Service Control Policies (SCPs)

Service control policies (SCPs) are a type of organization policy that you can use to manage permissions in your organization. See [this page](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html) for an introduction to SCPs and the value they add.

This module allows using various SCPs as described below. We try to adhere to best practices of not attaching SCPs to the root of the organization when possible; in the event you need to pass a list of OU names, be sure to have the exact name as the matching is case sensitive.

#### SCP: Deny ability to disable Security Hub

Enabling this SCP removes a member account's ability to disable Security Hub.

This is SCP is enabled by default, but can be disabled by setting `aws_deny_disabling_security_hub` attribute to `false` in `aws_service_control_policies`.

Example:

```hcl
aws_service_control_policies = {
  aws_deny_disabling_security_hub = false
}
```

#### SCP: Deny ability to leave Organization

Enabling this SCP removes a member account's ability to leave the AWS organization.

This is SCP is enabled by default, but can be disabled by setting `aws_deny_leaving_org` attribute to `false` in `aws_service_control_policies`.

Example:

```hcl
aws_service_control_policies = {
  aws_deny_leaving_org = false
}
```

#### SCP: Require the use of Instance Metadata Service Version 2

By default, all EC2s still allow access to the original metadata service, which means that if an attacker finds an EC2 running a proxy or WAF, or finds and SSRF vulnerability, they likely can steal the IAM role of the EC2. By enforcing IMDSv2, you can mitigate that risk. Be aware that this potentially could break some applications that have not yet been updated to work with the new IMDSv2.

This is SCP is enabled by default, but can be disabled by setting `aws_require_imdsv2` attribute to `false` in `aws_service_control_policies`.

Example:

```hcl
aws_service_control_policies = {
  aws_require_imdsv2 = false
}
```

#### SCP: Restricting AWS Regions

See the section `Specifying the correct regions`.

#### SCP: Restricting Root User Access

If you would like to restrict the root user's ability to log into accounts in an OU, you can pass a list of OU names to the `aws_deny_root_user_ous` attribute in `aws_service_control_policies`.

Example showing SCP applied to all OUs except the Root OU:

```hcl
data "aws_organizations_organization" "default" {}

data "aws_organizations_organizational_units" "default" {
  parent_id = data.aws_organizations_organization.default.roots[0].id
}

module "landing_zone" {
  ...
  aws_service_control_policies {
    aws_deny_root_user_ous = [
      for ou in data.aws_organizations_organizational_units.default.children : ou.name if ou.name != "Root"
    ]
  }

```

#### AWS Principal exceptions

In case you would like to exempt specific IAM entities from the [region restriction](#restricting-aws-regions), [leave the AWS organization](#deny-ability-to-leave-organization) and from the [ability to disable Security Hub](#deny-ability-to-disable-security-hub) SCP's, you can pass a list of ARN patterns using the `principal_exceptions` attribute in `aws_service_control_policies`. This can be useful for roles used by AWS ControlTower, for example.
Example:

```hcl
aws_service_control_policies = {
  principal_exceptions = ["arn:aws:iam::*:role/RoleAllowedToBypassRestrictions"]
}
```

### Organizations Policies: Tag Policies

Tag policies are a type of policy that can help you standardize tags across resources in your organization's accounts. In a tag policy, you specify tagging rules applicable to resources when they are tagged. See [this page](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_tag-policies.html) for an introduction to tag policies and the value they add.

To create a tag policy, set the `aws_required_tags` variable using a map of OU names and their tag policies. To enforce a tag for all [services and resource types that support enforcement](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_supported-resources-enforcement.html), set `enforced_for` to `["all"]`.

Please note the OU path key is case sensitive and tag policies will be created per tag key.

Example:

```hcl
module "landing_zone" {
  ...

  aws_required_tags = {
    "Root/Environments/Production" = [
      {
        name         = "Tag1"
        values       = ["A", "B"]
        enforced_for = ["all"]
      }
    ]
    "Root/Environments/Non-Production" = [
      {
        name         = "Tag2"
        enforced_for = ["secretsmanager:*"]
      }
    ]
  }
}
```

### SNS topic subscription

| Topic Name                                        | Variable                                | Content                             |
| ------------------------------------------------- | --------------------------------------- | ----------------------------------- |
| `aws-controltower-AggregateSecurityNotifications` | `aws_config_sns_subscription`           | Aggregated AWS Config notifications |
| `LandingZone-SecurityHubFindings`                 | `aws_security_hub_sns_subscription`     | Aggregated Security Hub findings    |
| `LandingZone-IAMActivity`                         | `monitor_iam_activity_sns_subscription` | IAM activity findings               |

Example for https protocol and specified webhook endpoint:

```hcl
module "landing_zone" {
  ...

  aws_config_sns_subscription = {
    endpoint = "https://app.datadoghq.com/intake/webhook/sns?api_key=qwerty0123456789"
    protocol = "https"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.7.0 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | >= 3.39 |
| <a name="requirement_mcaf"></a> [mcaf](#requirement\_mcaf) | >= 0.4.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.7.0 |
| <a name="provider_aws.audit"></a> [aws.audit](#provider\_aws.audit) | >= 6.7.0 |
| <a name="provider_aws.logging"></a> [aws.logging](#provider\_aws.logging) | >= 6.7.0 |
| <a name="provider_mcaf"></a> [mcaf](#provider\_mcaf) | >= 0.4.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_audit_manager_reports"></a> [audit\_manager\_reports](#module\_audit\_manager\_reports) | schubergphilis/mcaf-s3/aws | ~> 0.14.1 |
| <a name="module_aws_config_recorder"></a> [aws\_config\_recorder](#module\_aws\_config\_recorder) | ./modules/aws-config-recorder | n/a |
| <a name="module_aws_config_s3"></a> [aws\_config\_s3](#module\_aws\_config\_s3) | schubergphilis/mcaf-s3/aws | ~> 0.14.1 |
| <a name="module_aws_sso_permission_sets"></a> [aws\_sso\_permission\_sets](#module\_aws\_sso\_permission\_sets) | ./modules/permission-set | n/a |
| <a name="module_datadog_audit"></a> [datadog\_audit](#module\_datadog\_audit) | schubergphilis/mcaf-datadog/aws | ~> 0.9.0 |
| <a name="module_datadog_logging"></a> [datadog\_logging](#module\_datadog\_logging) | schubergphilis/mcaf-datadog/aws | ~> 0.9.0 |
| <a name="module_datadog_master"></a> [datadog\_master](#module\_datadog\_master) | schubergphilis/mcaf-datadog/aws | ~> 0.9.0 |
| <a name="module_guardduty"></a> [guardduty](#module\_guardduty) | ./modules/guardduty | n/a |
| <a name="module_inspector"></a> [inspector](#module\_inspector) | ./modules/inspector | n/a |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | schubergphilis/mcaf-kms/aws | ~> 0.3.0 |
| <a name="module_kms_key_audit"></a> [kms\_key\_audit](#module\_kms\_key\_audit) | schubergphilis/mcaf-kms/aws | ~> 0.3.0 |
| <a name="module_kms_key_logging"></a> [kms\_key\_logging](#module\_kms\_key\_logging) | schubergphilis/mcaf-kms/aws | ~> 0.3.0 |
| <a name="module_security_baseline_audit"></a> [security\_baseline\_audit](#module\_security\_baseline\_audit) | ./modules/security-baseline | n/a |
| <a name="module_security_baseline_logging"></a> [security\_baseline\_logging](#module\_security\_baseline\_logging) | ./modules/security-baseline | n/a |
| <a name="module_security_baseline_master"></a> [security\_baseline\_master](#module\_security\_baseline\_master) | ./modules/security-baseline | n/a |
| <a name="module_ses-root-accounts-mail-alias"></a> [ses-root-accounts-mail-alias](#module\_ses-root-accounts-mail-alias) | schubergphilis/mcaf-ses/aws | ~> 1.0.0 |
| <a name="module_ses-root-accounts-mail-forward"></a> [ses-root-accounts-mail-forward](#module\_ses-root-accounts-mail-forward) | schubergphilis/mcaf-ses-forwarder/aws | ~> 1.0.0 |
| <a name="module_tag_policy_assignment"></a> [tag\_policy\_assignment](#module\_tag\_policy\_assignment) | ./modules/tag-policy-assignment | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_auditmanager_account_registration.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/auditmanager_account_registration) | resource |
| [aws_cloudtrail.additional_auditing_trail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_cloudwatch_event_rule.security_hub_findings](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.security_hub_findings](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_metric_filter.iam_activity_master](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_metric_alarm.iam_activity_master](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_config_aggregate_authorization.audit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_aggregate_authorization) | resource |
| [aws_config_aggregate_authorization.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_aggregate_authorization) | resource |
| [aws_config_aggregate_authorization.master](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_aggregate_authorization) | resource |
| [aws_config_aggregate_authorization.master_to_audit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_aggregate_authorization) | resource |
| [aws_config_configuration_aggregator.audit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_aggregator) | resource |
| [aws_config_organization_managed_rule.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_organization_managed_rule) | resource |
| [aws_iam_role.sns_feedback](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.sns_feedback_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_service_linked_role.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [aws_organizations_policy.aiservices_opt_out](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy.allowed_regions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy.deny_root_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy.lz_root_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy_attachment.aiservices_opt_out](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_organizations_policy_attachment.allowed_regions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_organizations_policy_attachment.deny_root_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_organizations_policy_attachment.lz_root_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_securityhub_account.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_account.management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_configuration_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_configuration_policy) | resource |
| [aws_securityhub_configuration_policy_association.root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_configuration_policy_association) | resource |
| [aws_securityhub_finding_aggregator.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_finding_aggregator) | resource |
| [aws_securityhub_member.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_member) | resource |
| [aws_securityhub_member.management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_member) | resource |
| [aws_securityhub_organization_admin_account.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_organization_admin_account) | resource |
| [aws_securityhub_organization_configuration.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_organization_configuration) | resource |
| [aws_sns_topic.iam_activity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.security_hub_findings](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.iam_activity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.security_hub_findings](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.aws_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sns_topic_subscription.iam_activity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sns_topic_subscription.security_hub_findings](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_caller_identity.audit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_cloudwatch_log_group.cloudtrail_master](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudwatch_log_group) | data source |
| [aws_iam_policy_document.aws_config_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_key_audit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_key_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sns_feedback](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_organizations_organization.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_organizations_organizational_units.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organizational_units) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_sns_topic.all_config_notifications](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/sns_topic) | data source |
| [mcaf_aws_all_organizational_units.default](https://registry.terraform.io/providers/schubergphilis/mcaf/latest/docs/data-sources/aws_all_organizational_units) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_control_tower_account_ids"></a> [control\_tower\_account\_ids](#input\_control\_tower\_account\_ids) | Control Tower core account IDs | <pre>object({<br/>    audit   = string<br/>    logging = string<br/>  })</pre> | n/a | yes |
| <a name="input_regions"></a> [regions](#input\_regions) | Region configuration, plus global and per-region service SCP exceptions. See the README for more information on the configuration options. | <pre>object({<br/>    additional_allowed_service_actions_per_region    = optional(map(list(string)), {})<br/>    allowed_regions                                  = list(string)<br/>    enable_cdk_service_actions                       = optional(bool, false)<br/>    enable_edge_service_actions                      = optional(bool, false)<br/>    enable_security_lake_aggregation_service_actions = optional(bool, false)<br/>    home_region                                      = string<br/>    linked_regions                                   = optional(list(string), ["us-east-1"])<br/>  })</pre> | n/a | yes |
| <a name="input_additional_auditing_trail"></a> [additional\_auditing\_trail](#input\_additional\_auditing\_trail) | CloudTrail configuration for additional auditing trail | <pre>object({<br/>    name       = string<br/>    bucket     = string<br/>    kms_key_id = string<br/><br/>    event_selector = optional(object({<br/>      data_resource = optional(object({<br/>        type   = string<br/>        values = list(string)<br/>      }))<br/>      exclude_management_event_sources = optional(set(string), null)<br/>      include_management_events        = optional(bool, true)<br/>      read_write_type                  = optional(string, "All")<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_aws_account_password_policy"></a> [aws\_account\_password\_policy](#input\_aws\_account\_password\_policy) | AWS account password policy parameters for the audit, logging and master account | <pre>object({<br/>    allow_users_to_change        = bool<br/>    max_age                      = number<br/>    minimum_length               = number<br/>    require_lowercase_characters = bool<br/>    require_numbers              = bool<br/>    require_symbols              = bool<br/>    require_uppercase_characters = bool<br/>    reuse_prevention_history     = number<br/>  })</pre> | <pre>{<br/>  "allow_users_to_change": true,<br/>  "max_age": 90,<br/>  "minimum_length": 14,<br/>  "require_lowercase_characters": true,<br/>  "require_numbers": true,<br/>  "require_symbols": true,<br/>  "require_uppercase_characters": true,<br/>  "reuse_prevention_history": 24<br/>}</pre> | no |
| <a name="input_aws_aiservices_opt_out_policy_enabled"></a> [aws\_aiservices\_opt\_out\_policy\_enabled](#input\_aws\_aiservices\_opt\_out\_policy\_enabled) | Enable the AWS AI Services Opt-Out Policy at the organization level to prevent AWS from using your content for model training. | `bool` | `true` | no |
| <a name="input_aws_auditmanager"></a> [aws\_auditmanager](#input\_aws\_auditmanager) | AWS Audit Manager config settings | <pre>object({<br/>    enabled               = bool<br/>    reports_bucket_prefix = string<br/>  })</pre> | <pre>{<br/>  "enabled": true,<br/>  "reports_bucket_prefix": "audit-manager-reports"<br/>}</pre> | no |
| <a name="input_aws_config"></a> [aws\_config](#input\_aws\_config) | AWS Config settings | <pre>object({<br/>    aggregator_account_ids          = optional(list(string), [])<br/>    delivery_channel_s3_bucket_name = optional(string, null)<br/>    delivery_channel_s3_key_prefix  = optional(string, null)<br/>    delivery_frequency              = optional(string, "TwentyFour_Hours")<br/>    rule_identifiers                = optional(list(string), [])<br/>  })</pre> | <pre>{<br/>  "aggregator_account_ids": [],<br/>  "delivery_channel_s3_bucket_name": null,<br/>  "delivery_channel_s3_key_prefix": null,<br/>  "delivery_frequency": "TwentyFour_Hours",<br/>  "rule_identifiers": []<br/>}</pre> | no |
| <a name="input_aws_config_sns_subscription"></a> [aws\_config\_sns\_subscription](#input\_aws\_config\_sns\_subscription) | Subscription options for the aws-controltower-AggregateSecurityNotifications (AWS Config) SNS topic | <pre>map(object({<br/>    endpoint = string<br/>    protocol = string<br/>  }))</pre> | `{}` | no |
| <a name="input_aws_ebs_encryption_by_default"></a> [aws\_ebs\_encryption\_by\_default](#input\_aws\_ebs\_encryption\_by\_default) | Set to true to enable AWS Elastic Block Store encryption by default | `bool` | `true` | no |
| <a name="input_aws_ebs_snapshot_block_public_access_state"></a> [aws\_ebs\_snapshot\_block\_public\_access\_state](#input\_aws\_ebs\_snapshot\_block\_public\_access\_state) | Configure regionally the EBS snapshot public sharing policy, alternatives: `block-all-sharing` and `unblocked` | `string` | `"block-new-sharing"` | no |
| <a name="input_aws_ec2_image_block_public_access_state"></a> [aws\_ec2\_image\_block\_public\_access\_state](#input\_aws\_ec2\_image\_block\_public\_access\_state) | Configure blocking new AMIs from being publicly shared, alternatives: `unblocked` | `string` | `"block-new-sharing"` | no |
| <a name="input_aws_guardduty"></a> [aws\_guardduty](#input\_aws\_guardduty) | AWS GuardDuty settings | <pre>object({<br/>    enabled                       = optional(bool, true)<br/>    finding_publishing_frequency  = optional(string, "FIFTEEN_MINUTES")<br/>    ebs_malware_protection_status = optional(bool, true)<br/>    eks_audit_logs_status         = optional(bool, true)<br/>    lambda_network_logs_status    = optional(bool, true)<br/>    rds_login_events_status       = optional(bool, true)<br/>    s3_data_events_status         = optional(bool, true)<br/>    runtime_monitoring_status = optional(object({<br/>      enabled                             = optional(bool, true)<br/>      eks_addon_management_status         = optional(bool, true)<br/>      ecs_fargate_agent_management_status = optional(bool, true)<br/>      ec2_agent_management_status         = optional(bool, true)<br/>    }), {})<br/>  })</pre> | `{}` | no |
| <a name="input_aws_inspector"></a> [aws\_inspector](#input\_aws\_inspector) | AWS Inspector settings, at least one of the scan options must be enabled | <pre>object({<br/>    enabled                     = optional(bool, false)<br/>    enable_scan_ec2             = optional(bool, true)<br/>    enable_scan_ecr             = optional(bool, true)<br/>    enable_scan_lambda          = optional(bool, true)<br/>    enable_scan_lambda_code     = optional(bool, true)<br/>    excluded_member_account_ids = optional(list(string), [])<br/>    resource_create_timeout     = optional(string, "15m")<br/>  })</pre> | `{}` | no |
| <a name="input_aws_required_tags"></a> [aws\_required\_tags](#input\_aws\_required\_tags) | AWS Required tags settings | <pre>map(list(object({<br/>    name         = string<br/>    values       = optional(list(string))<br/>    enforced_for = optional(list(string))<br/>  })))</pre> | `null` | no |
| <a name="input_aws_security_hub"></a> [aws\_security\_hub](#input\_aws\_security\_hub) | AWS Security Hub settings | <pre>object({<br/>    aggregator_linking_mode      = optional(string, "SPECIFIED_REGIONS")<br/>    auto_enable_controls         = optional(bool, true)<br/>    control_finding_generator    = optional(string, "SECURITY_CONTROL")<br/>    create_cis_metric_filters    = optional(bool, true)<br/>    disabled_control_identifiers = optional(list(string), null)<br/>    enabled_control_identifiers  = optional(list(string), null)<br/>    product_arns                 = optional(list(string), [])<br/>    standards_arns               = optional(list(string), null)<br/>  })</pre> | `{}` | no |
| <a name="input_aws_security_hub_sns_subscription"></a> [aws\_security\_hub\_sns\_subscription](#input\_aws\_security\_hub\_sns\_subscription) | Subscription options for the LandingZone-SecurityHubFindings SNS topic | <pre>map(object({<br/>    endpoint = string<br/>    protocol = string<br/>  }))</pre> | `{}` | no |
| <a name="input_aws_service_control_policies"></a> [aws\_service\_control\_policies](#input\_aws\_service\_control\_policies) | AWS SCP's parameters to disable required/denied policies, set a list of allowed AWS regions, and set principals that are exempt from the restriction | <pre>object({<br/>    aws_deny_disabling_security_hub = optional(bool, true)<br/>    aws_deny_leaving_org            = optional(bool, true)<br/>    aws_deny_root_user_ous          = optional(list(string), [])<br/>    aws_require_imdsv2              = optional(bool, true)<br/>    principal_exceptions            = optional(list(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_aws_ssm_documents_public_sharing_permission"></a> [aws\_ssm\_documents\_public\_sharing\_permission](#input\_aws\_ssm\_documents\_public\_sharing\_permission) | Configure the SSM documents public sharing policy, alternatives: `Enable` | `string` | `"Disable"` | no |
| <a name="input_aws_sso_permission_sets"></a> [aws\_sso\_permission\_sets](#input\_aws\_sso\_permission\_sets) | Map of AWS IAM Identity Center permission sets with AWS accounts and group names that should be granted access to each account | <pre>map(object({<br/>    assignments = list(object({<br/>      account_id   = string<br/>      account_name = string<br/>      sso_groups   = list(string)<br/>    }))<br/>    inline_policy       = optional(string, null)<br/>    managed_policy_arns = optional(list(string), [])<br/>    session_duration    = optional(string, "PT4H")<br/>  }))</pre> | `{}` | no |
| <a name="input_datadog"></a> [datadog](#input\_datadog) | Datadog integration options for the core accounts | <pre>object({<br/>    api_key                              = optional(string, null)<br/>    api_key_name_prefix                  = optional(string, "aws-landing-zone-")<br/>    create_api_key                       = optional(bool, false)<br/>    cspm_resource_collection_enabled     = optional(bool, false)<br/>    enable_integration                   = bool<br/>    extended_resource_collection_enabled = optional(bool, false)<br/>    install_log_forwarder                = optional(bool, false)<br/>    log_collection_services              = optional(list(string), [])<br/>    log_forwarder_version                = optional(string)<br/>    metric_tag_filters                   = optional(map(string), {})<br/>    namespace_rules                      = optional(list(string), [])<br/>    site_url                             = string<br/>  })</pre> | `null` | no |
| <a name="input_datadog_excluded_regions"></a> [datadog\_excluded\_regions](#input\_datadog\_excluded\_regions) | List of regions where metrics collection will be disabled. | `list(string)` | `[]` | no |
| <a name="input_kms_key_policy"></a> [kms\_key\_policy](#input\_kms\_key\_policy) | A list of valid KMS key policy JSON documents | `list(string)` | `[]` | no |
| <a name="input_kms_key_policy_audit"></a> [kms\_key\_policy\_audit](#input\_kms\_key\_policy\_audit) | A list of valid KMS key policy JSON document for use with audit KMS key | `list(string)` | `[]` | no |
| <a name="input_kms_key_policy_logging"></a> [kms\_key\_policy\_logging](#input\_kms\_key\_policy\_logging) | A list of valid KMS key policy JSON document for use with logging KMS key | `list(string)` | `[]` | no |
| <a name="input_monitor_iam_activity"></a> [monitor\_iam\_activity](#input\_monitor\_iam\_activity) | Whether IAM activity should be monitored | `bool` | `true` | no |
| <a name="input_monitor_iam_activity_sns_subscription"></a> [monitor\_iam\_activity\_sns\_subscription](#input\_monitor\_iam\_activity\_sns\_subscription) | Subscription options for the LandingZone-IAMActivity SNS topic | <pre>map(object({<br/>    endpoint = string<br/>    protocol = string<br/>  }))</pre> | `{}` | no |
| <a name="input_path"></a> [path](#input\_path) | Optional path for all IAM users, user groups, roles, and customer managed policies created by this module | `string` | `"/"` | no |
| <a name="input_ses_root_accounts_mail_forward"></a> [ses\_root\_accounts\_mail\_forward](#input\_ses\_root\_accounts\_mail\_forward) | SES config to receive and forward root account emails | <pre>object({<br/>    domain            = string<br/>    from_email        = string<br/>    recipient_mapping = map(any)<br/><br/>    dmarc = object({<br/>      policy = optional(string)<br/>      rua    = optional(string)<br/>      ruf    = optional(string)<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_config_iam_service_linked_role_arn"></a> [aws\_config\_iam\_service\_linked\_role\_arn](#output\_aws\_config\_iam\_service\_linked\_role\_arn) | IAM Service Linked Role ARN for AWS Config in the management account |
| <a name="output_aws_config_s3_bucket_arn"></a> [aws\_config\_s3\_bucket\_arn](#output\_aws\_config\_s3\_bucket\_arn) | ARN of the AWS Config S3 bucket in the logging account |
| <a name="output_aws_config_s3_bucket_name"></a> [aws\_config\_s3\_bucket\_name](#output\_aws\_config\_s3\_bucket\_name) | Name of the AWS Config S3 bucket in the logging account |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ARN of KMS key for the management account |
| <a name="output_kms_key_audit_arn"></a> [kms\_key\_audit\_arn](#output\_kms\_key\_audit\_arn) | ARN of KMS key for the audit account |
| <a name="output_kms_key_audit_id"></a> [kms\_key\_audit\_id](#output\_kms\_key\_audit\_id) | ID of KMS key for the audit account |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | ID of KMS key for the management account |
| <a name="output_kms_key_logging_arn"></a> [kms\_key\_logging\_arn](#output\_kms\_key\_logging\_arn) | ARN of KMS key for the logging account |
| <a name="output_kms_key_logging_id"></a> [kms\_key\_logging\_id](#output\_kms\_key\_logging\_id) | ID of KMS key for the logging account |
| <a name="output_monitor_iam_activity_sns_topic_arn"></a> [monitor\_iam\_activity\_sns\_topic\_arn](#output\_monitor\_iam\_activity\_sns\_topic\_arn) | ARN of the SNS Topic in the audit account for IAM activity monitoring notifications |
<!-- END_TF_DOCS -->

## License

**Copyright:** Schuberg Philis

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

## Using Pre-commit

To make local development easier, we have added a pre-commit configuration to the repo. to use it, follow these steps:

Install the following tools:

`brew install tflint`

Install pre-commit:

`pip3 install pre-commit --upgrade`

To run the pre-commit hooks to see if everything working as expected, (the first time run might take a few minutes):

`pre-commit run -a`

To install the pre-commit hooks to run before each commit:

`pre-commit install`
