### AWS Variables ###
variable "AWS_ACCESS_KEY_ID" {
 
}

variable "AWS_SECRET_ACCESS_KEY" {
  
}

variable "AWS_DEFAULT_REGION" {
  
}

####################
#   General vars   #
####################

variable "region" {
  
}

variable "instance_type" {
  type = string
}

variable "min_instances_count" {
  type = string
}

variable "max_instances_count" {
  type = string
}

variable "desired_instances_count" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "network_subnets_cidr_block" {
  type    = map
}

variable "network_availability_zone_name" {
  type    = map
}

variable "memory_value_to_scale_cluster" {
  description = "Max value allowed in % before to scale"
  type    = string
}

variable "cpu_value_to_scale_cluster" {
  description = "Max value allowed in % before to scale"
  type    = string
}

variable "memory_value_to_scale_services" {
  type    = string
  description = "Max value allowed in % before to scale"
}

variable "cpu_value_to_scale_services" {
  type    = string
  description = "Max value allowed before to scale"
}

variable "app_version" {
  
}

variable "max_containers" {
  
}

variable "min_containers" {

}

variable "docker_image" {
  
}