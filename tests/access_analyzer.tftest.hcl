variables {

  control_tower_account_ids = {
    audit   = "012345678902"
    logging = "012345678903"
  }

  regions = {
    home_region    = "eu-central-1"
    linked_regions = ["us-east-1"]
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
      region = "eu-central-1"
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
      region = "eu-central-1"
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

  mock_data "aws_resourcegroupstaggingapi_resources" {
    defaults = {
      resource_tag_mapping_list = [
        {
          resource_arn       = "arn:aws:s3:::aws-controltower-config-logs-012345678902-aaa-bbb"
          compliance_details = []
          tags = {
            "aws:cloudformation:logical-id" = "ConfigS3Bucket"
          }
        }
      ]
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
      region = "eu-central-1"
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

run "access_analyzer_enabled_by_default" {
  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = length(aws_organizations_delegated_administrator.access_analyzer) == 1
    error_message = "The audit account should be registered as the IAM Access Analyzer delegated administrator"
  }

  assert {
    condition     = length(aws_accessanalyzer_analyzer.external_access) == 2
    error_message = "An external access analyzer should be created in each governed region (2)"
  }

  assert {
    condition     = length(aws_accessanalyzer_analyzer.unused_access) == 0
    error_message = "The unused access analyzer should be disabled by default"
  }

  assert {
    condition     = length(aws_iam_service_linked_role.access_analyzer) == 1
    error_message = "The Access Analyzer service-linked role should be created in the management account"
  }
}

run "access_analyzer_unused_enabled" {
  module {
    source = "./"
  }

  variables {
    aws_access_analyzer = {
      unused_access_enabled = true
    }
  }

  command = plan

  assert {
    condition     = length(aws_accessanalyzer_analyzer.external_access) == 2
    error_message = "The external access analyzer should still be created in each governed region"
  }

  assert {
    condition     = length(aws_accessanalyzer_analyzer.unused_access) == 1
    error_message = "A single unused access analyzer should be created when enabled"
  }

  assert {
    condition     = aws_accessanalyzer_analyzer.unused_access[0].region == "eu-central-1"
    error_message = "The unused access analyzer should be created in the home region"
  }
}

run "access_analyzer_all_disabled" {
  module {
    source = "./"
  }

  variables {
    aws_access_analyzer = {
      external_access_enabled = false
      unused_access_enabled   = false
    }
  }

  command = plan

  assert {
    condition     = length(aws_organizations_delegated_administrator.access_analyzer) == 0
    error_message = "No delegated administrator should be registered when both analyzers are disabled"
  }

  assert {
    condition     = length(aws_accessanalyzer_analyzer.external_access) == 0
    error_message = "No external access analyzer should be created when disabled"
  }

  assert {
    condition     = length(aws_accessanalyzer_analyzer.unused_access) == 0
    error_message = "No unused access analyzer should be created when disabled"
  }

  assert {
    condition     = length(aws_iam_service_linked_role.access_analyzer) == 0
    error_message = "No service-linked role should be created when both analyzers are disabled"
  }
}

run "access_analyzer_service_linked_role_disabled" {
  module {
    source = "./"
  }

  variables {
    aws_access_analyzer = {
      create_service_linked_role = false
    }
  }

  command = plan

  assert {
    condition     = length(aws_iam_service_linked_role.access_analyzer) == 0
    error_message = "No service-linked role should be created when create_service_linked_role is false"
  }

  assert {
    condition     = length(aws_accessanalyzer_analyzer.external_access) == 2
    error_message = "The external access analyzer should still be created when the service-linked role is managed externally"
  }
}
