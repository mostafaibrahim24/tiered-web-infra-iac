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
variable "web-tier-sg-name" {}
variable "app-tier-sg-name" {}
variable "web-launch-template-name" {}
variable "app-launch-template-name" {}
variable "web-asg-name" {
}
variable "web-http-target-group-name" {
  
}
variable "web-https-target-group-name" {
  
}
variable "app-target-group-name" {
  
}
variable "app-asg-name" {
  
}
variable "web-public-subnet1" {
  
}

variable "web-public-subnet2" {
  
}

variable "app-private-subnet1" {
  
}

variable "app-private-subnet2" {
  
}
variable "web-tier-instance-type" {
  default = "t2.micro"
}
variable "app-tier-instance-type" {
  default = "t2.micro"
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