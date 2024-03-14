##############
#   Output   #
##############

output "classroom_service" {
    value = aws_ecs_service.classroom_service.name
}