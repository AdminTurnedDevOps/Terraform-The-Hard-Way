terraform {
  backend "s3" {
    bucket = "terraform-states"
    key    = "vpc-terraform.tfstate"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}

resource "aws_vpc" "terraformhardway-platform" {
  cidr_block                       = "192.168.0.0/16"
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name        = "companya-${var.environment}-vpc"
    Environment = var.environment
    Provisioner = "terraform"
  }
}

resource "aws_internet_gateway" "terraformhardway-platform-vpc-gateway" {
  vpc_id = aws_vpc.terraformhardway-platform.id

  tags = {
    Name        = "companya-${var.environment}-gw"
    Environment = var.environment
    Provisioner = "terraform"
  }

  depends_on = [
    aws_vpc.terraformhardway-platform
  ]
}

resource "aws_route" "r" {
  route_table_id         = aws_vpc.terraformhardway-platform.default_route_table_id
  gateway_id             = aws_internet_gateway.terraformhardway-platform-vpc-gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_subnet" "privatesubnet" {
  vpc_id                  = aws_vpc.terraformhardway-platform.id
  cidr_block              = "192.168.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-west-1b"

  tags = {
    Name        = "companya-${var.environment}-private_subnet_d_one"
    Environment = var.environment
    Provisioner = "terraform"
  }

  depends_on = [
    aws_vpc.terraformhardway-platform
  ]
}

resource "aws_subnet" "publicsubnet" {
  vpc_id                  = aws_vpc.terraformhardway-platform.id
  cidr_block              = "192.168.4.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-1b"

  tags = {
    Name        = "companya-${var.environment}-public_subnet_d_one"
    Environment = var.environment
    Provisioner = "terraform"
  }

  depends_on = [
    aws_vpc.terraformhardway-platform
  ]
}

# NAT Public
resource "aws_eip" "nat_eip_a" {
  vpc = true
}

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_eip_a.id
  subnet_id     = aws_subnet.publicsubnet.id

  tags = {
    Name        = "companya-${var.environment}-nat_gateway_a"
    Environment = var.environment
    Provisioner = "terraform"
  }
}

resource "aws_route_table" "privateroute" {
  vpc_id = aws_vpc.terraformhardway-platform.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_a.id
  }

  tags = {
    Name        = "companya-${var.environment}-private_route_table"
    Environment = var.environment
    Provisioner = "terraform"
  }
}

resource "aws_route_table_association" "privateroute_one" {
  subnet_id      = aws_subnet.privatesubnet.id
  route_table_id = aws_route_table.privateroute.id
}


output "vpc_security_group_id" {
  value = aws_vpc.terraformhardway-platform.default_security_group_id
}
output "vpcid" {
  value = aws_vpc.terraformhardway-platform.id
}
output "security-group-id" {
  value = aws_security_group.allow_incoming.id
}
