# AWS AVM (Account Vending Machine)

Terraform module to provision an AWS account with a TFE workspace backed by a VCS project.

## Datadog Integration

This module supports an optional Datadog-AWS integration. This integration makes it easier for you to forward metrics and logs from your AWS account to Datadog.

In order to enable the integration, you will need to set the variable `datadog_integration` to `true` and provide a Datadog API Key using the variable `datadog_api_key`. If you would also like to forward logs to Datadog, you can set the variable `datadog_install_log_forwarder` to `true`.

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
| email | Email address of the account | `string` | `null` | no |
| environment | Stack environment | `string` | `null` | no |
| kms\_key\_id | The KMS key ID used to encrypt the SSM parameters | `string` | `null` | no |
| organizational\_unit | Organizational Unit to place account in | `string` | `null` | no |
| provisioned\_product\_name | A custom name for the provisioned product | `string` | `null` | no |
| region | The default region of the account | `string` | `"eu-west-1"` | no |
| sso\_firstname | The firstname of the Control Tower SSO account | `string` | `"AWS Control Tower"` | no |
| sso\_lastname | The lastname of the Control Tower SSO account | `string` | `"Admin"` | no |
| terraform\_auto\_apply | Whether to automatically apply changes when a Terraform plan is successful | `bool` | `false` | no |
| terraform\_version | Terraform version to use | `string` | `null` | no |
| tfe\_vcs\_branch | Terraform VCS branch to use | `string` | `"master"` | no |
| trigger\_prefixes | List of repository-root-relative paths which should be tracked for changes | `list(string)` | <pre>[<br>  "modules"<br>]</pre> | no |

## Outputs

No output.

<!--- END_TF_DOCS --->
