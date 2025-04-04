variables {

  control_tower_account_ids = {
    audit   = "012345678902"
    logging = "012345678903"
  }

  regions = {
    allowed_regions = ["eu-central-1"]
    home_region     = "eu-central-1"
  }
}

run "setup" {
  module {
    source = "./tests/setup"
  }
}

mock_provider "datadog" {}

mock_provider "aws" {
  mock_data "aws_region" {
    defaults = {
      name = "eu-central-1"
    }
  }

  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "012345678901"
    }
  }

  mock_data "aws_organizations_organization" {
    defaults = {
      accounts = [
        {
          "arn" : "arn:aws:organizations::012345678901:account/o-ab1234cdef/012345678901",
          "email" : "core-master@example.com",
          "id" : "012345678901",
          "name" : "core-master",
          "status" : "ACTIVE"
        },
        {
          "arn" : "arn:aws:organizations::012345678901:account/o-ab1234cdef/012345678902",
          "email" : "core-audit@example.com",
          "id" : "012345678902",
          "name" : "core-audit",
          "status" : "ACTIVE"
        },
        {
          "arn" : "arn:aws:organizations::012345678901:account/o-ab1234cdef/012345678903",
          "email" : "core-logging@example.com",
          "id" : "012345678903",
          "name" : "core-logging",
          "status" : "ACTIVE"
        }
      ]

      roots = [
        {
          "arn" : "arn:aws:organizations::012345678901:root/o-ab1234cdef/r-12ac",
          "id" : "r-12ac",
          "name" : "Root",
          "policy_types" : [
            {
              "status" : "ENABLED",
              "type" : "SERVICE_CONTROL_POLICY"
            },
            {
              "status" : "ENABLED",
              "type" : "TAG_POLICY"
            }
          ]
        }
      ]
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\": \"2012-10-17\",\"Statement\": [{\"Sid\": \"Base Permissions\",\"Effect\": \"Allow\",\"Action\": \"kms:*\",\"Resource\": \"*\",\"Principal\": {\"AWS\": \"arn:aws:iam::012345678901:root\"}}]}"
    }
  }
}

mock_provider "aws" {
  alias = "audit"

  mock_data "aws_region" {
    defaults = {
      name = "eu-central-1"
    }
  }

  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "012345678902"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\": \"2012-10-17\",\"Statement\": [{\"Sid\": \"Base Permissions\",\"Effect\": \"Allow\",\"Action\": \"kms:*\",\"Resource\": \"*\",\"Principal\": {\"AWS\": \"arn:aws:iam::012345678902:root\"}}]}"
    }
  }

  mock_data "aws_sns_topic" {
    defaults = {
      arn = "arn:aws:sns:eu-central-1:012345678902:aws-controltower-AllConfigNotifications"
    }
  }
}

mock_provider "aws" {
  alias = "logging"

  mock_data "aws_region" {
    defaults = {
      name = "eu-central-1"
    }
  }

  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "012345678903"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\": \"2012-10-17\",\"Statement\": [{\"Sid\": \"Base Permissions\",\"Effect\": \"Allow\",\"Action\": \"kms:*\",\"Resource\": \"*\",\"Principal\": {\"AWS\": \"arn:aws:iam::012345678903:root\"}}]}"
    }
  }
}

mock_provider "mcaf" {
  mock_data "mcaf_aws_all_organizational_units" {
    defaults = {
      organizational_units = [
        {
          "id" : "ou-1234",
          "name" : "OU1"
        },
        {
          "id" : "ou-5678",
          "name" : "OU2"
        }
      ]
    }
  }
}

run "datadog_integration_disabled" {
  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = length(module.datadog_master) == 0
    error_message = "The Datadog integration should be disabled"
  }

  assert {
    condition     = length(module.datadog_audit) == 0
    error_message = "The Datadog integration should be disabled"
  }

  assert {
    condition     = length(module.datadog_logging) == 0
    error_message = "The Datadog integration should be disabled"
  }
}

run "datadog_integration_disabled_by_boolean" {
  module {
    source = "./"
  }

  variables {
    datadog = {
      enable_integration = false
      site_url           = "datadoghq.eu"
    }
  }

  command = plan

  assert {
    condition     = length(module.datadog_master) == 0
    error_message = "The Datadog integration should be disabled"
  }

  assert {
    condition     = length(module.datadog_audit) == 0
    error_message = "The Datadog integration should be disabled"
  }

  assert {
    condition     = length(module.datadog_logging) == 0
    error_message = "The Datadog integration should be disabled"
  }
}

run "datadog_integration_enabled_api_key" {
  module {
    source = "./"
  }

  variables {
    datadog = {
      api_key               = "12345678901234567890123456789012"
      enable_integration    = true
      install_log_forwarder = true
      log_forwarder_version = "latest"
      site_url              = "datadoghq.eu"
    }
  }

  command = plan

  assert {
    condition     = length(module.datadog_master) == 1
    error_message = "The Datadog integration should be enabled"
  }

  assert {
    condition     = length(module.datadog_audit) == 1
    error_message = "The Datadog integration should be enabled"
  }

  assert {
    condition     = length(module.datadog_logging) == 1
    error_message = "The Datadog integration should be enabled"
  }
}

run "datadog_integration_enabled_create_api_key" {
  module {
    source = "./"
  }

  variables {
    datadog = {
      api_key               = null
      create_api_key        = true
      enable_integration    = true
      install_log_forwarder = true
      log_forwarder_version = "latest"
      site_url              = "datadoghq.eu"
    }
  }

  command = plan

  assert {
    condition     = length(module.datadog_master) == 1
    error_message = "The Datadog integration should be enabled"
  }

  assert {
    condition     = length(module.datadog_audit) == 1
    error_message = "The Datadog integration should be enabled"
  }

  assert {
    condition     = length(module.datadog_logging) == 1
    error_message = "The Datadog integration should be enabled"
  }
}
