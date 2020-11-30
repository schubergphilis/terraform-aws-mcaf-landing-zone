terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.16.0"
    }
    datadog = {
      source  = "datadog/datadog"
      version = "~> 2.14"
    }
    github = {
      source  = "hashicorp/github"
      version = "~> 3.1.0"
    }
    mcaf = {
      source = "schubergphilis/mcaf"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.21.0"
    }
  }
  required_version = ">= 0.13"
}
