// AWS IAM Access Analyzer - Management account configuration
resource "aws_organizations_delegated_administrator" "access_analyzer" {
  count = var.aws_access_analyzer.external_access_enabled || var.aws_access_analyzer.unused_access_enabled ? 1 : 0

  account_id        = var.control_tower_account_ids.audit
  service_principal = "access-analyzer.amazonaws.com"
}

// AWS IAM Access Analyzer - External access analyzer (CIS IAM.28)
// External access findings are based on regional resource policies, so an
// organization-wide analyzer is created in every governed region within the audit account.
// https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-getting-started.html
resource "aws_accessanalyzer_analyzer" "external_access" {
  for_each = var.aws_access_analyzer.external_access_enabled ? local.all_governed_regions : []

  provider = aws.audit

  region        = each.key
  analyzer_name = "${var.aws_access_analyzer.analyzer_name_prefix}-external-access"
  type          = "ORGANIZATION"
  tags          = var.tags

  depends_on = [aws_organizations_delegated_administrator.access_analyzer]
}

// AWS IAM Access Analyzer - Unused access analyzer
// Unused access analyzes IAM users and roles, which are global, so a single analyzer
// in the home region provides full coverage without multiplying cost across regions.
resource "aws_accessanalyzer_analyzer" "unused_access" {
  count = var.aws_access_analyzer.unused_access_enabled ? 1 : 0

  provider = aws.audit

  region        = var.regions.home_region
  analyzer_name = "${var.aws_access_analyzer.analyzer_name_prefix}-unused-access"
  type          = "ORGANIZATION_UNUSED_ACCESS"
  tags          = var.tags

  configuration {
    unused_access {
      unused_access_age = var.aws_access_analyzer.unused_access_age
    }
  }

  depends_on = [aws_organizations_delegated_administrator.access_analyzer]
}
