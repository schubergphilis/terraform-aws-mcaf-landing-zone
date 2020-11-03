resource "okta_app_saml" "aws_sso" {
  groups            = toset(var.aws_okta_group_ids)
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
