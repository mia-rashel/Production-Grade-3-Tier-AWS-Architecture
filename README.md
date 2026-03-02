# 🚀 Production-Grade 3-Tier AWS Architecture (Terraform)

![Terraform](https://img.shields.io/badge/Terraform-1.6+-623CE4?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)
![RDS](https://img.shields.io/badge/AWS-RDS-blue)
![EC2](https://img.shields.io/badge/AWS-EC2-orange)
![ALB](https://img.shields.io/badge/AWS-Application_Load_Balancer-green)
![Status](https://img.shields.io/badge/Status-Production--Style-success)

---

## 📌 Overview

This project implements a **production-style 3-tier AWS architecture** using modular Terraform.

It demonstrates:

- Infrastructure as Code (IaC)
- Secure network segmentation
- Application Load Balancing
- Auto Scaling
- RDS MySQL in isolated DB subnets
- CloudWatch monitoring and scaling policies
- Security group chaining between tiers

This architecture reflects real-world cloud engineering best practices.

---

## 🏗 Architecture Diagram

### Logical Flow

            ┌──────────────────────────┐
            │        Internet          │
            └─────────────┬────────────┘
                          │
                          ▼
            ┌──────────────────────────┐
            │ Application Load Balancer│
            │     (Public Subnets)     │
            └─────────────┬────────────┘
                          │
                          ▼
            ┌──────────────────────────┐
            │  EC2 Auto Scaling Group  │
            │   (Private App Subnets)  │
            └─────────────┬────────────┘
                          │
                          ▼
            ┌──────────────────────────┐
            │        RDS MySQL         │
            │   (Private DB Subnets)   │
            └──────────────────────────┘

---

## 🧱 Network Architecture

| Layer | Subnet Type | Internet Access | Purpose |
|-------|------------|----------------|----------|
| ALB   | Public     | Yes (via IGW)  | Handles incoming traffic |
| EC2   | Private App| Outbound only (via NAT) | Application layer |
| RDS   | Private DB | No internet access | Data layer |

---

## 🔐 Security Design

This architecture implements strict tier isolation:

- ALB allows HTTP from `0.0.0.0/0`
- EC2 only accepts traffic from ALB security group
- RDS only accepts traffic from EC2 security group
- Database is not publicly accessible
- DB runs in isolated private DB subnets
- Encrypted storage enabled on RDS

This ensures layered defense and minimized attack surface.

---

## ⚙️ Features Implemented

- VPC with public, private app, and private DB subnets  
- Internet Gateway + NAT Gateway  
- Application Load Balancer  
- Auto Scaling Group (CPU target tracking at 50%)  
- RDS MySQL (encrypted, backup enabled)  
- Dedicated DB Subnet Group  
- Security Group chaining (ALB → EC2 → RDS)  
- CloudWatch monitoring  
- SNS email alerts  
- Modular Terraform design  

---

## 📂 Project Structure

```
📂 Project Structure
multi-tier-aws/
│
├── modules/
│   ├── network/
│   ├── security/
│   ├── loadbalancer/
│   ├── compute/
│   ├── database/
│   └── monitoring/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
└── README.md
```
---

## 🚀 Deployment Instructions

### 1️⃣ Clone Repository
git clone https://github.com/mia-rashel/Production-Grade-3-Tier-AWS-Architecture

cd Production-Grade-3-Tier-AWS-Architecture
### 2️⃣ Create Your Own Variables File

Copy:

cp terraform.tfvars.example terraform.tfvars

Update values:

vpc_cidr    = "10.0.0.0/16"

my_ip       = "YOUR_PUBLIC_IP/32"

db_username = "admin"

db_password = "StrongPassword123!"

alert_email = "your-email@example.com"

### 3️⃣ Initialize Terraform
terraform init

terraform plan

terraform apply
### 4️⃣ Access Application

After apply completes:

terraform output alb_dns_name

Paste the DNS name into your browser.

## 📊 Monitoring & Scaling

### Auto Scaling Policy:

- Target Tracking

- 50% Average CPU Utilization

### Monitoring:

- CloudWatch metrics

- RDS connection tracking

- SNS email alerts

### 🏆 Production-Grade Characteristics

This project demonstrates:

- Logical + network-level tier isolation

- Infrastructure as Code (modular design)

- No hardcoded credentials

- Secure subnet segmentation

- Automated scaling

- Observability integration

- Encrypted database storage

### 🔮 Possible Enhancements

- Multi-AZ RDS deployment

- Read replicas

- HTTPS (ACM + TLS)

- WAF integration

- CI/CD pipeline (GitHub Actions)

- Remote state (S3 + DynamoDB locking)

- Secrets Manager integration

### 🧠 Author

Muhammad Rashel Mia
Cloud & DevOps Engineer
