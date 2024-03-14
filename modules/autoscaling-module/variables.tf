#################
# Variables     #
#################

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type = string
}

variable "memory_value_to_scale" {
  type    = string
}

variable "cpu_value_to_scale" {
  type    = string
}

variable "ms_classroom" {
  type = string
}

variable "max_containers" {
  
}

variable "min_containers" {
  
}