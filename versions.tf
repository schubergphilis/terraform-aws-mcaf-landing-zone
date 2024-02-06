terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.25.0"
      configuration_aliases = [aws.audit, aws.logging]
    }
    datadog = {
      source  = "datadog/datadog"
      version = "> 3.0.0"
    }
    mcaf = {
      source  = "schubergphilis/mcaf"
      version = ">= 0.4.2"
    }
  }
  required_version = ">= 1.3"
}
