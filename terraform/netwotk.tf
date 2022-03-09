resource "aws_vpc" "vpc" {
  cidr_block       = var.cidr_vpc
  instance_tenancy = "default"
  # Стандартные настройки при создании VPC ручками
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name  = "my-${var.env}-VPC"
    Owner = "Student"
  }
}

resource "aws_subnet" "public_subnet" {
  count  = length(var.public_subnet) # count leangtn. In our case 2 Subnets
  vpc_id = aws_vpc.vpc.id            # Connect our VPC with subnet
  # (https://www.terraform.io/language/functions/cidrsubnet)
  # Give subnets IP from VPC range.
  cidr_block              = var.public_subnet[count.index]                           # 172.31.0.0/16 ==> 172.31.X.X/24 
  availability_zone       = data.aws_availability_zones.available.names[count.index] # For 2 subnets give available zone
  map_public_ip_on_launch = true                                                     # Give public IP

  tags = {
    Name              = "Subnet-${var.env}-${count.index + 1}"
    Availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  }

  depends_on = [aws_vpc.vpc] # If VPC configure ==> subnets UP
}

# Connect our VPC to the Internet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "IGW-${var.env}"
    Description = "Internet Gateway for VPC"
    Environment = "${var.env}"
  }
}

# Route table from Internet to subnets
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "publicroute" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"                 # Allow all to IN/OUT traffic
    gateway_id = aws_internet_gateway.igw.id # Attach to IGW and Internet will work
  }

  tags = {
    Name = "PublicRouteTable-${var.env}"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table_association" "publicrouteAssociation" {
  count          = length(var.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.publicroute.id

  depends_on = [aws_subnet.public_subnet, aws_route_table.publicroute]
}
