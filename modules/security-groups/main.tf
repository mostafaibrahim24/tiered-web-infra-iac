data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = [var.vpc-name]
  }
}
resource "aws_security_group" "web-lb-sg" {
  vpc_id = data.aws_vpc.vpc.id
  description = "Allow HTTP and HTTPS from the internet"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443 
    to_port = 443 
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = var.web-lb-sg-name
  }
  depends_on = [ data.aws_vpc.vpc ]
}

resource "aws_security_group" "web-tier-sg" {
  vpc_id = data.aws_vpc.vpc.id
  description = "Allow HTTP and HTTPS for Web LB only"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.web-lb-sg.id]
  }
  ingress {
    from_port = 443 
    to_port = 443
    protocol = "tcp"
    security_groups = [aws_security_group.web-lb-sg.id]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = var.web-tier-sg-name
  }
  depends_on = [ data.aws_vpc.vpc ]
}

resource "aws_security_group" "app-lb-sg" {
  vpc_id = data.aws_vpc.vpc.id
  description = "Allow HTTP and HTTPS from web tier"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.web-tier-sg.id,aws_security_group.web-lb-sg.id]
  }
  ingress {
    from_port = 443 
    to_port = 443 
    protocol = "tcp"
    security_groups = [aws_security_group.web-tier-sg.id,aws_security_group.web-lb-sg.id]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = var.app-lb-sg-name
  }
  depends_on = [ data.aws_vpc.vpc ]
}
resource "aws_security_group" "app-tier-sg" {
  vpc_id = data.aws_vpc.vpc.id
  description = "Allow HTTP and HTTPS for App LB only"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.app-lb-sg.id]
  }
  ingress {
    from_port = 443 
    to_port = 443
    protocol = "tcp"
    security_groups = [aws_security_group.app-lb-sg.id]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = var.app-tier-sg-name
  }
  depends_on = [ data.aws_vpc.vpc ]
}
resource "aws_security_group" "db-tier-sg" {
  vpc_id = data.aws_vpc.vpc.id
  description = "Allow HTTP and HTTPS for App Tier only, Protocol type MySQL/Aurora"
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.app-tier-sg.id,aws_security_group.app-lb-sg.id]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = var.db-tier-sg-name
  }
  depends_on = [ data.aws_vpc.vpc ]
}
