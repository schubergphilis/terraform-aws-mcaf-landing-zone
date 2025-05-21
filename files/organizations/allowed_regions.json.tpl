{
  "Version": "2012-10-17",
  "Statement": [

    {
      "Sid": "DenyAllRegionsOutsideAllowedList",
      "Effect": "Deny",
      "NotAction": ${jsonencode(default_notactions)},
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": ${jsonencode(allowed)}
        },
        "ArnNotLike": {
          "aws:PrincipalARN": ${jsonencode(exceptions)}
        }
      }
    }%{ if length(regional_notactions) > 0 },%{ endif }

    %{ for region, notactions in regional_notactions }
    {
      "Sid": "DenyAllRegionsOutsideAllowedList_${region}",
      "Effect": "Deny",
      "NotAction": ${jsonencode(notactions)},
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": ["${region}"]
        },
        "ArnNotLike": {
          "aws:PrincipalARN": ${jsonencode(exceptions)}
        }
      }
    }%{ if region != keys(regional_notactions)[-1] },%{ endif }
    %{ endfor %}%{ if length(other_default_notactions) > 0 },%{ endif %}

    {
      "Sid": "DenyAllOtherRegions",
      "Effect": "Deny",
      "NotAction": ${jsonencode(other_default_notactions)},
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": ${jsonencode(allowed_plus_us_east)}
        },
        "ArnNotLike": {
          "aws:PrincipalARN": ${jsonencode(exceptions)}
        }
      }
    }%{ if length(other_regional_notactions) > 0 },%{ endif %}

    %{ for region, notactions in other_regional_notactions }
    {
      "Sid": "DenyAllOtherRegions_${region}",
      "Effect": "Deny",
      "NotAction": ${jsonencode(notactions)},
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": ["${region}"]
        },
        "ArnNotLike": {
          "aws:PrincipalARN": ${jsonencode(exceptions)}
        }
      }
    }%{ if region != keys(other_regional_notactions)[-1] },%{ endif %}
    %{ endfor %}

  ]
}
