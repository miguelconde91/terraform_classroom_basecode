###################
# MS_classroom_API   #
###################

resource "aws_appautoscaling_target" "ecs_target_ms_classroom_api" {
  max_capacity       = var.max_containers
  min_capacity       = var.min_containers
  resource_id        = "service/${var.cluster_name}/${var.ms_classroom}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "policy_ms_classroom_api_cpu" {
  name = "MS-Classroom-Scale-CPU"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.ecs_target_ms_classroom_api.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target_ms_classroom_api.scalable_dimension
  service_namespace = aws_appautoscaling_target.ecs_target_ms_classroom_api.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.cpu_value_to_scale
    disable_scale_in = false
    #Time before add new replica
    scale_out_cooldown = 300
    #Time before delete new replica
    scale_in_cooldown = 600
    predefined_metric_specification{
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "policy_ms_classroom_api_memory" {
  name = "MS-Classroom-Scale-Memory"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.ecs_target_ms_classroom_api.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target_ms_classroom_api.scalable_dimension
  service_namespace = aws_appautoscaling_target.ecs_target_ms_classroom_api.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.memory_value_to_scale
    disable_scale_in = false
    #Time before add new replica
    scale_out_cooldown = 300
    #Time before delete new replica
    scale_in_cooldown = 600
    predefined_metric_specification{
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}
