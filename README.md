# AWS Multi-Tier Web Application Infrastructure - Terraform Deployment

This modular Infrastructure as Code provisions a **robust**, **highly available**, **scalable**, **secure** multi-tier web application infrastructure on AWS.

## Architecture Brief Overview
* **Web Tier:**
    * Load Balancer (ALB) for distributing incoming traffic (Both HTTP and HTTPS).
    * Auto Scaling Group (ASG)
    * Web Application Firewall (WAF) to protect from malicious traffic.
* **Application Tier:**
    * Internal Load Balancer (ALB) for distributing traffic within the application tier.
    * Auto Scaling Group (ASG)
* **Database Tier:**
    * Multi-AZ RDS cluster (primary instance and read replica) for high availability and reliability.

## Properties
* **High Availability:** Multi-AZ deployments to ensure fault tolerance and minimize downtime.
* **Scalability:** Auto Scaling policies and CloudWatch alarms are implemented for both web and application tiers enabling dynamic scaling based on CPU utilization, ensuring optimal performance.
* **Security:** Comprehensive Security Groups to control the communication including inter-tier communication and a **WAF** blocking suspicious IPs and anonymous proxies
* **Tiered Architecture:** Separating concerns, making it easier to manage individual components and enhances security by isolating different components.
* **Cost-Effectiveness:** Auto Scaling scale down policies for both web and app tiers reducing costs.
* **Improved performance:** Load balancers for both tiers to distribute traffic accross multiple instances.

## Properties of the Architecture

* **Multi-AZ Deployment:** Ensures high availability by distributing resources across multiple Availability Zones.
* **Tiered Architecture:** Separates concerns and improves security by isolating different components.
* **Elasticity:** Auto Scaling allows the infrastructure to adapt to changing traffic patterns.
* **Security-First Design:** Security Groups, NAT Gateways, and WAF provide robust security measures.
* **Automated Deployment:** Terraform enables consistent and repeatable deployments.
* **Load Balancing:** Load balancers distribute traffic across multiple instances, improving performance and availability.
* **Database Replication:** Read replicas improve database performance and availability.
* **Infrastructure as Code:** Terraform allows you to manage your infrastructure as code.

## Prerequisites

* AWS account with appropriate permissions.
* Terraform installed.
* AWS CLI configured.

## Usage

1.  Clone the repository.
2.  Configure the `variables.tf` file with your desired settings.
3.  Run `terraform init` to initialize the Terraform project.
4.  Run `terraform plan` to preview the changes.
5.  Run `terraform apply` to deploy the infrastructure.

## Variables

The following variables are used to configure the infrastructure:

* `vpc-cidrblock`
* `vpc-name`
* `az1`
* `az2`
* `public-cidr1`
* `public-cidr2`
* `app-private-cidr1`
* `app-private-cidr2`
* `db-private-cidr1`
* `db-private-cidr2`
* `web-public-subnet1`
* `web-public-subnet2`
* `app-private-subnet1`
* `app-private-subnet2`
* `db-private-subnet1`
* `db-private-subnet2`
* `igw-name`
* `eip1-name`
* `natgw1-name`
* `eip2-name`
* `natgw2-name`
* `public-rt-name`
* `private-rt1-name`
* `private-rt2-name`
* `web-ami-identifier`
* `web-ami-image-owner`
* `app-ami-identifier`
* `app-ami-image-owner`
* `web-tier-sg-name`
* `app-tier-sg-name`
* `web-launch-template-name`
* `app-launch-template-name`
* `web-asg-name`
* `app-asg-name`
* `web-lb-name`
* `web-http-target-group-name`
* `web-https-target-group-name`
* `app-lb-name`
* `app-target-group-name`
* `db-tier-subnet-gp-name`
* `rds-username`
* `rds-pwd`
* `db-name`
* `rds-cluster-name`
* `web-lb-sg-name`
* `app-lb-sg-name`
* `db-tier-sg-name`
* `domain-name`

## Cleanup

To destroy the infrastructure, run `terraform destroy`.
