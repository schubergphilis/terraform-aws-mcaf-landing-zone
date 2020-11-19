locals {
  aws_config_aggregators = flatten([
    for account in toset(try(var.aws_config.aggregator_account_ids, [])) : [
      for region in toset(try(var.aws_config.aggregator_regions, [])) : {
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
  monitor_iam_access = merge(
    {
      for identity in coalesce(var.monitor_iam_access, []) : identity.name => {
        "account" = identity.account
        "userIdentity" = {
          "type"     = [identity.type]
          "userName" = [identity.name]
        }
      } if identity.type == "IAMUser"
    },
    {
      for identity in coalesce(var.monitor_iam_access, []) : identity.name => {
        "account" = identity.account
        "userIdentity" = {
          "type" = [identity.type]
          "sessionContext" = {
            "sessionIssuer" = {
              "userName" = [identity.name]
            }
          }
        }
      } if identity.type == "AssumedRole"
    },
    {
      "Root" = {
        "userIdentity" = {
          "Root" = {
            "type" = ["Root"]
          }
        }
      }
    }
  )
}
