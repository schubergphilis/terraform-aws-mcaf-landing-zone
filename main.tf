module "kms_key" {
  source      = "github.com/schubergphilis/terraform-aws-mcaf-kms?ref=v0.1.5"
  name        = "inception"
  description = "KMS key used for encrypting SSM parameters"
  tags        = var.tags
}

module "security_hub_master" {
  source = "./modules/security_hub"
}
