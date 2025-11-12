variable "additional_auditing_trail" {
  type = object({
    name       = string
    bucket     = string
    kms_key_id = string

    event_selector = optional(object({
      data_resource = optional(object({
        type   = string
        values = list(string)
      }))
      exclude_management_event_sources = optional(set(string), null)
      include_management_events        = optional(bool, true)
      read_write_type                  = optional(string, "All")
    }))
  })
  default     = null
  description = "CloudTrail configuration for additional auditing trail"
}

variable "aws_aiservices_opt_out_policy_enabled" {
  type        = bool
  default     = true
  description = "Enable the AWS AI Services Opt-Out Policy at the organization level to prevent AWS from using your content for model training."
}

variable "aws_auditmanager" {
  type = object({
    enabled               = bool
    reports_bucket_prefix = string
  })
  default = {
    enabled               = true
    reports_bucket_prefix = "audit-manager-reports"
  }
  description = "AWS Audit Manager config settings"
}

variable "aws_config" {
  type = object({
    aggregator_account_ids          = optional(list(string), [])
    delivery_channel_s3_bucket_name = optional(string, null)
    delivery_channel_s3_key_prefix  = optional(string, null)
    delivery_frequency              = optional(string, "TwentyFour_Hours")
    rule_identifiers                = optional(list(string), [])
  })
  default = {
    aggregator_account_ids          = []
    delivery_channel_s3_bucket_name = null
    delivery_channel_s3_key_prefix  = null
    delivery_frequency              = "TwentyFour_Hours"
    rule_identifiers                = []
  }
  description = "AWS Config settings"

  validation {
    condition     = contains(["One_Hour", "Three_Hours", "Six_Hours", "Twelve_Hours", "TwentyFour_Hours"], var.aws_config.delivery_frequency)
    error_message = "The delivery frequency must be set to \"One_Hour\", \"Three_Hours\", \"Six_Hours\", \"Twelve_Hours\", or \"TwentyFour_Hours\"."
  }
}

variable "aws_config_sns_subscription" {
  type = map(object({
    endpoint = string
    protocol = string
  }))
  default     = {}
  description = "Subscription options for the aws-controltower-AggregateSecurityNotifications (AWS Config) SNS topic"
}

variable "aws_core_accounts_baseline_settings" {
  type = object({
    ebs_encryption_by_default               = optional(bool, true)
    ebs_snapshot_block_public_access_state  = optional(string, "block-new-sharing")
    ec2_image_block_public_access_state     = optional(string, "block-new-sharing")
    ssm_documents_public_sharing_permission = optional(string, "Disable")

    account_password_policy = optional(object({
      allow_users_to_change        = optional(bool, true)
      max_age                      = optional(number, 90)
      minimum_length               = optional(number, 14)
      require_lowercase_characters = optional(bool, true)
      require_numbers              = optional(bool, true)
      require_symbols              = optional(bool, true)
      require_uppercase_characters = optional(bool, true)
      reuse_prevention_history     = optional(number, 24)
    }), {})
  })

  default     = {}
  description = "Consolidated settings for mcaf-account-baseline configuration used across core accounts."
}

variable "aws_guardduty" {
  type = object({
    enabled                       = optional(bool, true)
    finding_publishing_frequency  = optional(string, "FIFTEEN_MINUTES")
    ebs_malware_protection_status = optional(bool, true)
    eks_audit_logs_status         = optional(bool, true)
    lambda_network_logs_status    = optional(bool, true)
    rds_login_events_status       = optional(bool, true)
    s3_data_events_status         = optional(bool, true)
    runtime_monitoring_status = optional(object({
      enabled                             = optional(bool, true)
      eks_addon_management_status         = optional(bool, true)
      ecs_fargate_agent_management_status = optional(bool, true)
      ec2_agent_management_status         = optional(bool, true)
    }), {})
  })
  default     = {}
  description = "AWS GuardDuty settings"
}

variable "aws_inspector" {
  type = object({
    enabled                     = optional(bool, false)
    enable_scan_ec2             = optional(bool, true)
    enable_scan_ecr             = optional(bool, true)
    enable_scan_lambda          = optional(bool, true)
    enable_scan_lambda_code     = optional(bool, true)
    excluded_member_account_ids = optional(list(string), [])
    resource_create_timeout     = optional(string, "15m")
  })
  default     = {}
  description = "AWS Inspector settings, at least one of the scan options must be enabled"
}

variable "aws_required_tags" {
  type = map(list(object({
    name         = string
    values       = optional(list(string))
    enforced_for = optional(list(string))
  })))
  default     = null
  description = "AWS Required tags settings"

  validation {
    condition     = var.aws_required_tags != null ? alltrue([for taglist in var.aws_required_tags : length(taglist) <= 10]) : true
    error_message = "A maximum of 10 tag keys can be supplied to stay within the maximum policy length."
  }
}

variable "aws_security_hub" {
  type = object({
    aggregator_linking_mode      = optional(string, "SPECIFIED_REGIONS")
    auto_enable_controls         = optional(bool, true)
    control_finding_generator    = optional(string, "SECURITY_CONTROL")
    create_cis_metric_filters    = optional(bool, true)
    disabled_control_identifiers = optional(list(string), null)
    enabled_control_identifiers  = optional(list(string), null)
    product_arns                 = optional(list(string), [])
    standards_arns               = optional(list(string), null)
  })
  default     = {}
  description = "AWS Security Hub settings"

  validation {
    condition     = contains(["SECURITY_CONTROL", "STANDARD_CONTROL"], var.aws_security_hub.control_finding_generator)
    error_message = "The \"control_finding_generator\" variable must be set to either \"SECURITY_CONTROL\" or \"STANDARD_CONTROL\"."
  }

  validation {
    condition     = contains(["SPECIFIED_REGIONS", "ALL_REGIONS"], var.aws_security_hub.aggregator_linking_mode)
    error_message = "The \"aggregator_linking_mode\" variable must be set to either \"SPECIFIED_REGIONS\" or \"ALL_REGIONS\"."
  }

  validation {
    condition     = try(length(var.aws_security_hub.enabled_control_identifiers), 0) == 0 || try(length(var.aws_security_hub.disabled_control_identifiers), 0) == 0
    error_message = "Only one of \"enabled_control_identifiers\" or \"disabled_control_identifiers\" variable can be set."
  }
}

variable "aws_security_hub_sns_subscription" {
  type = map(object({
    endpoint = string
    protocol = string
  }))
  default     = {}
  description = "Subscription options for the LandingZone-SecurityHubFindings SNS topic"
}

variable "aws_service_control_policies" {
  type = object({
    aws_deny_disabling_security_hub = optional(bool, true)
    aws_deny_leaving_org            = optional(bool, true)
    aws_deny_root_user_ous          = optional(list(string), [])
    aws_require_imdsv2              = optional(bool, true)
    principal_exceptions            = optional(list(string), [])
  })
  default     = {}
  description = "AWS SCP's parameters to disable required/denied policies, set a list of allowed AWS regions, and set principals that are exempt from the restriction"
}

variable "aws_sso_permission_sets" {
  type = map(object({
    assignments = list(object({
      account_id   = string
      account_name = string
      sso_groups   = list(string)
    }))
    inline_policy       = optional(string, null)
    managed_policy_arns = optional(list(string), [])
    session_duration    = optional(string, "PT4H")
  }))
  default     = {}
  description = "Map of AWS IAM Identity Center permission sets with AWS accounts and group names that should be granted access to each account"
}

variable "control_tower_account_ids" {
  type = object({
    audit   = string
    logging = string
  })
  description = "Control Tower core account IDs"
}

variable "datadog" {
  type = object({
    api_key                              = optional(string, null)
    api_key_name_prefix                  = optional(string, "aws-landing-zone-")
    create_api_key                       = optional(bool, false)
    cspm_resource_collection_enabled     = optional(bool, false)
    enable_integration                   = bool
    extended_resource_collection_enabled = optional(bool, false)
    install_log_forwarder                = optional(bool, false)
    log_collection_services              = optional(list(string), [])
    log_forwarder_version                = optional(string)
    metric_tag_filters                   = optional(map(string), {})
    namespace_rules                      = optional(list(string), [])
    site_url                             = string
  })
  default     = null
  description = "Datadog integration options for the core accounts"

  validation {
    condition = (
      # Either Datadog integration config is not supplied = disabled
      var.datadog == null ||
      # Or it's directly disabled
      try(var.datadog.enable_integration, false) == false ||
      # Or it's enabled but the log forwarder is disabled (API key not needed)
      (try(var.datadog.enable_integration, false) && try(var.datadog.install_log_forwarder, false) == false) ||
      # Or the API key is supplied
      try(length(var.datadog.api_key), 0) > 0 ||
      # Or the API key will be created
      try(var.datadog.create_api_key, false)
    )

    error_message = "If Datadog integration is enabled, either an API key must be provided or the 'create_api_key' option must be set to true."
  }
}

variable "datadog_excluded_regions" {
  type        = list(string)
  description = "List of regions where metrics collection will be disabled."
  default     = []
}

variable "kms_key_policies_by_region" {
  type        = map(list(string))
  default     = {}
  description = "core-management key: region => list of extra policy JSON docs to merge."
}

variable "kms_key_policies_audit_by_region" {
  type        = map(list(string))
  default     = {}
  description = "core-audit key: region => list of extra policy JSON docs to merge."
}

variable "kms_key_policies_logging_by_region" {
  type        = map(list(string))
  default     = {}
  description = "core-logging key: region => list of extra policy JSON docs to merge."
}

variable "monitor_iam_activity" {
  type        = bool
  default     = true
  description = "Whether IAM activity should be monitored"
}

variable "monitor_iam_activity_sns_subscription" {
  type = map(object({
    endpoint = string
    protocol = string
  }))
  default     = {}
  description = "Subscription options for the LandingZone-IAMActivity SNS topic"
}

variable "regions" {
  type = object({
    additional_allowed_service_actions_per_region    = optional(map(list(string)), {})
    allowed_regions                                  = optional(list(string), []) # Allowed regions within your AWS Organization, defaults to your `home_region`.
    enable_cdk_service_actions                       = optional(bool, false)
    enable_edge_service_actions                      = optional(bool, false)
    enable_security_lake_aggregation_service_actions = optional(bool, false)
    home_region                                      = string                                # AWS Control Tower home region.
    linked_regions                                   = optional(list(string), ["us-east-1"]) # AWS Control Tower governed regions.
  })
  description = "Region configuration, plus global and per-region service SCP exceptions. See the README for more information on the configuration options."

  validation {
    condition     = length(var.regions.linked_regions) > 0
    error_message = "The 'linked_regions' list must include at least one region. By default, 'us-east-1' is specified to ensure the tracking of global resources. Please specify at least one region if overriding the default."
  }

  validation {
    condition = alltrue([
      for region in keys(var.regions.additional_allowed_service_actions_per_region) :
      !contains(var.regions.allowed_regions, region)
    ])
    error_message = "You cannot specify 'additional_allowed_service_actions_per_region' for a region already in 'allowed_regions'. The 'allowed_regions' list already grants full service-action access there, so any per-region overrides must only target regions not listed in 'allowed_regions'."
  }
}

variable "path" {
  type        = string
  default     = "/"
  description = "Optional path for all IAM users, user groups, roles, and customer managed policies created by this module"
}

variable "ses_root_accounts_mail_forward" {
  type = object({
    domain            = string
    from_email        = string
    recipient_mapping = map(any)

    dmarc = object({
      policy = optional(string)
      rua    = optional(string)
      ruf    = optional(string)
    })
  })
  default     = null
  description = "SES config to receive and forward root account emails"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Map of tags"
}
