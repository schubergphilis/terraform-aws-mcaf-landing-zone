locals {
  aws_okta_groups = merge(
    var.aws_okta_groups,
    {
      "AWSPlatformAdmins" = "AWS administrator access to all stacks/accounts"
    }
  )
}

resource "okta_app_saml" "aws_sso" {
  groups            = [for group in okta_group.aws_groups : group.id]
  key_years_valid   = 3
  label             = "Amazon Web Services"
  preconfigured_app = "amazon_aws_sso"

  app_settings_json = templatefile("${path.module}/files/okta/app_settings.json.tpl", {
    acsURL   = var.aws_sso_acs_url
    entityID = var.aws_sso_entity_id
  })

  lifecycle {
    ignore_changes = [features, users]
  }
}

resource "okta_group" "aws_groups" {
  for_each    = local.aws_okta_groups
  name        = each.key
  description = each.value
}
