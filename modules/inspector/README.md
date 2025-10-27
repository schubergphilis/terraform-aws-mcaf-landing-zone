# Amazon Inspector

This module enables Amazon Inspector across all accounts in an AWS Organization, following the AWS-recommended delegated administrator model.

Inspector operates as a Regional service — meaning the delegated administrator must be configured per region.  

The setup uses two providers:

- `aws.management` → the management (payer) account, which designates the delegated Inspector administrator.  
- `aws.delegated_admin` → the delegated administrator account, where Inspector is actually managed and organization-wide features are enabled.

For detailed background on how Inspector integrates with AWS Organizations, see the AWS documentation:  
🔗 [Inspector and AWS Organizations (AWS Docs)](https://docs.aws.amazon.com/inspector/latest/user/designating-admin.html)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->