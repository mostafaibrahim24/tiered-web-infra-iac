data "aws_subnet" "web-public-subnet1"{
    filter {
      name = "tag:Name"
      values = [var.web-public-subnet1]
    }
}
data "aws_subnet" "web-public-subnet2"{
    filter {
      name = "tag:Name"
      values = [var.web-public-subnet2]
    }
}
data "aws_security_group" "web-lb-sg"{
    filter {
      name =  "tag:Name"
      values = [var.web-lb-sg-name]
    }
}
data "aws_subnet" "app-private-subnet1" {
    filter {
      name = "tag:Name"
      values = [var.app-private-subnet1]
    }
} 
data "aws_subnet" "app-private-subnet2" {
    filter {
      name = "tag:Name"
      values = [var.app-private-subnet2]
    }
} 
data "aws_security_group" "app-lb-sg"{
    filter {
      name =  "tag:Name"
      values = [var.app-lb-sg-name]
    }
}
data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = [var.vpc-name]
  }
}
# --------------------------- Web tier --------------------------- 
resource "aws_lb" "web-lb" {
  name = var.web-lb-name
  internal = false
  load_balancer_type = "application"
  subnets = [data.aws_subnet.web-public-subnet1.id,data.aws_subnet.web-public-subnet2.id]
  security_groups = [data.aws_security_group.web-lb-sg.id]
  ip_address_type = "ipv4"
  tags = {
    Name = var.web-lb-name
  }
}
resource "aws_lb_target_group" "web-http-target-group" {
  vpc_id = data.aws_vpc.vpc.id
  name = var.web-http-target-group-name
  health_check {
    enabled = true
    interval = 10
    path = "/"
    protocol = "HTTP"
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2
  }
  target_type = "instance"
  port = 80
  protocol = "HTTP"
  lifecycle {
    prevent_destroy = false
  }
  tags = {
    Name = var.web-http-target-group-name
  }
  depends_on = [ aws_lb.web-lb ]
}

resource "aws_lb_listener" "web-lb-http-listener" {
  load_balancer_arn = aws_lb.web-lb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.web-http-target-group.arn
  }
}


resource "aws_lb_target_group" "web-https-target-group" {
  vpc_id = data.aws_vpc.vpc.id
  name = var.web-https-target-group-name
  health_check {
    enabled = true
    interval = 10
    path = "/"
    protocol = "HTTP" #just healthcheck
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2
  }
  target_type = "instance"
  port = 443
  protocol = "HTTPS"
  lifecycle {
    prevent_destroy = false
  }
  tags = {
    Name = var.web-https-target-group-name
  }
  depends_on = [ aws_lb.web-lb ]
}
resource "aws_acm_certificate" "cert" {
  domain_name = var.domain-name
  validation_method = "EMAIL"
  tags = {
    Name = "cert"
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_lb_listener" "web-lb-https-listener" {
  load_balancer_arn = aws_lb.web-lb.arn
  port = 443 
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.cert.arn
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.web-https-target-group.arn
  }
}

# --------------------------- App tier --------------------------- 
resource "aws_lb" "app-lb" {
  name = var.app-lb-name
  internal = true
  load_balancer_type = "application"
  subnets = [data.aws_subnet.app-private-subnet1.id,data.aws_subnet.app-private-subnet2.id]
  security_groups = [data.aws_security_group.app-lb-sg.id]
  ip_address_type = "ipv4"
  tags = {
    Name = var.app-lb-name
  }
}
resource "aws_lb_target_group" "app-target-group" {
  vpc_id = data.aws_vpc.vpc.id
  name = var.app-target-group-name
  health_check {
    enabled = true
    interval = 10
    path = "/"
    protocol = "HTTP"
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2
  }
  target_type = "instance"
  port = 80
  protocol = "HTTP"
  lifecycle {
    prevent_destroy = false
  }
  tags = {
    Name = var.app-target-group-name
  }
  depends_on = [ aws_lb.app-lb ]
}

resource "aws_lb_listener" "app-lb-listener" {
  load_balancer_arn = aws_lb.app-lb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app-target-group.arn
  }
}