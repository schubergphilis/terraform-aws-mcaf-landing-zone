terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
      configuration_aliases = [
        aws.management,
        aws.delegated_admin
      ]
    }
  }

  required_version = ">= 1.3.0"
}
