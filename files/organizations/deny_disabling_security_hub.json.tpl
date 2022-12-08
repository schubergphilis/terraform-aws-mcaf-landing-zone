{
    "Version": "2012-10-17",
    "Statement": {
        "Sid": "DenyDisablingSecurityHub",
        "Effect": "Deny",
        "Action": [
            "securityhub:DeleteInvitations",
            "securityhub:DisableSecurityHub",
            "securityhub:DisassociateFromMasterAccount",
            "securityhub:DeleteMembers",
            "securityhub:DisassociateMembers",
            "securityhub:BatchDisableStandards"
        ],
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
