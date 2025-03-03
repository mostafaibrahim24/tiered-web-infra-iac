module "vpc" {
  source = "./modules/vpc"
  vpc-name = var.vpc-name
  vpc-cidrblock = var.vpc-cidrblock
  igw-name = var.igw-name
  az1 = var.az1
  az2 = var.az2
  # Web tier 
  web-public-subnet1 = var.web-public-subnet1
  public-cidr1 = var.public-cidr1
  web-public-subnet2 = var.web-public-subnet2
  public-cidr2 = var.public-cidr2
  # App tier
  app-private-subnet1 = var.app-private-subnet1
  app-private-cidr1 = var.app-private-cidr1
  app-private-subnet2 = var.app-private-subnet2
  app-private-cidr2 = var.app-private-cidr2
  # Database tier
  db-private-subnet1 = var.db-private-subnet1
  db-private-cidr1 = var.db-private-cidr1
  db-private-subnet2 = var.db-private-subnet2
  db-private-cidr2 = var.db-private-cidr2
  # EIPs
  eip1-name = var.eip1-name
  eip2-name = var.eip2-name
  # NAT gatways
  natgw1-name = var.natgw1-name
  natgw2-name = var.natgw2-name
  # Route Tables
  public-rt-name = var.public-rt-name
  private-rt1-name = var.private-rt1-name
  private-rt2-name = var.private-rt2-name
}

module "security-groups" {
  source = "./modules/security-groups"
  vpc-name = var.vpc-name
  # Web
  web-lb-sg-name = var.web-lb-sg-name
  web-tier-sg-name = var.web-tier-sg-name
  # App
  app-lb-sg-name = var.app-lb-sg-name
  app-tier-sg-name = var.app-tier-sg-name
  # Database
  db-tier-sg-name = var.db-tier-sg-name

  depends_on = [ module.vpc ]
}

module "rds" {
  source = "./modules/rds"
  db-tier-sg-name = var.db-tier-sg-name
  db-private-subnet1 = var.db-private-subnet1
  db-private-subnet2 = var.db-private-subnet2
  db-tier-subnet-gp-name = var.db-tier-subnet-gp-name
  rds-username = var.rds-username
  rds-pwd = var.rds-pwd
  db-name = var.db-name
  rds-cluster-name = var.rds-cluster-name
  depends_on = [ module.security-groups ]
}

module "lbs" {
  source = "./modules/lbs"
  vpc-name = var.vpc-name
  # Web
  web-lb-name = var.web-lb-name
  web-public-subnet1 = var.web-public-subnet1
  web-public-subnet2 = var.web-public-subnet2
  web-lb-sg-name = var.web-lb-sg-name
  web-http-target-group-name = var.web-http-target-group-name
  web-https-target-group-name = var.web-https-target-group-name
  domain-name = var.domain-name
  # App
  app-lb-name = var.app-lb-name
  app-private-subnet1 = var.app-private-subnet1
  app-private-subnet2 = var.app-private-subnet2
  app-lb-sg-name = var.app-lb-sg-name
  app-target-group-name = var.app-target-group-name

  depends_on = [ module.rds ]
}

module "asgs" {
  source = "./modules/asgs"
  # Web
  web-asg-name = var.web-asg-name
  web-ami-identifier = var.web-ami-identifier
  web-ami-image-owner = var.web-ami-image-owner
  web-http-target-group-name = var.web-http-target-group-name
  web-https-target-group-name = var.web-https-target-group-name
  web-launch-template-name = var.web-launch-template-name
  web-public-subnet1 = var.web-public-subnet1
  web-public-subnet2 = var.web-public-subnet2
  web-tier-sg-name = var.web-tier-sg-name
  # App
  app-asg-name = var.app-asg-name
  app-ami-identifier = var.app-ami-identifier
  app-ami-image-owner = var.app-ami-image-owner
  app-target-group-name = var.app-target-group-name
  app-launch-template-name = var.app-launch-template-name
  app-private-subnet1 = var.app-private-subnet1
  app-private-subnet2 = var.app-private-subnet2
  app-tier-sg-name = var.app-tier-sg-name

  depends_on = [ module.lbs ]
}

module "waf" {
  source = "./modules/waf"
  web-lb-name = var.web-lb-name
  depends_on = [ module.asgs ]
}
