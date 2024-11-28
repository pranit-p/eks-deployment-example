resource "aws_vpc" "eks_deployment_vpc" {
  cidr_block           = "192.168.0.0/16"
  tags = {
    Name = "eks-deployment-vpc"
  }
}

locals {
  public_subnet = [
    {
      ip_range= "192.168.1.0/24"
      availability_zone = "us-east-1a"
    },
    {
      ip_range= "192.168.3.0/24"
      availability_zone = "us-east-1b"
    },
    {
      ip_range= "192.168.5.0/24"
      availability_zone = "us-east-1c"
    }
  ]
  private_subnet = [
    {
      ip_range= "192.168.7.0/24"
      availability_zone = "us-east-1a"
    },
    {
      ip_range= "192.168.9.0/24"
      availability_zone = "us-east-1b"
    },
    {
      ip_range= "192.168.11.0/24"
      availability_zone = "us-east-1c"
    }
  ]
}

resource "aws_subnet" "eks_deployment_public_subnet" {
  for_each =  { for subnet in local.public_subnet : subnet.availability_zone => subnet }
  vpc_id                  = aws_vpc.eks_deployment_vpc.id
  map_public_ip_on_launch = true
  cidr_block              = each.value.ip_range
  availability_zone       = each.value.availability_zone
  tags = {
    Name = "eks-deployment-public-subnet",
  }
}

resource "aws_subnet" "eks_deployment_private_subnet" {
  for_each =  { for subnet in local.private_subnet : subnet.availability_zone => subnet }
  vpc_id                  = aws_vpc.eks_deployment_vpc.id
  cidr_block              = each.value.ip_range
  availability_zone       = each.value.availability_zone
  tags = {
    Name = "eks-deployment-private-subnet",
  }
}

resource "aws_internet_gateway" "eks_deployment_internet_gateway" {
  vpc_id = aws_vpc.eks_deployment_vpc.id
  tags = {
    Name = "eks-deployment-internet-gateway"
  }
}

resource "aws_route_table" "eks_deployment_public_subnet_route_table" {
  vpc_id = aws_vpc.eks_deployment_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_deployment_internet_gateway.id
  }
}

resource "aws_route_table_association" "eks_deployment_public_subnet_route_table" {
  for_each =  { for subnet in local.public_subnet : subnet.availability_zone => subnet }
  subnet_id      = aws_subnet.eks_deployment_public_subnet[each.value.availability_zone].id
  route_table_id = aws_route_table.eks_deployment_public_subnet_route_table.id
}

resource "aws_security_group" "eks_deployment_security_group" {
  name   = "eks-deployment-security-group"
  vpc_id = aws_vpc.eks_deployment_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow http traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow internet access"
  }
}