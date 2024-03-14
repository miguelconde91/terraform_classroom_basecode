terraform {
    required_providers {
        aws = {
            source        = "hashicorp/aws"
            version       = "~> 5.40.0"
        }
    }

### Backend Configuration ###

### Local Backend configuration ###
/*  
  backend "local" {
    path = "/home/conde/Terraform-States/classroom.tfstate"
  }
}
*/

### Remote Backend using AWS S3 buckets ###

    backend "s3" {
      bucket              = "classroom-tfstate-stack"
      key                 = "testing"
      region              = "us-east-1"
      #dynamodb_table      = "classroom-tflock-stack"
      encrypt             = true
      shared_credentials_file = "/home/conde/.aws/credentials"
      profile             = "personal"
    }   
}   


### Remote Backend configuration for Terraform Cloud integration ###
/*   
    backend "remote" {
        hostname = "app.terraform.io"
        organization = "classroom"
        workspaces {
        name = "AWS-Infrastructure"
        }
    }    
}
*/


### HTTP Backend configuration for GitLab
/*
backend "http" {}
}
*/

### End Backend Configuration ###

###################################################################

### Provider Configuration ###

# Configure the AWS Provider for Cloud Terraform

provider "aws" {
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region = var.AWS_DEFAULT_REGION
}

# Configure the AWS Provider for local deployments 

#provider "aws" {
#  region  = var.AWS_DEFAULT_REGION
#  profile = "personal"
#}

### End Provider Configuration ###

###################################################################

#####################
# Network module    #
#####################

module "network" {
  source                  = "./modules/network-module"
  vpc_cdir                = var.vpc_cidr_block
  cidr_block              = var.network_subnets_cidr_block
  environment             = var.environment
  availability_zone_name  = var.network_availability_zone_name
  tags_network            = {
    Name                  = format("Classroom-Network-%s", var.environment)
    Project               = format("Classroom-%s", var.environment)
    Orchestator           = "Terraform"
    Deployment            = "1.0"
    Environment           = "${var.environment}"
    Module                = "Network"
  }
  sufix_name_resource     = "Classroom-${var.environment}"
}


################
# S3 module    #
################
/*
module "s3" {
  source                  = "./modules/s3-module"
  environment             = var.environment
  tags_s3                 = {
    Name                  = format("Classroom-S3-%s", var.environment)
    Project               = format("Classroom-%s", var.environment)
    Orchestator           = "Terraform"
    Deployment            = "1.0"
    Environment           = "${var.environment}"
    Module                = "S3"
  }
}
*/

#####################
# ECS module        #
#####################

module "ecs_cluster" {
  depends_on = [
    module.s3,
    module.network
  ]
  source                  = "./modules/ecs-cluster-module"
  ecs_instance_type       = "t2.small"
  cluster_name            = "classroom-ecs-${var.environment}"
  key_name                = "classroom-key-${var.environment}"
  stack_name              = "classroom-${var.environment}"
  instance_type           = var.instance_type
  cpu_value_to_scale      = var.cpu_value_to_scale_cluster
  memory_value_to_scale   = var.memory_value_to_scale_cluster
  environment             = var.environment
  max_instances_count     = var.max_instances_count
  min_instances_count     = var.min_instances_count
  desired_instances_count = var.desired_instances_count
  docker_image            = var.docker_image
  region                  = var.AWS_DEFAULT_REGION
  vpc_id                  = module.network.vpc_id
  vpc_cidr_block          = module.network.vpc_cidr_block
  private_subnets         = module.network.private_subnets_id
  public_subnets          = module.network.public_subnets_id
  ecs_security_group_id   = module.network.ecs_security_group
  aws_alb_listener        = module.network.aws_alb_listener
  
  tags_ecs                = {
    Name                  = format("Classroom-ECS-%s", var.environment)
    Project               = format("Classroom-%s", var.environment)
    Orchestator           = "Terraform"
    Deployment            = "1.0"
    Environment           = "${var.environment}"
    Module                = "ECS"    
  }
}


######################
# Autoscaling module #
######################

module "autoscaling" {
  depends_on              = [ module.ecs_cluster ]
  source                  = "./modules/autoscaling-module"
  cluster_name            = "classroom-ecs-${var.environment}"
  cpu_value_to_scale      = var.cpu_value_to_scale_services
  memory_value_to_scale   = var.memory_value_to_scale_services
  ms_classroom            = module.ecs_cluster.classroom_service
  min_containers          = var.min_containers
  max_containers          = var.max_containers
}
