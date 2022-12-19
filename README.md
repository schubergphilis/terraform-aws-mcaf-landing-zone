# terraform-aws-mcaf-landing-zone

Terraform module to setup and manage various components of the SBP AWS Landing Zone.

Overview of Landing Zone tools & services:

<img src="images/MCAF_landing_zone_tools_and_services_v040.png" width="600">

The SBP AWS Landing Zone consists of 3 repositories:

- [MCAF Landing Zone module (current repository)](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone): the foundation of the Landing Zone and manages the 3 core accounts: audit, logging, master
- [MCAF Account Vending Machine (AVM) module](https://github.com/schubergphilis/terraform-aws-mcaf-avm): providing an AWS AVM. This module sets up an AWS account with one or more Terraform Cloud/Enterprise (TFE) workspace(s) backed by a VCS project
- [MCAF Account Baseline module](https://github.com/schubergphilis/terraform-aws-mcaf-account-baseline): optional module providing baseline configuration for AWS accounts

## Basic configuration

```hcl
module "landing_zone" {
  source             = "github.com/schubergphilis/terraform-aws-mcaf-landing-zone?ref=VERSION"
  tags               = var.tags

  control_tower_account_ids = {
    audit   = "012345678902"
    logging = "012345678903"
  }
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

NOTE: Before enabling this feature, make sure that the [bucket policy authorizing CloudTrail to deliver logs](https://aws.amazon.com/premiumsupport/knowledge-center/change-cloudtrail-trail/) is in place and that you have enabled [trusted access between AWS Organizations and CloudTrail](https://docs.aws.amazon.com/organizations/latest/userguide/services-that-can-integrate-cloudtrail.html#integrate-enable-ta-cloudtrail). If these two steps are not in place, Terraform will fail to create the trail.

Example:

```hcl
additional_auditing_trail = {
  name   = "additional_auditing_trail"
  bucket = "bucket_name"
}
```

### AWS Config Rules

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

### AWS GuardDuty

This module supports enabling GuardDuty at the organization level which means that all new accounts that are created in, or added to, the organization are added as a member accounts of the `audit` account GuardDuty detector.

This feature can be controlled via the `aws_guardduty` variable and is enabled by default. With `aws_guardduty_s3_protection` you control if you want to have GuardDuty protecting S3, it is turned on by default.

Note: In case you are migrating an existing AWS organization to this module, all existing accounts except for the `master` and `logging` accounts have to be enabled like explained [here](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_organizations.html#guardduty_add_orgs_accounts).

## AWS KMS

The module creates 3 AWS KMS keys, one for the master account, one for the audit account, and one for the log archive account. We recommend to further scope down the AWS KMS key policy in the master account by providing a secure policy using `kms_key_policy`. The default policy "Base Permissions" can be overwritten and should be limited to the root account only, for example by using the statement below:

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
        "arn:aws:iam::${data.aws_caller_identity.master.account_id}:root"
      ]
    }
  }
```

Note that you have to add additional policies allowing for example access to the pipeline user or role. Only applying this policy will result in a `The new key policy will not allow you to update the key policy in the future` exception.

### AWS SSO

This module supports managing AWS SSO resources to control user access to all accounts belonging to the AWS Organization.

This feature can be controlled via the `aws_sso_permission_sets` variable by passing a map (key-value pair) where every key corresponds to an AWS SSO Permission Set name and the value follows the structure below:

- `assignments`: list of maps (key-value pair) of AWS Account IDs as keys and a list of AWS SSO Group names that should have access to the account using the permission set defined
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
        {
          for account in [ 123456789012, 012456789012 ] : account => [
            okta_group.aws["AWSPlatformAdmins"].name
          ]
        },
        {
          for account in [ 925556789012 ] : account => [
            okta_group.aws["AWSPlatformUsers"].name
          ]
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
        {
          for account in [ 123456789012, 012456789012 ] : account => [
            okta_group.aws["AWSPlatformAdmins"].name,
            okta_group.aws["AWSPlatformUsers"].name
          ]
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

#### Deny ability to disable Security Hub

Enabling this SCP removes a member account's ability to disable Security Hub.

This is SCP is enabled by default, but can be disabled by setting `aws_deny_disabling_security_hub` attribute to `false` in `aws_service_control_policies`.

Example:

```hcl
aws_service_control_policies = {
  aws_deny_disabling_security_hub = false
}
```

#### Deny ability to leave Organization

Enabling this SCP removes a member account's ability to leave the AWS organization.

This is SCP is enabled by default, but can be disabled by setting `aws_deny_leaving_org` attribute to `false` in `aws_service_control_policies`.

Example:

```hcl
aws_service_control_policies = {
  aws_deny_leaving_org = false
}
```

#### Require the use of Instance Metadata Service Version 2

By default, all EC2s still allow access to the original metadata service, which means that if an attacker finds an EC2 running a proxy or WAF, or finds and SSRF vulnerability, they likely can steal the IAM role of the EC2. By enforcing IMDSv2, you can mitigate that risk. Be aware that this potentially could break some applications that have not yet been updated to work with the new IMDSv2.

This is SCP is enabled by default, but can be disabled by setting `aws_require_imdsv2` attribute to `false` in `aws_service_control_policies`.

Example:

```hcl
aws_service_control_policies = {
  aws_require_imdsv2 = false
}
```

#### Restricting AWS Regions

If you would like to define which AWS Regions can be used in your AWS Organization, you can pass a list of region names to the variable `aws_service_control_policies` using the `allowed_regions` attribute. This will trigger this module to deploy a [Service Control Policy (SCP) designed by AWS](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps_examples.html#example-scp-deny-region) and attach it to the root of your AWS Organization.

Example:

```hcl
aws_service_control_policies = {
  allowed_regions    = ["eu-west-1"]
}
```

#### AWS Principal exceptions

In case you would like to exempt specific IAM entities from the [region restriction](#restricting-aws-regions), [leave the AWS organization](#deny-ability-to-leave-organization) and from the [ability to disable Security Hub](#deny-ability-to-disable-security-hub), you can pass a list of ARN patterns using the `principal_exceptions` attribute in `aws_service_control_policies`. This can be useful for roles used by AWS ControlTower, for example, to avoid preventing it from managing all regions properly.

Example:

```hcl
aws_service_control_policies = {
  principal_exceptions = ["arn:aws:iam::*:role/RoleAllowedToBypassRegionRestrictions"]
}
```

#### Restricting Root User Access

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

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| aws | >= 4.9.0 |
| mcaf | >= 0.4.2 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.9.0 |
| aws.audit | >= 4.9.0 |
| aws.logging | >= 4.9.0 |
| mcaf | >= 0.4.2 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_service\_control\_policies | AWS SCP's parameters for allowed AWS regions, principals that are exempt from the restriction and required/denied policies | <pre>object({<br>    allowed_regions                 = optional(list(string), [])<br>    principal_exceptions            = optional(list(string), [])<br>    aws_deny_disabling_security_hub = optional(bool, true)<br>    aws_deny_leaving_org            = optional(bool, true)<br>    aws_deny_root_user_ous          = optional(list(string), [])<br>    aws_require_imdsv2              = optional(bool, true)<br>  })</pre> | n/a | yes |
| control\_tower\_account\_ids | Control Tower core account IDs | <pre>object({<br>    audit   = string<br>    logging = string<br>  })</pre> | n/a | yes |
| tags | Map of tags | `map(string)` | n/a | yes |
| additional\_auditing\_trail | CloudTrail configuration for additional auditing trail | <pre>object({<br>    name   = string<br>    bucket = string<br>  })</pre> | `null` | no |
| aws\_account\_password\_policy | AWS account password policy parameters for the audit, logging and master account | <pre>object({<br>    allow_users_to_change        = bool<br>    max_age                      = number<br>    minimum_length               = number<br>    require_lowercase_characters = bool<br>    require_numbers              = bool<br>    require_symbols              = bool<br>    require_uppercase_characters = bool<br>    reuse_prevention_history     = number<br>  })</pre> | <pre>{<br>  "allow_users_to_change": true,<br>  "max_age": 90,<br>  "minimum_length": 14,<br>  "require_lowercase_characters": true,<br>  "require_numbers": true,<br>  "require_symbols": true,<br>  "require_uppercase_characters": true,<br>  "reuse_prevention_history": 24<br>}</pre> | no |
| aws\_config | AWS Config settings | <pre>object({<br>    aggregator_account_ids = list(string)<br>    aggregator_regions     = list(string)<br>  })</pre> | `null` | no |
| aws\_config\_sns\_subscription | Subscription options for the aws-controltower-AggregateSecurityNotifications (AWS Config) SNS topic | <pre>map(object({<br>    endpoint = string<br>    protocol = string<br>  }))</pre> | `{}` | no |
| aws\_ebs\_encryption\_by\_default | Set to true to enable AWS Elastic Block Store encryption by default | `bool` | `true` | no |
| aws\_guardduty | Whether AWS GuardDuty should be enabled | `bool` | `true` | no |
| aws\_guardduty\_s3\_protection | Whether AWS GuardDuty S3 protection should be enabled | `bool` | `true` | no |
| aws\_required\_tags | AWS Required tags settings | <pre>map(list(object({<br>    name         = string<br>    values       = optional(list(string))<br>    enforced_for = optional(list(string))<br>  })))</pre> | `null` | no |
| aws\_required\_tags | AWS Required tags settings | <pre>map(list(object({<br>    name   = string<br>    values = optional(list(string))<br>  })))</pre> | `null` | no |
| aws\_security\_hub\_product\_arns | A list of the ARNs of the products you want to import into Security Hub | `list(string)` | `[]` | no |
| aws\_security\_hub\_sns\_subscription | Subscription options for the LandingZone-SecurityHubFindings SNS topic | <pre>map(object({<br>    endpoint = string<br>    protocol = string<br>  }))</pre> | `{}` | no |
| aws\_sso\_permission\_sets | Map of AWS IAM Identity Center permission sets with AWS accounts and group names that should be granted access to each account | <pre>map(object({<br>    assignments         = list(map(list(string)))<br>    inline_policy       = optional(string, null)<br>    managed_policy_arns = optional(list(string), [])<br>    session_duration    = optional(string, "PT4H")<br>  }))</pre> | `{}` | no |
| datadog | Datadog integration options for the core accounts | <pre>object({<br>    api_key               = string<br>    enable_integration    = bool<br>    install_log_forwarder = bool<br>    site_url              = string<br>  })</pre> | `null` | no |
| datadog\_excluded\_regions | List of regions where metrics collection will be disabled. | `list(string)` | `[]` | no |
| kms\_key\_policy | A list of valid KMS key policy JSON documents | `list(string)` | `[]` | no |
| kms\_key\_policy\_audit | A list of valid KMS key policy JSON document for use with audit KMS key | `list(string)` | `[]` | no |
| kms\_key\_policy\_logging | A list of valid KMS key policy JSON document for use with logging KMS key | `list(string)` | `[]` | no |
| monitor\_iam\_activity | Whether IAM activity should be monitored | `bool` | `true` | no |
| monitor\_iam\_activity\_sns\_subscription | Subscription options for the LandingZone-IAMActivity SNS topic | <pre>map(object({<br>    endpoint = string<br>    protocol = string<br>  }))</pre> | `{}` | no |
| security\_hub\_create\_cis\_metric\_filters | Enable the creation of metric filters related to the CIS AWS Foundation Security Hub Standard | `bool` | `true` | no |
| security\_hub\_standards\_arns | A list of the ARNs of the standards you want to enable in Security Hub | `list(string)` | `null` | no |
| ses\_root\_accounts\_mail\_forward | SES config to receive and forward root account emails | <pre>object({<br>    domain            = string<br>    from_email        = string<br>    recipient_mapping = map(any)<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| kms\_key\_arn | ARN of KMS key for master account |
| kms\_key\_audit\_arn | ARN of KMS key for audit account |
| kms\_key\_audit\_id | ID of KMS key for audit account |
| kms\_key\_id | ID of KMS key for master account |
| kms\_key\_logging\_arn | ARN of KMS key for logging account |
| kms\_key\_logging\_id | ID of KMS key for logging account |
| monitor\_iam\_activity\_sns\_topic\_arn | ARN of the SNS Topic in the Audit account for IAM activity monitoring notifications |
| root\_policy | n/a |

<!--- END_TF_DOCS --->

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
