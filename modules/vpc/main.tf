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

# VPC's IGW
resource "aws_internet_gateway" "igw" {
  depends_on = [ aws_vpc.vpc ]
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.igw-name
  }
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

# ----------------------- NAT -----------------------
resource "aws_eip" "natgw-eip1" {
  domain = "vpc"

  tags = {
    Name = var.eip1-name
  }

  depends_on = [ aws_subnet.web-public-subnet1 ]
}
resource "aws_nat_gateway" "natgw1" {
  subnet_id = aws_subnet.web-public-subnet1
  allocation_id = aws_eip.natgw-eip1.id
  tags = {
    Name = var.natgw1-name
  }
}
resource "aws_eip" "natgw-eip2" {
  domain = "vpc"

  tags = {
    Name = var.eip2-name
  }

  depends_on = [ aws_subnet.web-public-subnet2]
}
resource "aws_nat_gateway" "natgw2" {
  subnet_id = aws_subnet.web-public-subnet2
  allocation_id = aws_eip.natgw-eip2.id
  tags = {
    Name = var.natgw2-name
  }
}
# ----------------------- Route tables and associations with subnets -----------------------
    # Public RT to internet and associations with the web public subnets
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = var.public-rt-name
  }
}
resource "aws_route_table_association" "public-rt-association1" {
  route_table_id = aws_route_table.public-rt.id
  subnet_id = aws_subnet.web-public-subnet1.id
}
resource "aws_route_table_association" "public-rt-association2" {
  route_table_id = aws_route_table.public-rt.id
  subnet_id = aws_subnet.web-public-subnet2.id
}
    # Private RT to NATGWs (then outbound to igw) and associations
    # RT 1 of NATGW1 with the private subnets of app and db
resource "aws_route_table" "private-rt1" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw1.id
  }
  tags = {
    Name = var.private-rt1-name
  }
  depends_on = [ aws_route_table.public-rt ]
}
resource "aws_route_table_association" "app-private1-private-rt1-association" {
  route_table_id = aws_route_table.private-rt1
  subnet_id = aws_subnet.app-private-subnet1
}
resource "aws_route_table_association" "db-private1-private-rt1-association" {
  route_table_id = aws_route_table.private-rt1
  subnet_id = aws_subnet.db-private-subnet1
}
    # RT 2 of NATGW2 with the private subnets of app and db
resource "aws_route_table" "private-rt2" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw2.id
  }
  tags = {
    Name = var.private-rt2-name
  }
  depends_on = [ aws_route_table.public-rt,aws_route_table.private-rt1 ]
}
resource "aws_route_table_association" "app-private2-private-rt2-association" {
  route_table_id = aws_route_table.private-rt2
  subnet_id = aws_subnet.app-private-subnet2
}
resource "aws_route_table_association" "db-private2-private-rt2-association" {
  route_table_id = aws_route_table.private-rt2
  subnet_id = aws_subnet.db-private-subnet2
}


