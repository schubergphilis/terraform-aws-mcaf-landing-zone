locals {
  aws_config_aggregators = flatten([
    for account in toset(concat(try(var.aws_config.aggregator_account_ids, []), [var.control_tower_account_ids.audit])) : [
      for region in toset(concat(try(var.aws_config.aggregator_regions, []), ["eu-central-1", "eu-west-1"])) : {
        account_id = account
        region     = region
      }
    ]
  ])
  aws_config_rules = concat(
    try(var.aws_config.rule_identifiers, []),
    [
      "CLOUD_TRAIL_ENABLED",
      "ENCRYPTED_VOLUMES",
      "ROOT_ACCOUNT_MFA_ENABLED",
      "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
    ]
  )
}
