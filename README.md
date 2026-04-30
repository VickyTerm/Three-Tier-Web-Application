# 🚀 AWS 3-Tier Web Application Architecture (Production-Style DevOps Project)

## 📌 Project Overview

This project demonstrates a **complete production-style 3-Tier Web Application Architecture on AWS** built using modern DevOps practices.

The architecture is designed with **high availability, scalability, security, modular Infrastructure as Code, and cloud-native best practices**.

It simulates how enterprise-grade applications are deployed in real-world environments.

---

# 🏗️ Architecture Diagram

> Add your architecture image here

```text
three-tier-aws/
```

Recommended Screenshot:

* AWS Architecture Diagram
* Terraform folder structure
* Application UI / Health Page
* AWS Console screenshots

---

# 🧱 Architecture Components

## 🌐 Web Tier (Presentation Layer)

* Public Application Load Balancer (ALB)
* Nginx reverse proxy running on EC2
* Hosted inside Public Subnets
* Receives internet traffic
* Routes traffic to App Tier

### Components

* 2 Web EC2 Instances
* Public ALB
* Security Group isolation
* Nginx reverse proxy

---

## ⚙️ App Tier (Business Logic Layer)

* Internal Application Load Balancer
* Node.js + Express Application
* Auto Scaling Group
* Hosted in Private App Subnets
* Accessible only internally

### Components

* Auto Scaling Group
* Launch Template
* Internal ALB
* Node.js Express API
* Health endpoints

---

## 🗄️ Database Tier (Data Layer)

* MySQL Database hosted on Amazon RDS
* Hosted in Private Database Subnets
* No public access
* Secure connectivity from App Tier only

### Components

* RDS MySQL 8.0
* DB Subnet Group
* Dedicated Security Group
* Private networking

---

# ☁️ AWS Services Used

| Service                   | Purpose                              |
| ------------------------- | ------------------------------------ |
| Amazon VPC                | Network isolation                    |
| Public Subnets            | Web tier hosting                     |
| Private Subnets           | App tier hosting                     |
| Database Subnets          | RDS deployment                       |
| Internet Gateway          | Public internet access               |
| NAT Gateway               | Outbound access from private subnets |
| Application Load Balancer | Traffic distribution                 |
| EC2                       | Web + App servers                    |
| Auto Scaling Group        | High availability                    |
| RDS MySQL                 | Database layer                       |
| Security Groups           | Least privilege networking           |
| IAM                       | Access control                       |
| CloudWatch                | Monitoring                           |
| S3                        | Static assets and logs               |

---

# 🛠️ Tech Stack

## Infrastructure

* Terraform
* AWS
* Linux (Amazon Linux 2023)

## DevOps Tools

* Terraform
* GitHub Actions
* Jenkins
* Docker
* Ansible

## Backend

* Node.js
* Express.js
* MySQL
* Nginx

---

# 📂 Project Structure

```text
three-tier-aws/
│
├── provider.tf
├── variables.tf
├── outputs.tf
├── main.tf
├── terraform.tfvars
├── README.md
│
├── modules/
│   ├── networking/
│   ├── security/
│   ├── alb/
│   ├── app-tier/
│   ├── web-tier/
│   ├── rds/
│   └── monitoring/
│
├── ansible/
│   ├── web-tier.yml
│   ├── app-tier.yml
│   └── inventory
│
├── docker/
│   └── Dockerfile
│
├── app/
│   ├── app.js
│   ├── config/
│   ├── routes/
│   ├── package.json
│   └── .env
│
└── .github/
    └── workflows/
        └── terraform-ci.yml
```

---

# 🔐 Security Best Practices Implemented

* Least privilege security groups
* Private application layer
* Private RDS deployment
* Internal Load Balancer
* Separate subnet tiers
* No direct database exposure
* Infrastructure as Code
* Randomized DB password generation
* IAM role-based permissions

---

# 🌍 Traffic Flow

```text
Internet
   ↓
Public ALB
   ↓
Nginx Web EC2
   ↓
Internal ALB
   ↓
Node.js App Tier
   ↓
RDS MySQL
```

---

# ⚡ Deployment Steps

## 1. Clone Repository

```bash
git clone <your-repo-url>
cd three-tier-aws
```

---

## 2. Initialize Terraform

```bash
terraform init
```

---

## 3. Validate Terraform

```bash
terraform validate
```

---

## 4. Preview Infrastructure

```bash
terraform plan
```

---

## 5. Deploy Infrastructure

```bash
terraform apply
```

---

## 6. Destroy Infrastructure

```bash
terraform destroy
```

---

# 📈 Features Implemented

✅ Highly Available Multi-AZ VPC
✅ Public + Private Subnet Architecture
✅ NAT Gateway Routing
✅ Public + Internal Load Balancers
✅ Auto Scaling Group
✅ Nginx Reverse Proxy
✅ Node.js App Tier
✅ RDS MySQL Integration
✅ Security Group Segmentation
✅ Infrastructure as Code (Terraform)
✅ Production-style Networking

---

# 🚀 Future Enhancements

* CloudFront + WAF
* Secrets Manager integration
* CloudWatch monitoring dashboards
* Dockerized App Tier
* ECS/Fargate migration
* GitHub Actions CI/CD
* Blue/Green deployment
* SSL/TLS using ACM
* Route53 custom domain
* Full Observability Stack

---

# 📊 AWS Well-Architected Principles Followed

* Operational Excellence
* Security
* Reliability
* Performance Efficiency
* Cost Optimization
* Sustainability

---

# 🎯 Learning Outcomes

This project demonstrates hands-on expertise in:

* AWS Networking
* Infrastructure as Code
* Terraform Modularization
* DevOps Automation
* High Availability Design
* Security Architecture
* Application Load Balancing
* Auto Scaling
* Private Networking
* RDS Integration

---

# 🧑‍💻 Author

**VickyTricky**
DevOps & Cloud Engineering Enthusiast

---

# ⭐ Support

If you found this project useful:

* ⭐ Star the repository
* 🍴 Fork the project
* 📢 Share with others

---

# 📜 License

This project is for educational and portfolio purposes.

MIT License
