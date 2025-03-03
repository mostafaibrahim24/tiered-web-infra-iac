
variable "db-private-subnet1"{}

variable "db-private-subnet2"{}

variable "db-tier-sg-name" {
  
}
variable "db-tier-subnet-gp-name" {
  
}
variable "rds-username" {
  
}
variable "rds-pwd" {
  
}
variable "db-name" {
  
}
variable "rds-cluster-name" {
  
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
