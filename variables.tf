variable "app-asg-name" {}
variable "app-launch-template-name" {}
variable "app-lb-name" {}
variable "app-lb-sg-name" {}
variable "app-private-cidr1" {}
variable "app-private-cidr2" {}
variable "app-private-subnet1" {}
variable "app-private-subnet2" {}
variable "app-target-group-name" {}
variable "app-tier-sg-name" {}
variable "az1" {}
variable "az2" {}
variable "db-name" {}
variable "db-private-cidr1" {}
variable "db-private-cidr2" {}
variable "db-private-subnet1" {}
variable "db-private-subnet1"{}
variable "db-private-subnet2" {}
variable "db-private-subnet2"{}
variable "db-tier-sg-name" {}
variable "db-tier-subnet-gp-name" {}
variable "domain-name" {}
variable "eip1-name" {}
variable "eip2-name" {}
variable "natgw1-name" {}
variable "natgw2-name" {}
variable "igw-name" {}
variable "private-rt1-name" {}
variable "private-rt2-name" {}
variable "public-cidr1" {}
variable "public-cidr2" {}
variable "public-rt-name" {}
variable "rds-cluster-name" {}
variable "rds-pwd" {}
variable "rds-username" {}
variable "vpc-cidrblock" {}
variable "vpc-name" {}
variable "web-asg-name" {}
variable "web-https-target-group-name" {}
variable "web-http-target-group-name" {}
variable "web-launch-template-name" {}
variable "web-lb-name" {}
variable "web-lb-sg-name" {}
variable "web-public-subnet1" {}
variable "web-public-subnet2" {}
variable "web-tier-sg-name" {}
variable "web-ami-identifier" {
  default = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}
variable "web-ami-image-owner" {
  default = "aws-marketplace"
}
variable "app-ami-identifier" {
  default = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}
variable "app-ami-image-owner" {
  default = "aws-marketplace"
}
variable "web-tier-instance-type" {
  default = "t2.micro"
}
variable "app-tier-instance-type" {
  default = "t2.micro"
}
variable "rds-db-engine" {
  default = "aurora-mysql"
}
variable "rds-db-engine-version" {
  default = "8.0.mysql_aurora.3.02.2"
}

variable "primary-instance-class" {
  default = "db.r5.large"
}
variable "read-replica-instance-class" {
  default = "db.r5.large"
}
variable "db-port" {
  default = 3306
}
variable "web-tier-asg-min" {
  default = 2
}
variable "web-tier-asg-max" {
  default = 4
}
variable "app-tier-asg-min" {
  default = 2
}
variable "app-tier-asg-max" {
  default = 4
}