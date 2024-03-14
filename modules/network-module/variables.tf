#####################
# Network vars      #
#####################

variable "environment" {

}

variable "vpc_cdir" {

}

variable "availability_zone_name" {

}

variable "cidr_block" {

}

variable "tags_network" {

}

variable "sufix_name_resource" {

}

variable "log_standard_ia_days" {
  description = "Number of days before moving logs to IA Storage"
  default     = 30
}

variable "log_glacier_days" {
  description = "Number of days before moving logs to Glacier"
  default     = 60
}

variable "log_expiry_days" {
  description = "Number of days before logs expiration"
  default     = 90
}