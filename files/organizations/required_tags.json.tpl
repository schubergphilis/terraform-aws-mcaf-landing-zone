tags = {
  %{ for tag in tags ~}
  ${tag.name} = {
    tag_key = {
      @@assign = "${tag.name}"
      @@operators_allowed_for_child_policies = ["@@none"]
    }
    %{ if try(tag.values, [] ) != [] }
    tag_value = {
      @@assign = ${jsonencode(tag.values)}
    }
    %{ endif ~}
    }
  %{ endfor ~}
}
