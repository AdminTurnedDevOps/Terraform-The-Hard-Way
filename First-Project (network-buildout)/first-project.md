# First Project

Now that you've gone through the basics of Terraform, it's time to get started with your first project. The first project will be to create a network on AWS. The network will consist of multiple components, including subnets, IPs, and gateways.

Inside of this module, you'll find:
- A `main.tf` file
- A `variables.tf` file

This README breaks down the `main.tf` file

## Backend and Providers
First things first, you need to set up the backend and providers. The backend and provider blocks will use an S3 bucket to store the `tfstate` and ensure that the required providers are set.

```
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
  region = "us-east-1"
}
```

## VPC
The VPC is the network itself. Because it's like it's own virtual datacenter, the most important thing it contains is the creation of the CIDR block. In this case, we're going with a `192.168.x.x` CIDR with a `/16` subnet range.

Notice how we're specifying the `tags` block, which is important for any environment. Without tags, you don't know which resources belong to what environment.

```
resource "aws_vpc" "terraformhardway-platform" {
  cidr_block                       = "192.168.0.0/16"
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name        = "companya-${var.environment}-vpc"
    Environment = var.environment
    Provisioner = "terraform"
  }
}
```
## Internet Gateway
An internet gateway is crucial for any VPC because it allows communication between your VPC and the internet.

You'll notice a new block, the `depends_on` block. What this is saying is that to create the `aws_internet_gateway_ resource, the VPC MUST be created first. Why? Because an internet gateway cannot exist without a VPC to attach it to.

```
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
```

## Route
The route table is created to determine where network traffic from a subnet or gateway is directed. Notice how we're calling upon the `gateway_id` from the internet gateway resource that we're creating.

The `destination_cidr_block` is `0.0.0.0`, which means out to the world - anywhere.

```
resource "aws_route" "r" {
  route_table_id         = aws_vpc.terraformhardway-platform.default_route_table_id
  gateway_id             = aws_internet_gateway.terraformhardway-platform-vpc-gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

```

## Subnets

Because this is a demo environment, there's only one private subnet and one public subnet. I typically recommend 3 public subnets and 3 private subnets for production environment. That way, there's a solid amount of redundancy.

```
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
```

## EIP
The Elastic IP is to ensure that there is one associated to the VPC for resources that need it.

```
resource "aws_eip" "nat_eip_a" {
  vpc = true
}
```

## NAT Gateway and Route Table
The NAT gateway is used for instances in a private subnet to connect to services outside of the VPC. The biggest key differentiator here is that external resources (outside of AWS and outside of the VPC) cannot initiate a connection with those instances.

The route table is then created and associated with the VPC.

Once the route table is created, an association is created to tie the private IP to the route table so it can access the external resources.

```
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
```

## Outputs
Once all of the resources are created, you may want to see some terminal output about the resources. Things like the resource IDs and ARN's, for example. 

That's where the `output` block comes into play.

```
output "vpc_security_group_id" {
  value = aws_vpc.terraformhardway-platform.default_security_group_id
}
output "vpcid" {
  value = aws_vpc.terraformhardway-platform.id
}
output "security-group-id" {
  value = aws_security_group.allow_incoming.id
}
```

## Variables.tf

Inside of the `variables.tf`, there is just one variable for the environment. You can also set up variables for the CIDRs and IP addresses, but these typically don't change unless you want to use the Terraform module for multiple different environments.