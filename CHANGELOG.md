# CHANGELOG

All notable changes to this project will automatically be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v4.0.1 - 2024-11-01

### What's Changed

#### 🐛 Bug Fixes

* fix: add the option to control the SecurityHub auto enabling behaviour for newly created AWS accounts (#213) @kapas2004

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v4.0.0...v4.0.1

## v4.0.0 - 2024-10-28

### What's Changed

#### 🚀 Features

* breaking: update GuardDuty to support runtime monitoring (#210) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v3.5.2...v4.0.0

## v3.5.2 - 2024-10-11

### What's Changed

#### 🐛 Bug Fixes

* fix: Remove unused SES forwarder alias (#212) @shoekstra

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v3.5.1...v3.5.2

## v3.5.1 - 2024-10-02

### What's Changed

#### 🐛 Bug Fixes

* fix: bump Datadog module to one with fixed dependencies (#211) @stefanwb

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v3.5.0...v3.5.1

## v3.5.0 - 2024-09-10

### What's Changed

#### 🚀 Features

* feature: update dependencies for security findings (#209) @Plork

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v3.4.0...v3.5.0

## v3.4.0 - 2024-08-12

### What's Changed

#### 🐛 Bug Fixes

* bug: encrypt the audit manager reports bucket using KMS (#208) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v3.3.0...v3.4.0

## v3.3.0 - 2024-08-08

### What's Changed

#### 🚀 Features

* feature: upgrade the datadog integration module, exposing the latest settings (#207) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v3.2.5...v3.3.0

## v3.2.5 - 2024-08-01

### What's Changed

#### 🐛 Bug Fixes

* fix: add create timeout config for aws_inspector2_enabler resource (#206) @skesarkar-schubergphilis

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v3.2.4...v3.2.5

## v3.2.4 - 2024-07-02

### What's Changed

#### 🐛 Bug Fixes

* fix: for passing Control.1 Security Hub control on the core-mgmt account (#205) @marceldevroed

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v3.2.3...v3.2.4

## v3.2.3 - 2024-05-28

### What's Changed

#### 🐛 Bug Fixes

* bug: add servicequotas to allowed regions deny since global quotas need to be managed from us-east-1 (#204) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v3.2.2...v3.2.3

## v3.2.2 - 2024-04-19

### What's Changed

#### 🐛 Bug Fixes

* fix: global allowed region permissions for quicksight (#202) @svashisht03

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v3.2.1...v3.2.2

## v3.2.1 - 2024-03-29

### What's Changed

#### 🐛 Bug Fixes

* fix: add logs:* to the allowed regions exclusion since this is needed for global services (#201) @angautam

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v3.2.0...v3.2.1

## v3.2.0 - 2024-02-22

### What's Changed

#### 🚀 Features

* feature: Add Amazon Inspector support (#200) @wvanheerde

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v3.1.2...v3.2.0

## v3.1.2 - 2024-02-21

### What's Changed

#### 🐛 Bug Fixes

* fix: add default principal to region deny SCP (#199) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v3.1.1...v3.1.2

## v3.1.1 - 2024-01-17

### What's Changed

#### 🐛 Bug Fixes

* fix: global allowed region permissions for s3 logging & quicksight (#198) @Plork

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v3.1.0...v3.1.1

## v3.1.0 - 2024-01-05

### What's Changed

#### 🚀 Features

* enhancement: Enable AWS Audit Manager (#197) @stefanwb

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v3.0.0...v3.1.0

## v3.0.0 - 2024-01-02

### What's Changed

#### 🚀 Features

* breaking: Control Tower 3.0 support (#196) @stefanwb

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v2.0.1...v3.0.0

## v2.0.1 - 2023-12-04

### What's Changed

#### 🐛 Bug Fixes

* fix: add provider to guardduty features (#195) @marcoschreurs

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v2.0.0...v2.0.1

## v2.0.0 - 2023-12-04

### What's Changed

#### 🚀 Features

* breaking: Add AWS Guardduty detector features & bump AWS provider to next major v5 (#194) @marcoschreurs

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v1.4.0...v2.0.0

## v1.4.0 - 2023-11-09

### What's Changed

#### 🚀 Features

- feat: Add option to provide event_selector for CloudTrail (#193) @sbkg0002

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v1.3.0...v1.4.0

## v1.3.0 - 2023-10-02

### What's Changed

#### 🚀 Features

- enhancement: Update mcaf datadog  to v0.3.12 (#191) @marcoschreurs

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v1.2.0...v1.3.0

## v1.2.0 - 2023-09-08

### What's Changed

#### 🚀 Features

- feat: update allowed_regions SCP to include latest services (#190) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v1.1.1...v1.2.0

## v1.1.1 - 2023-08-09

### What's Changed

#### 🐛 Bug Fixes

- bug: tag policy documentation is not in line with actual enforcement options enforced by the tag policies service (#188) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v1.1.0...v1.1.1

## v1.1.0 - 2023-08-08

### What's Changed

#### 🚀 Features

- feat: update the tag policy services and resource types list that support enforcement (#187) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v1.0.1...v1.1.0

## v1.0.1 - 2023-07-25

### What's Changed

#### 🐛 Bug Fixes

- bug: aws security hub in management settings need to be removed to prevent overriding of values (#186) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v1.0.0...v1.0.1

## v1.0.0 - 2023-07-25

### What's Changed

#### 🚀 Features

- feature: Refactor AWS Security Hub configuration (#185) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v0.28.1...v1.0.0

## v0.28.1 - 2023-07-12

### What's Changed

#### 🐛 Bug Fixes

- fix: Remove unused `files/okta/app_settings.json.tpl` file (#183) @shoekstra
- bug: cis metrics filters get removed when upgrading to v0.26.0 or higher but not upgrading to security hub cis 1.4 (#184) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v0.28.0...v0.28.1

## v0.28.0 - 2023-07-11

### What's Changed

#### 🚀 Features

- enhancement: Adds log collection option for DD integration (#182) @stefanwb

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v0.27.0...v0.28.0

## v0.27.0 - 2023-07-11

### What's Changed

#### 🚀 Features

- enhancement: Enable SecurityHub for management and logging account (#176) @stimmerman

#### 🐛 Bug Fixes

- enhancement: Enable SecurityHub for management and logging account (#176) @stimmerman

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v0.26.1...v0.27.0

## v0.26.1 - 2023-07-10

### What's Changed

#### 🐛 Bug Fixes

- bug: ses-root-accounts-mail-forward s3 bucket solve ACL error (#180) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v0.26.0...v0.26.1

## v0.26.0 - 2023-06-19

### What's Changed

#### 🚀 Features

- enhancement: Update cis-aws-foundations-benchmark from v1.2.0 to v1.4.0 (#177) @stimmerman

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v0.25.1...v0.26.0

## v0.25.1 - 2023-05-26

### What's Changed

#### 🐛 Bug Fixes

- bug: when creating the AWS Config bucket the ACL is not supported (#179) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v0.25.0...v0.25.1

## v0.25.0 - 2023-04-03

### What's Changed

- Remove workflows (#172) @shoekstra
- TF docs needs to write content (#170) @stimmerman
- Be more explicit about which files to keep in sync (#169) @stefanwb
- Bumps checkov in Actions (#168) @stefanwb

#### 🚀 Features

- enhancement: add kms encryption to the CloudTrail `additional_auditing_trail` (#171) @japm94

#### 📖 Documentation

- enhancement: add kms encryption to the CloudTrail `additional_auditing_trail` (#171) @japm94

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/compare/v0.24.1...v0.25.0

## v0.24.1 - 2023-02-10

ENHANCEMENTS

- Add KMS permissions to the KMS key to allow encryption/decryption by the cloudWatch log group of the `ses-root-accounts-mail-forward` lambda ([#167](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/167)).
- Encrypt the CloudWatch log group of the `ses-root-accounts-mail-forward` lambda ([#166](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/166)).

## v0.24.0 - 2023-02-07

ENHANCEMENTS

- Change nested provider to provider alias ([#165](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/165)).

## v0.23.0 - 2023-02-01

ENHANCEMENTS

- Use a seperate bucket to store AWS Config Configuration History, enable KMS on the delivery channel objects, and add the option to set a optional path for all supported IAM resources. ([#164](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/164)).
- Restructure module - create a file per provided functionality instead of per account ([#163](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/163)).

## v0.22.0 - 2023-01-18

ENHANCEMENTS

- Make GuardDuty more configurable, adds ability to set publishing frequency and data sources ([#161](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/161)).

## v0.21.5 - 2023-01-11

ENHANCEMENTS

- Adding CheckOV to the workflow and solving all CheckOV findings ([#160](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/160)).

## v0.21.4 - 2023-01-09

ENHANCEMENTS

- Adding the `supportplans:*` global service as exception to the `DenyAllRegionsOutsideAllowedList` SCP ([#159](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/159)).

## v0.21.3 - 2023-01-06

ENHANCEMENTS

- Fixed CheckOV finding because of `aws_guardduty_detector` not explicity enabled ([#158](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/158)).

## v0.21.2 - 2023-01-03

ENHANCEMENTS

- Update minimum AWS provider version to fix deprecation message in `aws_identitystore_group` data resource ([#157](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/157)).

## v0.21.1 - 2023-01-03

ENHANCEMENTS

- Add DMARC support for SES root accounts mail forward feature, this will make it possible to configure a RUA or RUF email address to send DMARC reports to ([#156](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/156)).

## v0.21.0 - 2022-12-27

BUG FIXES

- Adding allowing IAM entities exceptions on `aws_deny_disabling_security_hub` and `aws_deny_leaving_org` organizations policy. Move SCP's variables into `aws_service_control_policies` ([#153](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/153)).

## v0.20.0 - 2022-12-13

ENHANCEMENTS

- Move AWS IAM Identity Center permission set resources to a sub-module. ([#150](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/150))

## v0.19.1 - 2022-12-14

ENHANCEMENTS

- Generate unique names for tag policies and remove services that are not supported from the enforcement list. ([#155](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/155))

## v0.19.0 - 2022-12-13

ENHANCEMENTS

- Create tag policies per tag key, this will recreate any existing policies, and allow policy enforcement per service. ([#152](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/152))

## v0.18.0 - 2022-11-30

ENHANCEMENTS

- Allow Tag Policies on nested Organizational units and allow optional `values` for Tag policies. Therefore the Terraform version requirement is now `>= 1.3`  ([#151](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/151))

## v0.17.8 - 2022-11-23

ENHANCEMENTS

- Bump terraform-aws-mcaf-ses-forwarder to 0.2.2, which removes template provider dependency. ([#149](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/149))

## v0.17.7 - 2022-11-17

BUG FIXES

- Update allowed regions list to include latest services. ([#148](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/148))

## v0.17.6 - 2022-10-13

BUG FIXES

- Update AWS ConfigRole to match the updated policy name. ([#147](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/147))

## v0.17.5 - 2022-10-13

BUG FIXES

- Only use `aws_cloudwatch_log_group` data sources when the variable `monitor_iam_activity` is set to true. ([#145](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/145))

## v0.17.4 - 2022-10-05

BUG FIXES

- Fix error: Null values are not allowed for this attribute value. ([#144](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/144))
- Fix SH finding SNS.2 on core-audit account -- Configuring delivery status logging. ([#142](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/142))

## v0.17.3 - 2022-09-30

ENHANCEMENTS

- Update the terraform-aws-mcaf-ses module to v0.1.1 to support DMARC record creation. ([#141](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/141))

## v0.17.2 - 2022-08-12

BUG FIXES

- Modify audit kms key policy to grant GenerateDataKey permissions to pipeline . ([#140](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/140))

## v0.17.1 - 2022-08-11

BUG FIXES

- Allow sns.amazonaws.com access to the audit kms key and remove an unneeded statement in the master key. ([#138](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/138))
- Modify master account KMS key policy allowing override. ([#139](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/139))

## v0.17.0 - 2022-08-10

ENHANCEMENTS

- Add support for providing custom KMS key policy for audit KMS key and move KMS to a seperate file. ([#137](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/137))

## v0.16.0 - 2022-08-08

ENHANCEMENTS

- Add support for AWS Provider version 4. ([#136](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/136))

## v0.15.6 - 2022-07-13

BUG FIXES

- Modify KMS key input of the internal `ses-root-accounts-mail-forward` module to use ARN in stead of ID. ([#135](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/135))

## v0.15.5 - 2022-05-31

ENHANCEMENTS

- Whitelist Sustainability as a approved global service in the Allowed Regions Service Control Policy. ([#134](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/134))

## v0.15.4 - 2022-04-15

BUG FIXES

- Datadog site url is now also passed to datadog forwarder module for audit and logging accounts. ([#133](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/133))

## v0.15.3 - 2022-04-05

BUG FIXES

- When `var.monitor_iam_activity` is set `false` we shouldn't create any `iam_activity` related resources. ([#131](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/131))

## v0.15.2 - 2022-03-14

ENHANCEMENTS

- Updated KMS key policy for logging KMS key have more default Get permissions. ([#130](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/130))

## v0.15.1 - 2022-03-10

ENHANCEMENTS

- Added a KMS key for logging account with support for KMS key policy. ([#129](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/129))

## v0.15.0 - 2022-02-21

ENHANCEMENTS

- Add an optional mail forwarder using Amazon SES: adding the `ses_root_accounts_mail_forward` variable creates the necessary SES resources to accept mail sent to an AWS hosted domain and forward it to an external recipient or recipients. ([#128](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/128))

## v0.14.0 - 2022-01-14

ENHANCEMENTS

- Add an account level S3 public access policy to block public access to all S3 buckets within the landing zone core accounts. ([#125](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/125))

## v0.13.0 - 2021-11-17

ENHANCEMENTS

- Add support for assigning managed policies in SSO permission sets. ([#124](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/124))

## v0.12.2 - 2021-11-10

BUG FIXES

- Fixed malfunction policy issue. Allowed regions policy template wasn't using the appropariate allowed_region property. ([#123](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/123))

## v0.12.1 - 2021-10-27

BUG FIXES

- Conditionally merges DenyAllRegionsOutsideAllowedList, DenyDeletingCloudTrailLogStream, DenyDisablingSecurityHub, RequireAllEc2RolesToUseV2, RequireImdsV2, MaxImdsHopLimit, and DenyLeavingOrg policies into one `LandinZone-RootPolicies` policy to avoid exceeding SCP limit (5 policies per org) [Quotas for AWS Organizations](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_reference_limits.html).
- ([#120](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/120))

## v0.12.0 - 2021-09-22

ENHANCEMENTS

- Set the audit account as security hub administrator account for the organization and automatically enable Security Hub for new accounts in the organization. ([#121](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/121))

## v0.11.0 - 2021-09-22

ENHANCEMENTS

- Add additional IAM activity monitors. ([#119](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/119))

## v0.10.6 - 2021-09-13

ENHANCEMENTS

- Upgrade Datadog MCAF module used in core accounts to latest version. ([#118](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/118))

## v0.10.5 - 2021-09-07

ENHANCEMENTS

- Update IAM Activity Monitor for root usage to match CIS AWS rule 1.1. ([#117](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/117))

## v0.10.4 - 2021-08-23

ENHANCEMENTS

- Add a `DenyDisablingSecurityHub` SCP that is attached to all AWS Organisation OUs. ([#110](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/110))

## v0.10.3 - 2021-08-04

ENHANCEMENTS

- Enable by default AWS GuardDuty S3 protection. ([#111](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/111))

## v0.10.2 - 2021-07-13

ENHANCEMENTS

- Update KMS module. ([#109](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/109))

## v0.10.1 - 2021-06-30

ENHANCEMENTS

- Make list of SecurityHub Standards configurable ([#108](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/108))

## v0.10.0 - 2021-05-27

ENHANCEMENTS

- Add support for multiple SSO Permission Set assignments. ([#106](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/106))

## v0.9.1 - 2021-05-11

ENHANCEMENTS

- Added support for KMS Key policy. ([#104](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/104))

## v0.9.0 - 2021-04-12

ENHANCEMENTS

- Removal of the local AVM module. AVM module has been split up into 2 modules to allow for more flexibility: AVM core functionality has been moved to [MCAF Account Vending Machine (AVM) module](https://github.com/schubergphilis/terraform-aws-mcaf-avm) and all other functionality has been moved to the [MCAF Account Baseline module](https://github.com/schubergphilis/terraform-aws-mcaf-account-baseline). ([#102](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/102))

## v0.8.2 - 2021-04-08

BUG FIXES

- Adds `is_multi_region_trail = true` & `enable_log_file_validation = true` for cloudtrail resource regarding TFSEC#AWS063 & #AWS064 ([#101](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/101))
- Allows access-analyzer to be used outside region since it's a global service + adds ignores for tfsec ([#100](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/100))

## v0.8.1 - 2021-03-22

ENHANCEMENTS

- Add support to use a TFC agent pool ([#98](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/98))

## v0.8.0 - 2021-03-05

ENHANCEMENTS

- Add support to manage AWS SSO resources ([#95](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/95))

## v0.7.4 - 2021-03-03

ENHANCEMENTS

- Add SCP to protect CloudTrail LogStream ([#94](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/94))

BUG FIXES

- Prevent error when aws_required_tags is not set ([#93](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/93))
- Improve tagging of resources ([#92](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/92))

## v0.7.3 - 2021-02-06

ENHANCEMENTS

- Adding tag compliance capability using tag policies ([#84](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/84))

## v0.7.2 - 2021-02-25

ENHANCEMENTS

- Add capability to disable SSO activity monitoring in the AVM module ([#89](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/89))

## v0.7.1 - 2021-02-24

BUG FIXES

- Update SCP to support AWS ChatBot ([#88](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/88))

## v0.7.0 - 2021-02-24

ENHANCEMENTS

- Update IAM activity monitoring in the AVM module ([#86](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/86))
- Update IAM activity monitoring in the core accounts ([#85](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/85))

## v0.6.1 - 2021-02-09

BUG FIXES

- Add missing provider to the `aws_iam_account_password_policy` and `aws_ebs_encryption_by_default` resources ([#82](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/82))

## v0.6.0 - 2021-02-02

BUG FIXES

- Fix error when trying to read SNS topic policy from data source ([#78](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/78))

ENHANCEMENTS

- Enable AWS EBS encryption by default ([#79](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/79))
- Refactored Securityhub to use organizations and removed unused Guardduty resources ([#80](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/80))

## v0.5.1 - 2021-01-15

BUG FIXES

- Fix `workspace_id` output in AVM module when the module does not create a workspace ([#76](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/76))

## v0.5.0 - 2021-01-15

ENHANCEMENTS

- Add ability to opt out of workspace create when you want to create the workspace and workspace user outside of the AVM module ([#74](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/74))

## v0.4.9 - 2021-01-11

BUG FIXES

- Fix bug in output `monitor_iam_access_sns_topic_arn`, this needs to be the event bus arn. Changed the value and the output to match the event bus in the audit account ([#72](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/72))

## v0.4.8 - 2021-01-11

BUG FIXES

- Fix bug in `monitor_iam_access` pattern in the AVM module, `userName` must be an array ([#70](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/70))

## v0.4.7 - 2021-01-08

BUG FIXES

- Enable key rotation for the kms resources ([#68](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/68))

## v0.4.6 - 2021-01-08

ENHANCEMENTS

- Add notifications for Security Hub findings via SNS topic LandingZone-SecurityHubFindings ([#56](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/56))

## v0.4.5 - 2021-01-08

BUG FIXES

- Add `endpoint_auto_confirms` variable to the AWS Config SNS topic ([#62](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/62)) ([#64](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/64))
- Modify accountID of the AWS Config SNS topic ([#65](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/65))

## v0.4.4 - 2021-01-05

BUG FIXES

- Resolve issue where an empty `sns_security_subscription` variable causes a failure and restructured the variable to a map as `for_each` in Terraform 0.14 cannot be used with an object that has sensitive values ([#60](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/60))

## v0.4.3 - 2021-01-04

ENHANCEMENTS

- Set default password policy parameters for the audit, logging, master accounts ([#57](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/57))

ENHANCEMENTS

- Forward SecurityHub findings to AggregateSecurityNotifications SNS topic ([#56](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/56))

## v0.4.2 - 2020-12-29

ENHANCEMENTS

- Add support for subscribing to aggregated security SNS topic ([#41](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/41))

## v0.4.1 - 2020-12-29

ENHANCEMENTS

- Add support for exemptions to the AWS region restriction ([#31](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/31))
- Set default password policy parameters for the AWS accounts ([#51](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/51)) ([#43](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/43))

BUG FIXES

- Loosen provider version constraints to allow more flexibility for module users ([#53](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/53))

## v0.4.0 - 2020-12-16

ENHANCEMENTS

- Add a `DenyLeavingOrg` SCP that is attached to all AWS Organisation OUs ([#39](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/39))
- Add a `RequireUseOfIMDSv2` SCP that is attached to all AWS Organisation OUs by default ([#38](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/38))
- Add a `DenyRootUser` SCP that can be attached to AWS Organisation OUs ([#37](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/37))

## v0.3.2 - 2020-12-14

BUG FIXES

- Fix support for Datadog region ([#36](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/36))

## v0.3.1 - 2020-12-09

ENHANCEMENTS

- Add support for usage of different Datadog region ([#32](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/32)) ([#34](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/34))

## v0.3.0 - 2020-12-04

ENHANCEMENTS

- Add support for an additional CloudTrail Trail configuration ([#28](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/28))

## v0.2.1 - 2020-11-30

BUG FIXES

- Fix recreation of the aws_securityhub_member resource ([#25](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/25))
- Remove MCAF provider version pin in AVM module ([#26](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/26))

## v0.2.0 - 2020-11-20

ENHANCEMENTS

- Add support for AWS GuardDuty ([#12](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/12))
- Modify terraform-aws-mcaf-workspace version to 0.3.0 in the avm module, in order to prevent github error ([#22](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/22))
- Add KMS Key in the Audit account ([#18](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/18))
- Add support for monitoring IAM access ([#15](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/15))
- Add support for multiple AWS Config Aggregators ([#14](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/14))
- Add support for defining specific account name for AWS Service Catalog ([#13](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/13))
- Make account and email names more flexible. ([#17](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/17))

BUG FIXES

- Fix multiple bugs in unreleased features ([#23](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/23))
- Add filter to create rules only for the right identities ([#21](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/21))
- Fix errors when monitor_iam_access is null ([#19](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/19))
- Add condition to audit AWS Config Aggregate Auth ([#20](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/20))

## v0.1.0 - 2020-11-16

- Adds optional SCP to restrict allowed regions ([#11](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/11))
- Adds support for optional AWS Config Aggregate Authorization ([#10](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/10))
- Enables AWS Config in the master account ([#9](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/9))
- Adds support for custom tags to AVM module ([#8](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/8))
- Adds support for passing SSH Key Id to TFE workspace ([#7](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/7))
- Adds output to AVM module ([#6](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/6))
- Adds support for AWS-Datadog integration ([#5](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/5))
- Adds support for AWS Config Rules ([#4](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/4))
- Enables security hub for all AWS Organization accounts ([#3](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/3))
- Removes embedded Okta Groups ([#2](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/2))
- First version ([#1](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/1))
