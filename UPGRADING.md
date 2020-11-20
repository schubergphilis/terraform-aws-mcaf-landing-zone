# Upgrading from v0.1.x to v0.2.x

This section describes changes to be aware of when upgrading from v0.1.x to v0.2.x.

## Enhancements

### AWS Config Aggregator Accounts

Since version `0.2.x` supports multiple account IDs when configuring AWS Config Aggregator accounts, the identifier given to the multiple `aws_config_aggregate_authorization` resources had to change from `region_name` to `account_id-region_name`. This causes the authorizations created by version `0.1.x` to be destroyed and recreated with the new identifiers.

### AWS GuardDuty

In order to enable GuardDuty for the entire organization, all existing accounts except for the `master` and `logging` accounts have to be add as members in the `audit` account like explained [here](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_organizations.html#guardduty_add_orgs_accounts). If this step is not taken, only the core accounts will have GuardDuty enabled.

### TFE Workspaces

TFE Workspaces use version [0.3.0 of the terraform-aws-mcaf-workspace](https://github.com/schubergphilis/terraform-aws-mcaf-workspace/tree/v0.3.0) module which by default creates a Terraform backend file in the repository associated with the workspace.
