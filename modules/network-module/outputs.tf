##############
#   Output   #
##############

output "vpc_id" {
  value = aws_vpc.vpc.id
  description = "VPC ID of the environment."
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
  description = "VPC ID of the environment."
}

output "public_subnets_id" {
  value = [aws_subnet.publicsubnet1.id, aws_subnet.publicsubnet2.id, aws_subnet.publicsubnet3.id]
  description = "Public subnets IDs"
}

output "private_subnets_id" {
  value = [aws_subnet.privatesubnet1.id, aws_subnet.privatesubnet2.id, aws_subnet.privatesubnet3.id]
  description = "Private subnets IDs"
}

output "ecs_security_group" {
  value = aws_security_group.ecs_security_group.id
  description = "SG for ECS"
}

output "cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "aws_alb_listener" {
  value = aws_lb_listener.public_listener.arn
}
