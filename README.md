# AWS Multi-Tier Web Application Infrastructure - Terraform Deployment

This modular Infrastructure as Code provisions a **robust**, **highly available**, **scalable**, **secure** multi-tier web application infrastructure on AWS.

## Architecture Brief Overview
* **Web Tier:** Load Balancer (ALB) for distributing incoming traffic (Both HTTP and HTTPS), Auto Scaling Group (ASG) for EC2 and Web Application Firewall (WAF) to protect from suspicious traffic.
* **Application Tier:** Internal Load Balancer (ALB) for distributing traffic within the application tier and Auto Scaling Group (ASG) for EC2
* **Database Tier:** Multi-AZ RDS cluster (primary instance and read replica) for high availability and reliability.
## Diagram
![tier drawio (2)](https://github.com/user-attachments/assets/7fde6af6-d2e1-416c-84d2-f67c794b75d0)

## Properties
* **High Availability:** Multi-AZ deployments to ensure fault tolerance and minimize downtime.
* **Scalability and Elasticity:** Auto Scaling policies and CloudWatch alarms are implemented for both web and application tiers enabling dynamic scaling based on CPU utilization, ensuring optimal performance.
* **Security:** WAF blocking suspicious IPs and anonymous proxies and Comprehensive Security Groups to control the communication including inter-tier communication.
* **Tiered Architecture:** Separating concerns, making it easier to manage individual components and enhances security by isolating different components.
* **Cost-Effectiveness:** Auto Scaling scale down policies for both web and app tiers reducing costs when instances are not needed.
* **Improved performance:** Load balancers for both tiers to distribute traffic accross multiple instances.

## Prerequisites

* AWS account with appropriate permissions.
* Terraform installed.
  
## Usage

1.  Clone the repository.
2.  Check main.tf for an example of using modules and Add variables values (whether cli args or TF_VAR env vars or .tfvars .auto.tfvars or defaults in variables.tf)
3.  Run `terraform init` to initialize the Terraform project.
4.  Run `terraform plan` to preview the changes.
5.  Run `terraform apply` to deploy the infrastructure.

To destroy the infrastructure, run `terraform destroy`.
