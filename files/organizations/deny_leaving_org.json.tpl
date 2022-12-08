{
  "Version": "2012-10-17",
  "Statement": {
    "Sid": "DenyLeavingOrg",
    "Effect": "Deny",
    "Action": "organizations:LeaveOrganization",
    "Resource": "*",
    "Condition": {
        %{ if length(exceptions) > 0 ~}
        "ArnNotLike": {
            "aws:PrincipalARN": ${jsonencode(exceptions)}
        }
        %{ endif ~}
    }
  }
}
