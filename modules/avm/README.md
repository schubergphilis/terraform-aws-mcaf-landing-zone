# AWS AVM (Account Vending Machine)

Terraform module to provision an AWS account with a TFE workspace backed by a VCS project.

## Datadog Integration

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

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | ~> 3.7.0 |
| datadog | ~> 2.14 |
| github | ~> 3.1.0 |
| mcaf | ~> 0.1.0 |
| tfe | ~> 0.21.0 |

## Providers

| Name | Version |
|------|---------|
| aws.managed\_by\_inception | ~> 3.7.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| defaults | Default options for this module | <pre>object({<br>    account_prefix         = string<br>    github_organization    = string<br>    sso_email              = string<br>    terraform_organization = string<br>    terraform_version      = string<br>  })</pre> | n/a | yes |
| name | Stack name | `string` | n/a | yes |
| oauth\_token\_id | The OAuth token ID of the VCS provider | `string` | n/a | yes |
| datadog | Datadog integration options | <pre>object({<br>    api_key               = string<br>    enable_integration    = bool<br>    install_log_forwarder = bool<br>  })</pre> | `null` | no |
| email | Email address of the account | `string` | `null` | no |
| environment | Stack environment | `string` | `null` | no |
| kms\_key\_id | The KMS key ID used to encrypt the SSM parameters | `string` | `null` | no |
| organizational\_unit | Organizational Unit to place account in | `string` | `null` | no |
| provisioned\_product\_name | A custom name for the provisioned product | `string` | `null` | no |
| region | The default region of the account | `string` | `"eu-west-1"` | no |
| ssh\_key\_id | The SSH key ID to assign to the TFE workspace | `string` | `null` | no |
| sso\_firstname | The firstname of the Control Tower SSO account | `string` | `"AWS Control Tower"` | no |
| sso\_lastname | The lastname of the Control Tower SSO account | `string` | `"Admin"` | no |
| terraform\_auto\_apply | Whether to automatically apply changes when a Terraform plan is successful | `bool` | `false` | no |
| terraform\_version | Terraform version to use | `string` | `null` | no |
| tfe\_vcs\_branch | Terraform VCS branch to use | `string` | `"master"` | no |
| trigger\_prefixes | List of repository-root-relative paths which should be tracked for changes | `list(string)` | <pre>[<br>  "modules"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The AWS account ID |
| workspace\_id | The TFE workspace ID |

<!--- END_TF_DOCS --->
