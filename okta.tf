locals {
  okta_groups = {
    "AWSPlatformAdmins" = {
      description = "AWS administrator access to all stacks/accounts"
    }
    "GitHubAccess" = {
      description = "Access to GitHub Organization"
    }
  }
}

resource "okta_app_saml" "aws_sso" {
  groups            = list(okta_group.groups["AWSPlatformAdmins"].id)
  key_years_valid   = 3
  label             = "Amazon Web Services"
  preconfigured_app = "amazon_aws_sso"

  app_settings_json = templatefile("${path.module}/okta_app_saml.json.tpl", {
    acsURL   = var.aws_sso_acs_url
    entityID = var.aws_sso_entity_id
  })

  lifecycle {
    ignore_changes = [features, users]
  }
}

resource "okta_group" "groups" {
  for_each    = local.okta_groups
  name        = each.key
  description = each.value.description
}
