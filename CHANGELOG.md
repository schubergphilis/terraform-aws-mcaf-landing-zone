# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

## 0.2.0 (2020-11-20)

ENHANCEMENTS

* Add support for AWS GuardDuty ([#12](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/12))
* Modify terraform-aws-mcaf-workspace version to 0.3.0 in the avm module, in order to prevent github error ([#22](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/22))
* Add KMS Key in the Audit account ([#18](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/18))
* Add support for monitoring IAM access ([#15](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/15))
* Add support for multiple AWS Config Aggregators ([#14](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/14))
* Add support for defining specific account name for AWS Service Catalog ([#13](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/13))
* Make account and email names more flexible. ([#17](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/17))

BUG FIXES

* Fix multiple bugs in unreleased features ([#23](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/23))
* Add filter to create rules only for the right identities ([#21](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/21))
* Fix errors when monitor_iam_access is null ([#19](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/19))
* Add condition to audit AWS Config Aggregate Auth ([#20](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/20))

## 0.1.0 (2020-11-16)

* Adds optional SCP to restrict allowed regions ([#11](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/11))
* Adds support for optional AWS Config Aggregate Authorization ([#10](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/10))
* Enables AWS Config in the master account ([#9](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/9))
* Adds support for custom tags to AVM module ([#8](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/8))
* Adds support for passing SSH Key Id to TFE workspace ([#7](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/7))
* Adds output to AVM module ([#6](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/6))
* Adds support for AWS-Datadog integration ([#5](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/5))
* Adds support for AWS Config Rules ([#4](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/4))
* Enables security hub for all AWS Organization accounts ([#3](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/3))
* Removes embedded Okta Groups ([#2](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/2))
* First version ([#1](https://github.com/schubergphilis/terraform-aws-mcaf-landing-zone/pull/1))
