${jsonencode({
    tags = {
      for tag in tags : tag.name => {
        tag_key = {
          "@@assign" = tag.name
          "@@operators_allowed_for_child_policies" = ["@@none"]
        },
        tag_value = {
          "@@assign" = tag.values
        }
      }
    }
})}
