# VPC
resource "aws_vpc" "vpc"{
    cidr_block = var.vpc-cidrblock
    instance_tenancy = "default"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      Name = var.vpc-name
    }
}
variable "vpc-cidrblock" {
}
variable "vpc-name" {
}
# VPC's IGW
resource "aws_internet_gateway" "igw" {
  depends_on = [ aws_vpc.vpc ]
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.igw-name
  }
}
variable "igw-name" {
  
}
# ----------------------- Public subnets of the web tier -----------------------
resource "aws_subnet" "web-public-subnet1" {
  vpc_id = aws_vpc.vpc.id
  availability_zone = var.az1
  cidr_block = var.public-cidr1
  map_public_ip_on_launch = true
  tags = {
    Name = var.web-public-subnet1
  }
  depends_on = [ aws_internet_gateway.igw ]
}
resource "aws_subnet" "web-public-subnet2" {
  vpc_id = aws_vpc.vpc.id
  availability_zone = var.az2
  cidr_block = var.public-cidr2
  map_public_ip_on_launch = true
  tags = {
    Name = var.web-public-subnet2
  }
  depends_on = [ aws_internet_gateway.igw , aws_subnet.web-public-subnet1]
}


# ----------------------- Private subnets of the app tier -----------------------
resource "aws_subnet" "app-private-subnet1" {
  vpc_id = aws_vpc.vpc.id
  availability_zone = var.az1
  cidr_block = var.app-private-cidr1
  map_public_ip_on_launch = false
  tags = {
    Name = var.app-private-subnet1
  }
  depends_on = [aws_subnet.web-public-subnet2]
}
resource "aws_subnet" "app-private-subnet2" {
  vpc_id = aws_vpc.vpc.id
  availability_zone = var.az2
  cidr_block = var.app-private-cidr2
  map_public_ip_on_launch = false
  tags = {
    Name = var.app-private-subnet2
  }
  depends_on = [ aws_subnet.app-private-subnet1]
}
# ----------------------- Private subnets of the db tier -----------------------
resource "aws_subnet" "db-private-subnet1" {
  vpc_id = aws_vpc.vpc.id
  availability_zone = var.az1
  cidr_block = var.db-private-cidr1
  map_public_ip_on_launch = false
  tags = {
    Name = var.db-private-subnet1
  }
  depends_on = [aws_subnet.app-private-subnet2]
}
resource "aws_subnet" "db-private-subnet2" {
  vpc_id = aws_vpc.vpc.id
  availability_zone = var.az2
  cidr_block = var.db-private-cidr2
  map_public_ip_on_launch = false
  tags = {
    Name = var.db-private-subnet2
  }
  depends_on = [ aws_subnet.db-private-subnet1]
}