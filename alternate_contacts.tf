resource "null_resource" "enable_aws_service_access_account_management" {
  provisioner "local-exec" {
    command = "aws organizations enable-aws-service-access --service-principal account.amazonaws.com"
  }
}

resource "aws_account_alternate_contact" "operations" {
  for_each = toset([for account in data.aws_organizations_organization.default.accounts : account.id])

  account_id             = each.value
  alternate_contact_type = "OPERATIONS"
  email_address          = var.alternate_contacts.operations.email_address
  name                   = var.alternate_contacts.operations.name
  phone_number           = var.alternate_contacts.operations.phone_number
  title                  = var.alternate_contacts.operations.title
}

resource "aws_account_alternate_contact" "billing" {
  for_each = toset([for account in data.aws_organizations_organization.default.accounts : account.id])

  account_id             = each.value
  alternate_contact_type = "BILLING"
  email_address          = var.alternate_contacts.billing.email_address
  name                   = var.alternate_contacts.billing.name
  phone_number           = var.alternate_contacts.billing.phone_number
  title                  = var.alternate_contacts.billing.title
}

resource "aws_account_alternate_contact" "security" {
  for_each = toset([for account in data.aws_organizations_organization.default.accounts : account.id])

  account_id             = each.value
  alternate_contact_type = "SECURITY"
  email_address          = var.alternate_contacts.security.email_address
  name                   = var.alternate_contacts.security.name
  phone_number           = var.alternate_contacts.security.phone_number
  title                  = var.alternate_contacts.security.title
}
