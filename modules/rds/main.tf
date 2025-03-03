data "aws_subnet" "db-private-subnet1"{
    filter {
      name = "tag:Name"
      values = [var.db-private-subnet1]
    }
}
data "aws_subnet" "db-private-subnet2"{
    filter {
      name = "tag:Name"
      values = [var.db-private-subnet2]
    }
}
data "aws_security_group" "db-tier-sg"{
    filter {
      name = "tag:Name"
      values = [var.db-tier-sg-name]
    }
}
resource "aws_db_subnet_group" "db-tier-subnet-gp" {
  name = var.db-tier-subnet-gp-name
  subnet_ids = [data.aws_subnet.db-private-subnet1,data.aws_subnet.db-private-subnet2]
}
resource "aws_rds_cluster" "aurora-cluster" {
  cluster_identifier = "aurora-cluster"
  engine                  = var.rds-db-engine
  engine_version          = var.rds-db-engine-version
  master_username         = var.rds-username
  master_password         = var.rds-pwd 
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  database_name           = var.db-name
  port                    = var.db-port
  db_subnet_group_name = aws_db_subnet_group.db-tier-subnet-gp.name
  vpc_security_group_ids = [data.aws_security_group.db-tier-sg]
  tags = {
    Name = var.rds-cluster-name
  }
}

# RDS Primary instance
resource "aws_rds_cluster_instance" "primary-instance" {
  cluster_identifier = aws_rds_cluster.aurora-cluster.id
  identifier         = "primary-instance"
  instance_class     = var.primary-instance-class
  engine             = aws_rds_cluster.aurora-cluster.engine
  engine_version     = aws_rds_cluster.aurora-cluster.engine_version
}

# RDS Read Replica Instance
resource "aws_rds_cluster_instance" "read-replica-instance" {
  cluster_identifier = aws_rds_cluster.aurora-cluster.id
  identifier         = "read-replica-instance"
  instance_class = var.read-replica-instance-class
  engine             = aws_rds_cluster.aurora-cluster.engine

  depends_on = [aws_rds_cluster_instance.primary-instance]
}
