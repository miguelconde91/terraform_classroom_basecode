locals {
  ecs_tags_asg_format = null_resource.ecs_tags_as_list_of_maps.*.triggers

  ecs_name_prefix    = "ecs"
}

resource "null_resource" "ecs_tags_as_list_of_maps" {
  count = length(keys(var.tags_ecs))

  triggers = {
    "key"                 = element(keys(var.tags_ecs), count.index)
    "value"               = element(values(var.tags_ecs), count.index)
    "propagate_at_launch" = "true"
  }
}