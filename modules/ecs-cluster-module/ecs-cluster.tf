#####################
# ECS data          #
#####################

data "template_file" "ecs_instances" {
  template = file("${path.module}/ecs_instances.sh")

  vars = {
    ecs_cluster             = var.cluster_name
    stack_name              = var.stack_name
    region                  = var.region
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn2-ami-ecs-hvm-*-x86_64-ebs",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}


#####################
# ECS resources     #
#####################

resource "aws_iam_role" "ecs_instances_role" {
  name = "Classroom-ECS-Instances-Role-${var.environment}"
  path = "/ecs/"
  tags = merge(var.tags_ecs)
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ecs_instances_profile" {
  name = "Classroom-ECS-Instances-Prof-${var.environment}"
  role = aws_iam_role.ecs_instances_role.name
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = aws_iam_role.ecs_instances_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role       = aws_iam_role.ecs_instances_role.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}


#ECS-Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
    name = var.cluster_name
    tags = merge(var.tags_ecs)
}

#Launch Templates for ECS instances
resource "aws_launch_template" "ecs_launch_template" {
  name_prefix = format("ecs-data-%s", var.environment)
  image_id        = data.aws_ami.amazon_linux.id
  instance_type   = var.ecs_instance_type
  key_name        = var.key_name
  vpc_security_group_ids = [ var.ecs_security_group_id ]
  
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instances_profile.id
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 50
      volume_type = "gp2"
    }
  }

  user_data = base64encode(data.template_file.ecs_instances.rendered)
}

#ECS Instances Autoscalling Group
resource "aws_autoscaling_group" "ecs-instances" {
    depends_on = [ aws_launch_template.ecs_launch_template ]
    name = format("ecs-instances-%s", var.stack_name)
    vpc_zone_identifier = [ var.private_subnets[0], var.private_subnets[1] ]
    launch_template {
      id      = aws_launch_template.ecs_launch_template.id
      version = "$Latest"
    }
    min_size = var.min_instances_count
    max_size = var.max_instances_count
    desired_capacity = var.desired_instances_count
    lifecycle {
       create_before_destroy = true
    }
    tag {
      key                 = "Environment"
      value               = var.environment
      propagate_at_launch = true
    }
    tag {
      key                 = "Project"
      value               = format("Classroom-%s", var.environment)
      propagate_at_launch = true
    }
    tag {
      key                 = "Name"
      value               = format("Classroom-ECS-%s", var.environment)
      propagate_at_launch = true
    }
    tag {
      key                 = "Orchestator"
      value               = "Terraform"
      propagate_at_launch = true
    }
    tag {
      key                 = "Deployment"
      value               = "1.0"
      propagate_at_launch = true
    }
    tag {
      key                 = "Module"
      value               = "ECS"
      propagate_at_launch = true
    }
}


resource "aws_autoscaling_policy" "ecs_policy_cpu" {
  name                   = "ecs-scaling-policy-cpu"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.ecs-instances.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_value_to_scale
    disable_scale_in = false
  }

}

resource "aws_autoscaling_policy" "ecs_policy_memory" {
  name                   = "ecs-scaling-policy-memory"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.ecs-instances.name
  target_tracking_configuration {
    customized_metric_specification {
      metric_dimension {
        name  = "ClusterName"
        value = var.cluster_name
      }

      metric_name = "MemoryUtilization"
      namespace   = "AWS/ECS"
      statistic   = "Average"
    }
    target_value = var.memory_value_to_scale
    disable_scale_in = false
  }
}

resource "aws_autoscaling_policy" "ecs_policy_memory-reserved" {
  name                   = "ecs-scaling-policy-memory-reserved"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.ecs-instances.name
  target_tracking_configuration {
    customized_metric_specification {
      metric_dimension {
        name  = "ClusterName"
        value = var.cluster_name
      }

      metric_name = "MemoryReservation"
      namespace   = "AWS/ECS"
      statistic   = "Average"
    }
    target_value = var.memory_value_to_scale
    disable_scale_in = false
  }
}

#LogGroup
resource "aws_cloudwatch_log_group" "classroom_service_logs" {
    name_prefix = "ECS-Classroom-${var.stack_name}"
    retention_in_days = 14
}

###########################
## Microservices section ##
###########################

#Classroom

resource "aws_lb_target_group" "tg_classroom_service" {
    name = "TG-Classroom-Service-${var.environment}"
    port = 8000
    protocol = "HTTP"
    vpc_id = var.vpc_id
    deregistration_delay = 300
    stickiness {
        type = "lb_cookie"
        enabled = true
    }
    health_check {
        enabled = true
        interval = 30
        path = "/api/v1/docs"
        port = "traffic-port"
        protocol = "HTTP"
        timeout = 10
        healthy_threshold = 2
        unhealthy_threshold = 5
    }
    tags = merge(var.tags_ecs)
}

resource "aws_lb_listener_rule" "lr_classroom_service" {
    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.tg_classroom_service.arn
    }
    condition {
        path_pattern {
            values = ["/api/v1/*"]
        }
    }
    listener_arn = var.aws_alb_listener
    priority = 10
}

resource "aws_ecs_task_definition" "td_classroom_service" {
    family = "TD-API-${var.stack_name}"
    network_mode = "bridge"
    tags = merge(var.tags_ecs)
    container_definitions = <<DEFINITION
    [
      {
        "name": "classroom-service",
        "image": "${var.docker_image}",
        "essential": true,
        "cpuReservation": 128,
        "memoryReservation": 768,
        "portMappings": [
          {
            "containerPort": 8000,
            "protocol": "tcp"
            }
           ],
         "environment": [
            {
              "name": "APP_VERSION",
              "value": "v1"
            }              
          ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${aws_cloudwatch_log_group.classroom_service_logs.name}",
            "awslogs-region": "${var.region}",
            "awslogs-stream-prefix": "classroom-service"
          }
        }
      }
    ]
    DEFINITION
}

resource "aws_ecs_service" "classroom_service" {
    depends_on = [ aws_lb_target_group.tg_classroom_service ]
    name = "classroom-service"
    cluster = aws_ecs_cluster.ecs_cluster.id
    deployment_maximum_percent = 200
    deployment_minimum_healthy_percent = 50
    desired_count = 1
    tags = merge(var.tags_ecs)
    load_balancer {
      target_group_arn = aws_lb_target_group.tg_classroom_service.arn
      container_name   = "classroom-service"
      container_port   = 8000
    }
    placement_constraints {
      type       = "memberOf"
      expression = "attribute:Classroom==True"
    }
    task_definition = aws_ecs_task_definition.td_classroom_service.arn
}
