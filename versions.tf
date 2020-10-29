terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.7.0"
    }
    okta = {
      source  = "oktadeveloper/okta"
      version = "~> 3.0"
    }
  }
  required_version = ">= 0.13"
}
