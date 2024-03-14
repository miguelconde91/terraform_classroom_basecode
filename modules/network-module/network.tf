#####################
# Network resources #
#####################

#VPC
resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cdir
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    tags = merge(var.tags_network, {Name = format("VPC-%s", var.sufix_name_resource)})
}

#InternetGateway
resource "aws_internet_gateway" "internetgateway" {
    depends_on = [aws_vpc.vpc]
    vpc_id = aws_vpc.vpc.id
    tags = merge(var.tags_network)
}

#PublicSubnet1
resource "aws_subnet" "publicsubnet1" {
    vpc_id = aws_vpc.vpc.id
    availability_zone = var.availability_zone_name["public1"]
    cidr_block = var.cidr_block["public1"]
    map_public_ip_on_launch = "true"
    tags = merge(var.tags_network, {Name = format("Public-Subnet-1-%s", var.sufix_name_resource)})
}

#PublicSubnet2
resource "aws_subnet" "publicsubnet2" {
    vpc_id = aws_vpc.vpc.id
    availability_zone = var.availability_zone_name["public2"]
    cidr_block = var.cidr_block["public2"]
    map_public_ip_on_launch = "true"
    tags = merge(var.tags_network, {Name = format("Public-Subnet-2-%s", var.sufix_name_resource)})
}

#PublicSubnet3
resource "aws_subnet" "publicsubnet3" {
    vpc_id = aws_vpc.vpc.id
    availability_zone = var.availability_zone_name["public3"]
    cidr_block = var.cidr_block["public3"]
    map_public_ip_on_launch = "true"
    tags = merge(var.tags_network, {Name = format("Public-Subnet-3-%s", var.sufix_name_resource)})
}

#PrivateSubnet1
resource "aws_subnet" "privatesubnet1" {
    vpc_id = aws_vpc.vpc.id
    availability_zone = var.availability_zone_name["private1"]
    cidr_block = var.cidr_block["private1"]
    map_public_ip_on_launch = "false"
    tags = merge(var.tags_network, {Name = format("Private-Subnet-1-%s", var.sufix_name_resource)})
}

#PrivateSubnet2
resource "aws_subnet" "privatesubnet2" {
    vpc_id = aws_vpc.vpc.id
    availability_zone = var.availability_zone_name["private2"]
    cidr_block = var.cidr_block["private2"]
    map_public_ip_on_launch = "false"
    tags = merge(var.tags_network, {Name = format("Private-Subnet-2-%s", var.sufix_name_resource)})
}

#PrivateSubnet3
resource "aws_subnet" "privatesubnet3" {
    vpc_id = aws_vpc.vpc.id
    availability_zone = var.availability_zone_name["private3"]
    cidr_block = var.cidr_block["private3"]
    map_public_ip_on_launch = "false"
    tags = merge(var.tags_network, {Name = format("Private-Subnet-3-%s", var.sufix_name_resource)})
}

#ElasticIP
resource "aws_eip" "eip" {
    domain = "vpc"
    tags = merge(var.tags_network, {Name = format("EIP-NAT-Gateway-%s", var.sufix_name_resource)})
}

#NatGateway
resource "aws_nat_gateway" "natgateway" {
    subnet_id = aws_subnet.publicsubnet1.id
    allocation_id = aws_eip.eip.id
    tags = merge(var.tags_network, {Name = format("%s", var.sufix_name_resource)})
}

#PublicRouteTable
resource "aws_route_table" "publicroutetable" {
    vpc_id = aws_vpc.vpc.id
    tags = merge(var.tags_network, {Name = format("Public-Routetable-%s", var.sufix_name_resource)})
}

#DefaultPublicRoute
resource "aws_route" "defaultpublicroute" {
    depends_on = [aws_internet_gateway.internetgateway]
    route_table_id = aws_route_table.publicroutetable.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internetgateway.id
}

#PublicSubnet1RouteTableAssociation
resource "aws_route_table_association" "publicsubnet1routetableassociation"{
    route_table_id = aws_route_table.publicroutetable.id
    subnet_id = aws_subnet.publicsubnet1.id
}

#PublicSubnet2RouteTableAssociation
resource "aws_route_table_association" "publicsubnet2routetableassociation"{
    route_table_id = aws_route_table.publicroutetable.id
    subnet_id = aws_subnet.publicsubnet2.id
}

#PrivateRouteTable
resource "aws_route_table" "privateroutetable" {
    vpc_id = aws_vpc.vpc.id
    tags = merge(var.tags_network, {Name = format("Private1-Routetable-%s", var.sufix_name_resource)})
}

#DefaultPrivateRoute1
resource "aws_route" "defaultprivateroute" {
    depends_on = [aws_internet_gateway.internetgateway]
    route_table_id = aws_route_table.privateroutetable.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway.id
}

#PrivateSubnet1RouteTableAssociation
resource "aws_route_table_association" "privatesubnet1routetableassociation"{
    route_table_id = aws_route_table.privateroutetable.id
    subnet_id = aws_subnet.privatesubnet1.id
}

#PrivateRouteTable
resource "aws_route_table" "privateroutetable2" {
    vpc_id = aws_vpc.vpc.id
    tags = merge(var.tags_network, {Name = format("Private2-Routetable-%s", var.sufix_name_resource)})
}

#DefaultPrivateRoute2
resource "aws_route" "defaultprivateroute2" {
    depends_on = [aws_internet_gateway.internetgateway]
    route_table_id = aws_route_table.privateroutetable2.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway.id
}

#PrivateSubnet2RouteTableAssociation
resource "aws_route_table_association" "privatesubnet2routetableassociation"{
    route_table_id = aws_route_table.privateroutetable2.id
    subnet_id = aws_subnet.privatesubnet2.id
}

#NoIngressSecurityGroup
resource "aws_security_group" "noingresssecuritygroup" {
    vpc_id = aws_vpc.vpc.id
    name = format("classroom-no-ingress-%s", var.environment)
    description = "Security group with no ingress rule"
}

resource "aws_security_group" "ecs_security_group" {
  depends_on = [
    aws_vpc.vpc    
    ]
  name        = format("classroom-sg-ecs-%s", var.environment)
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Allow HTTPS"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags_network, {Name = format("ECS-SG-%s", var.sufix_name_resource)})
}

#Security Group for ALB
resource "aws_security_group" "ecs_lb_security_group" {
    vpc_id = aws_vpc.vpc.id
    description = "Security Group for Public ALB"
    tags = merge(var.tags_network)
}

#Security Group Rule 1
resource "aws_security_group_rule" "sg_ecs_lb_rule1"{
    depends_on = [ aws_security_group.ecs_lb_security_group ]
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_group_id = aws_security_group.ecs_lb_security_group.id
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow access from internet"
}

#Security Group Rule 2
resource "aws_security_group_rule" "sg_ecs_lb_rule2"{
    depends_on = [ aws_security_group.ecs_lb_security_group ]
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_group_id = aws_security_group.ecs_lb_security_group.id
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow access from internet"
}

#Security Group Rule 3
resource "aws_security_group_rule" "sg_ecs_lb_rule3"{
    depends_on = [ aws_security_group.ecs_lb_security_group ]
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_group_id = aws_security_group.ecs_lb_security_group.id
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow access to internet"
}

resource "aws_s3_bucket" "alb_access_logs" {
    bucket = "alb-access-log-classroom-${var.environment}"
    force_destroy = true
    tags = merge(var.tags_network)
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_bastion_ssh_logs" {
  bucket = aws_s3_bucket.alb_access_logs.id

  rule {
    id      = "alb-logs"

    filter {
      prefix = "alb-logs/"
    }

    transition {
      days          = var.log_standard_ia_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.log_glacier_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.log_expiry_days
    }

    status = "Enabled"
  }
}

data "aws_iam_policy_document" "allow_logs_write_s3" {
  statement {
    actions = [
      "s3:PutObject",
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::127311923021:root"]
    }
    resources = [
      "${aws_s3_bucket.alb_access_logs.arn}/alb-internet-logs/*"
      ]
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_alb" {
  bucket = aws_s3_bucket.alb_access_logs.id
  policy = data.aws_iam_policy_document.allow_logs_write_s3.json  
}

#ALB public exposed directly
resource "aws_lb" "ecs_lb_internet" {
    name = "ALB-${var.sufix_name_resource}"
    subnets = [ aws_subnet.publicsubnet1.id, aws_subnet.publicsubnet2.id ]
    ip_address_type = "ipv4"
    internal = false
    load_balancer_type = "application"
    security_groups = [ aws_security_group.ecs_lb_security_group.id ]
    access_logs {
        bucket  = aws_s3_bucket.alb_access_logs.bucket
        prefix  = "alb-internet-logs"
        enabled = true
    }
    tags = merge(var.tags_network)
}

#Listener 80 of ALB
resource "aws_lb_listener" "public_listener" {
    load_balancer_arn = aws_lb.ecs_lb_internet.arn
    port              = "80"
    protocol          = "HTTP"
    default_action {
        type = "fixed-response"
        fixed_response {
            content_type = "text/plain"
            message_body = "Service not found"
            status_code  = "404"
        }
    }
}