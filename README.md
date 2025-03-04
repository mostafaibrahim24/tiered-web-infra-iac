# AWS Multi-Tier Web Application Infrastructure - Terraform
<p align="center">
  <img src=https://github.com/user-attachments/assets/2f865e3d-4195-45a1-895a-6dd051ec58ed width=80 height=80\>
  <img src=https://github.com/user-attachments/assets/abfeb16e-7d3d-4efc-97aa-c85e1340224d width=100 height=70\>
</p>

This project is a modular Infrastructure as Code that provisions a multi-tier web application infrastructure on AWS using terraform.  
## Key Features:
* **Highly Available**: Auto Scaling Groups with Multi-AZ deployments ensure minimal downtime and fault tolerance.
* **Scalable, Elastic and Cost-Effective:**: Auto Scaling policies and CloudWatch alarms dynamically adjust resources based on CPU utilization, optimizing both performance and cost :moneybag:.
* **High Performance**: Load Balancers (ALBs) efficiently distribute traffic across web and app tiers, enhancing responsiveness and user experience.
* **Robust Security**: An AWS WAF that blocks suspicious IPs, anonymous proxies and IP addresses that have been identified as actively engaging in malicious activities (from [MadPot](https://www.aboutamazon.com/news/aws/amazon-madpot-stops-cybersecurity-crime)), while comprehensive Security Groups enforce strict inter-tier communication controls.
* **Reliable, Performant & Scalable Database**: A *Multi-AZ* RDS cluster with a primary instance and read replica is deployed to handle demanding workloads, improve read performance, and ensure data redundancy.
* **Tiered Architecture:** Separation of concerns enhances manageability, scalability, and security by isolating different components.  
## Showcasing:
* Automating and managing cloud infrastructure with Infrastructure as Code using **Terraform**.
* Architecting Resilient, Secure, Reliable, Cost-Effective and Scalable Cloud Infrastructure on **AWS** :cloud:.
* Optimizing reusability and scalability by structuring Terraform code into self-contained modules.


## Diagram
<p align="center">
  <img src=https://github.com/user-attachments/assets/b0236b73-ea1b-4bc6-8379-35133c9086da width=700 height=640\>
</p>

## Modules
```
├── modules
│   ├── asgs
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── lbs
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── rds
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── security-groups
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── vpc
│   │   ├── main.tf
│   │   └── variables.tf
│   └── waf
│       ├── main.tf
│       └── variables.tf
```

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
