locals {
  aws_account_emails = { for account in data.aws_organizations_organization.default.accounts : account.id => account.email }

  iam_activity = {
    SSO = "{$.readOnly IS FALSE && $.userIdentity.sessionContext.sessionIssuer.userName = \"AWSReservedSSO_*\" && $.eventName != \"ConsoleLogin\"}"
  }

  cloudtrail_activity_cis_aws_foundations = (local.security_hub_has_cis_aws_foundations_enabled && var.aws_security_hub.create_cis_metric_filters) ? {
    RootActivity                 = "{$.userIdentity.type=\"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\"}"
    UnauthorizedApiCalls         = "{($.errorCode=\"*UnauthorizedOperation\") || ($.errorCode=\"AccessDenied*\")}"
    IamPolicyChanges             = "{($.eventName=DeleteGroupPolicy) || ($.eventName=DeleteRolePolicy) || ($.eventName=DeleteUserPolicy) || ($.eventName=PutGroupPolicy) || ($.eventName=PutRolePolicy) || ($.eventName=PutUserPolicy) || ($.eventName=CreatePolicy) || ($.eventName=DeletePolicy) || ($.eventName=CreatePolicyVersion) || ($.eventName=DeletePolicyVersion) || ($.eventName=AttachRolePolicy) || ($.eventName=DetachRolePolicy) || ($.eventName=AttachUserPolicy) || ($.eventName=DetachUserPolicy) || ($.eventName=AttachGroupPolicy) || ($.eventName=DetachGroupPolicy)}"
    CloudTrailConfigChange       = "{($.eventName=CreateTrail) || ($.eventName=UpdateTrail) || ($.eventName=DeleteTrail) || ($.eventName=StartLogging) || ($.eventName=StopLogging)}"
    ManagementConsoleAuthFailure = "{($.eventName=ConsoleLogin) && ($.errorMessage=\"Failed authentication\")}"
    KmsKeyDisableOrDeletion      = "{($.eventSource=kms.amazonaws.com) && (($.eventName=DisableKey) || ($.eventName=ScheduleKeyDeletion))}"
    S3BucketPolicyChange         = "{($.eventSource=s3.amazonaws.com) && (($.eventName=PutBucketAcl) || ($.eventName=PutBucketPolicy) || ($.eventName=PutBucketCors) || ($.eventName=PutBucketLifecycle) || ($.eventName=PutBucketReplication) || ($.eventName=DeleteBucketPolicy) || ($.eventName=DeleteBucketCors) || ($.eventName=DeleteBucketLifecycle) || ($.eventName=DeleteBucketReplication))}"
    AwsConfigConfigChange        = "{($.eventSource=config.amazonaws.com) && (($.eventName=StopConfigurationRecorder) || ($.eventName=DeleteDeliveryChannel) || ($.eventName=PutDeliveryChannel) || ($.eventName=PutConfigurationRecorder))}"
    SecurityGroupChange          = "{($.eventName=AuthorizeSecurityGroupIngress) || ($.eventName=AuthorizeSecurityGroupEgress) || ($.eventName=RevokeSecurityGroupIngress) || ($.eventName=RevokeSecurityGroupEgress) || ($.eventName=CreateSecurityGroup) || ($.eventName=DeleteSecurityGroup)}"
    NaclChange                   = "{($.eventName=CreateNetworkAcl) || ($.eventName=CreateNetworkAclEntry) || ($.eventName=DeleteNetworkAcl) || ($.eventName=DeleteNetworkAclEntry) || ($.eventName=ReplaceNetworkAclEntry) || ($.eventName=ReplaceNetworkAclAssociation)}"
    NetworkGatewayChange         = "{($.eventName=CreateCustomerGateway) || ($.eventName=DeleteCustomerGateway) || ($.eventName=AttachInternetGateway) || ($.eventName=CreateInternetGateway) || ($.eventName=DeleteInternetGateway) || ($.eventName=DetachInternetGateway)}"
    RouteTableChange             = "{($.eventName=CreateRoute) || ($.eventName=CreateRouteTable) || ($.eventName=ReplaceRoute) || ($.eventName=ReplaceRouteTableAssociation) || ($.eventName=DeleteRouteTable) || ($.eventName=DeleteRoute) || ($.eventName=DisassociateRouteTable)}"
    VpcChange                    = "{($.eventName=CreateVpc) || ($.eventName=DeleteVpc) || ($.eventName=ModifyVpcAttribute) || ($.eventName=AcceptVpcPeeringConnection) || ($.eventName=CreateVpcPeeringConnection) || ($.eventName=DeleteVpcPeeringConnection) || ($.eventName=RejectVpcPeeringConnection) || ($.eventName=AttachClassicLinkVpc) || ($.eventName=DetachClassicLinkVpc) || ($.eventName=DisableVpcClassicLink) || ($.eventName=EnableVpcClassicLink)}"
  } : {}

  aws_service_control_policies_principal_exceptions = distinct(concat(var.aws_service_control_policies.principal_exceptions, ["arn:aws:iam::*:role/AWSControlTowerExecution"]))

  security_hub_standards_arns_default = [
    "arn:aws:securityhub:${data.aws_region.current.region}::standards/aws-foundational-security-best-practices/v/1.0.0",
    "arn:aws:securityhub:${data.aws_region.current.region}::standards/cis-aws-foundations-benchmark/v/1.4.0",
    "arn:aws:securityhub:${data.aws_region.current.region}::standards/pci-dss/v/3.2.1"
  ]

  security_hub_standards_arns = var.aws_security_hub.standards_arns != null ? var.aws_security_hub.standards_arns : local.security_hub_standards_arns_default

  security_hub_has_cis_aws_foundations_enabled = length(regexall(
    "cis-aws-foundations-benchmark/v", join(",", local.security_hub_standards_arns)
  )) > 0 ? true : false

  allowed_regions      = distinct(concat([var.regions.home_region], try(var.regions.linked_regions, [])))
  all_governed_regions = toset(distinct(concat([var.regions.home_region], var.regions.linked_regions, local.allowed_regions, [data.aws_region.current.region])))
}
