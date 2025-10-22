# Amazon GuardDuty

This module enables Amazon GuardDuty across all accounts in an AWS Organization, following the AWS-recommended delegated administrator model.

GuardDuty operates as a Regional service — meaning the delegated administrator must be configured per region.  

The setup uses two providers:

- `aws.management` → the management (payer) account, which designates the delegated GuardDuty administrator.  
- `aws.delegated_admin` → the delegated administrator account, where GuardDuty is actually managed and organization-wide features are enabled.

For detailed background on how GuardDuty integrates with AWS Organizations, see the AWS documentation:  
🔗 [GuardDuty and AWS Organizations (AWS Docs)](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_organizations.html)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.delegated_admin"></a> [aws.delegated\_admin](#provider\_aws.delegated\_admin) | >= 6.0.0 |
| <a name="provider_aws.management"></a> [aws.management](#provider\_aws.management) | >= 6.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_guardduty_detector.delegated_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector) | resource |
| [aws_guardduty_organization_admin_account.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account) | resource |
| [aws_guardduty_organization_configuration.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration) | resource |
| [aws_guardduty_organization_configuration_feature.ebs_malware_protection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration_feature) | resource |
| [aws_guardduty_organization_configuration_feature.eks_audit_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration_feature) | resource |
| [aws_guardduty_organization_configuration_feature.lambda_network_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration_feature) | resource |
| [aws_guardduty_organization_configuration_feature.rds_login_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration_feature) | resource |
| [aws_guardduty_organization_configuration_feature.runtime_monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration_feature) | resource |
| [aws_guardduty_organization_configuration_feature.s3_data_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration_feature) | resource |
| [aws_caller_identity.delegated_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ebs_malware_protection_status"></a> [ebs\_malware\_protection\_status](#input\_ebs\_malware\_protection\_status) | Whether EBS volume malware protection is enabled in GuardDuty. | `bool` | `true` | no |
| <a name="input_eks_audit_logs_status"></a> [eks\_audit\_logs\_status](#input\_eks\_audit\_logs\_status) | Whether EKS audit logs monitoring is enabled in GuardDuty. | `bool` | `true` | no |
| <a name="input_finding_publishing_frequency"></a> [finding\_publishing\_frequency](#input\_finding\_publishing\_frequency) | Frequency at which GuardDuty findings are published. | `string` | `"FIFTEEN_MINUTES"` | no |
| <a name="input_lambda_network_logs_status"></a> [lambda\_network\_logs\_status](#input\_lambda\_network\_logs\_status) | Whether Lambda network logs monitoring is enabled in GuardDuty. | `bool` | `true` | no |
| <a name="input_rds_login_events_status"></a> [rds\_login\_events\_status](#input\_rds\_login\_events\_status) | Whether RDS login events monitoring is enabled in GuardDuty. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region where the resources will be created. If omitted, the default provider region is used. | `string` | `null` | no |
| <a name="input_runtime_monitoring_status"></a> [runtime\_monitoring\_status](#input\_runtime\_monitoring\_status) | Runtime monitoring configuration for GuardDuty. | <pre>object({<br/>    enabled                             = optional(bool, true)<br/>    eks_addon_management_status         = optional(bool, true)<br/>    ecs_fargate_agent_management_status = optional(bool, true)<br/>    ec2_agent_management_status         = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_s3_data_events_status"></a> [s3\_data\_events\_status](#input\_s3\_data\_events\_status) | Whether S3 data event monitoring is enabled in GuardDuty. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->