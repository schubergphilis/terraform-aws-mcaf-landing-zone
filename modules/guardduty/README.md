# Amazon GuardDuty

This module enables Amazon GuardDuty across all accounts in an AWS Organization, following the AWS-recommended delegated administrator model.

GuardDuty operates as a Regional service — meaning the delegated administrator must be configured per region.  

The setup uses two providers:

- `aws.management` → the management (payer) account, which designates the delegated GuardDuty administrator.  
- `aws.delegated_admin` → the delegated administrator account, where GuardDuty is actually managed and organization-wide features are enabled.

For detailed background on how GuardDuty integrates with AWS Organizations, see the AWS documentation:  
🔗 [GuardDuty and AWS Organizations (AWS Docs)](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_organizations.html)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->