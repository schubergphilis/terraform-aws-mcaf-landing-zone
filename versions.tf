terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
    mcaf = {
      source = "schubergphilis/mcaf"
    }
  }
  required_version = ">= 1.0"
}