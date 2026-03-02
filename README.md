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
- Multi-AZ high availability
- Auto Scaling compute layer
- Enterprise-grade RDS deployment
- Remote state management (S3 + DynamoDB)
- CloudWatch monitoring & alerting
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
            │  RDS MySQL(Multi-AZ      |
            │     + Read Replica       |
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
## Enterprise Database Architecture
### High Availability (Multi-AZ)

The primary RDS instance is deployed in Multi-AZ mode, providing:

 - Synchronous standby replica
 - Automatic failover during AZ failure
 - Same database endpoint after failover
 - Minimal downtime

If one Availability Zone fails, AWS automatically promotes the standby instance.
### Read Scaling (Read Replica)
A dedicated Read Replica is deployed to:

- Offload read-heavy workloads
- Improve scalability
- Support horizontal database scaling

Characteristics:
- Asynchronous replication
- Separate endpoint
- Can be manually promoted if needed

Multi-AZ ensures availability.
Read Replica ensures scalability.
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
- Multi-AZ Application Load Balancer
- Multi-AZ Auto Scaling Group
- CPU Target Tracking (50%)
- RDS MySQL (Multi-AZ enabled)
- Dedicated Read Replica
- Dedicated DB Subnet Group
- Security Group chaining (ALB → EC2 → RDS)
- CloudWatch monitoring
- SNS email alerts
- Modular Terraform structure
- Remote state management (S3 + DynamoDB locking)

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

## 🗄 Terraform Remote State Management

This project uses a production-ready Terraform backend configuration:

- Remote state stored in **Amazon S3**
- State locking implemented using **DynamoDB**
- Server-side encryption enabled
- Centralized state for collaborative deployments

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
- Secrets Manager integration

### 🧠 Author

Muhammad Rashel Mia
Cloud & DevOps Engineer
