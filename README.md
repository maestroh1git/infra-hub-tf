# maestrohwithit Infrastructure

![GitHub last commit](https://img.shields.io/github/last-commit/maestroh1git/infra-hub-tf)
![GitHub issues](https://img.shields.io/github/issues/maestroh1git/infra-hub-tf)
![GitHub pull requests](https://img.shields.io/github/issues-pr/maestroh1git/infra-hub-tf)
![Terraform](https://img.shields.io/badge/Terraform-1.6.6-blue)
![AWS](https://img.shields.io/badge/AWS-Cloud-orange)

🎉 **Production-Ready Infrastructure as Code** for the maestrohwithit platform with multi-environment support, comprehensive security, automated backups, and disaster recovery.

## 🌟 Features

- ✅ **Multi-Environment Support** (dev, staging, production)
- ✅ **Security Scanning** (tfsec, Checkov) in CI/CD
- ✅ **Automated Backups** with AWS Backup
- ✅ **VPC Flow Logs** for network monitoring
- ✅ **Secrets Management** with AWS Secrets Manager
- ✅ **CloudWatch Alarms** for proactive monitoring
- ✅ **Disaster Recovery** procedures and runbooks
- ✅ **Pre-commit Hooks** for code quality
- ✅ **Modular Design** for reusability

## 📋 Table of Contents

- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Environments](#environments)
- [Folder Structure](#folder-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Infrastructure Modules](#infrastructure-modules)
- [CI/CD Pipeline](#cicd-pipeline)
- [Security](#security)
- [Monitoring & Alerts](#monitoring--alerts)
- [Disaster Recovery](#disaster-recovery)
- [Documentation](#documentation)
- [Troubleshooting](#troubleshooting)

## 🏗️ Architecture

The architecture provides production-grade AWS infrastructure with:

- **Multi-AZ VPC** with public and private subnets
- **EKS Cluster** for container orchestration
- **RDS Databases** with automated backups
- **Application Load Balancers** for traffic distribution
- **S3 Buckets** for logs, backups, and assets
- **KMS Encryption** for data at rest
- **CloudWatch Integration** for comprehensive monitoring

![Architecture Diagram](docs/architecture-diagram.png)

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/maestrohwithit-USA/maestrohwithit-infra.git
cd maestrohwithit-infra

# Install pre-commit hooks
pip install pre-commit
pre-commit install

# Configure AWS credentials
aws configure

# Navigate to environment
cd environments/dev

# Initialize and deploy
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## 🌍 Environments

| Environment | Purpose | Resources | Cost/Month | 
|-------------|---------|-----------|------------|
| **dev** | Development & testing | Minimal (1 AZ, t3.micro) | ~$50-100 |
| **staging** | Pre-production testing | Moderate (2 AZs, t3.small) | ~$150-250 |
| **prod** | Production workloads | Full HA (3 AZs, t3.medium+) | ~$500-1000+ |

Each environment is completely isolated with:
- Separate VPC (different CIDR ranges)
- Independent Terraform state
- Environment-specific configurations
- Dedicated CI/CD workflows

📖 **Learn more:** [Environment Management Guide](docs/ENVIRONMENTS.md)

## 📁 Folder Structure

```bash
maestrohwithit-infra/
├── environments/              # Environment-specific configurations
│   ├── dev/
│   │   ├── main.tf           # Dev infrastructure
│   │   ├── variables.tf      # Variable definitions
│   │   ├── terraform.tfvars  # Dev values ✅ Version controlled
│   │   └── outputs.tf        # Output values
│   ├── staging/              # Staging environment
│   └── prod/                 # Production environment
│
├── modules/                   # Reusable Terraform modules
│   ├── vpc/                  # VPC with subnets, NAT, IGW
│   ├── vpc-flow-logs/        # VPC network monitoring ⭐ NEW
│   ├── ec2/                  # EC2 instances
│   ├── eks/                  # Kubernetes cluster
│   ├── rds/                  # Managed databases
│   ├── alb/                  # Load balancers
│   ├── asg/                  # Auto Scaling groups
│   ├── s3-storage/           # S3 buckets for logs/backups ⭐ NEW
│   ├── kms/                  # Encryption keys ⭐ NEW
│   ├── backup/               # AWS Backup plans ⭐ NEW
│   ├── cloudwatch-alarms/    # Monitoring alarms ⭐ NEW
│   ├── cloudwatch/           # Logging & metrics
│   ├── acm/                  # SSL certificates
│   ├── route53/              # DNS management
│   ├── ses/                  # Email service
│   ├── sg/                   # Security groups
│   ├── iam-policy/           # IAM policies
│   ├── state_lock/           # Terraform state locking
│   └── tag-policy/           # Resource tagging
│
├── .github/workflows/         # CI/CD pipelines
│   ├── terraform.yaml        # Dev deployment (auto)
│   ├── terraform-staging.yaml # Staging deployment
│   └── terraform-prod.yaml   # Prod deployment (manual approval)
│
├── docs/                      # Documentation
│   ├── ENVIRONMENTS.md       # Environment management guide
│   ├── SECRETS_MANAGEMENT.md # Secrets & credentials guide
│   └── DISASTER_RECOVERY.md  # DR procedures & runbooks
│
├── .pre-commit-config.yaml   # Pre-commit hooks ⭐ NEW
├── .gitignore                # Git ignore rules
└── README.md                 # This file
```

## ⚙️ Prerequisites

### Required Tools

| Tool | Version | Purpose |
|------|---------|---------|
| **Terraform** | ≥ 1.6.6 | Infrastructure provisioning |
| **AWS CLI** | ≥ 2.x | AWS resource management |
| **kubectl** | Latest | Kubernetes management |
| **Git** | ≥ 2.x | Version control |
| **pre-commit** | Latest | Code quality hooks |

### Installation

#### Terraform
```bash
# macOS
brew install terraform

# Linux
wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
unzip terraform_1.6.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Verify
terraform version
```

#### AWS CLI
```bash
# macOS
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure
aws configure
```

#### Pre-commit Hooks
```bash
pip install pre-commit
pre-commit install

# Test hooks
pre-commit run --all-files
```

## 🔧 Installation

### 1. Clone Repository

```bash
git clone https://github.com/maestrohwithit-USA/maestrohwithit-infra.git
cd maestrohwithit-infra
```

### 2. Configure AWS Credentials

```bash
aws configure
# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region: us-east-2
# - Output format: json
```

### 3. Create S3 Backend (First Time Only)

```bash
# Create S3 bucket for Terraform state
aws s3 mb s3://maestrohwithit-infra-bucket --region us-east-2

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket maestrohwithit-infra-bucket \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name maestrohwithit-backend-state-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-2
```

### 4. Initialize Terraform

```bash
cd environments/dev
terraform init
```

## 📖 Usage

### Deploy to Development

```bash
cd environments/dev

# Review changes
terraform plan -var-file=terraform.tfvars

# Apply changes
terraform apply -var-file=terraform.tfvars
```

### Deploy to Staging/Production

For staging and production, use GitHub Actions workflows (see CI/CD section).

### View Outputs

```bash
# Show all outputs
terraform output

# Show specific output
terraform output vpc_id

# Export outputs as JSON
terraform output -json > outputs.json
```

### Destroy Resources

```bash
# Preview what will be destroyed
terraform plan -destroy -var-file=terraform.tfvars

# Destroy (use with caution!)
terraform destroy -var-file=terraform.tfvars
```

## 🧩 Infrastructure Modules

### Core Networking
- **vpc**: Multi-AZ VPC with public/private subnets, NAT gateways, internet gateway
- **vpc-flow-logs**: Network traffic logging to CloudWatch
- **sg**: Security groups with ingress/egress rules

### Compute
- **ec2**: EC2 instances with EBS volumes and EIPs
- **asg**: Auto Scaling groups with launch templates
- **eks**: Managed Kubernetes cluster with node groups

### Storage & Database
- **rds**: Managed PostgreSQL/MySQL with Multi-AZ support
- **s3-storage**: S3 buckets with versioning, encryption, lifecycle policies

### Security
- **kms**: KMS encryption keys for data at rest
- **iam-policy**: IAM roles and policies
- **backup**: AWS Backup plans with retention policies

### Monitoring & Logging
- **cloudwatch-alarms**: CPU, memory, disk, and custom metric alarms
- **cloudwatch**: Log groups and metric filters

### Networking Services
- **alb**: Application Load Balancers with target groups
- **route53**: DNS zones and records
- **acm**: SSL/TLS certificates

## 🔄 CI/CD Pipeline

### Automated Checks

All pull requests and merges run:

1. ✅ **Terraform Format Check** - Ensures consistent formatting
2. 🔒 **Security Scanning** - tfsec + Checkov for vulnerabilities
3. ✔️ **Terraform Validate** - Syntax and logic validation
4. 📋 **Terraform Plan** - Preview infrastructure changes

### Environment Workflows

| Environment | Trigger | Approval Required | Workflow File |
|-------------|---------|-------------------|---------------|
| **Dev** | Push to `main` (dev paths) | No | `terraform.yaml` |
| **Staging** | Push to `main` OR manual | No | `terraform-staging.yaml` |
| **Prod** | Manual dispatch only | ✅ Yes | `terraform-prod.yaml` |

### Manual Production Deployment

```bash
# Via GitHub Actions UI:
1. Go to Actions tab
2. Select "Terraform Production Environment"
3. Click "Run workflow"
4. Choose action: "plan" or "apply"
5. For "apply", designated reviewer must approve
```

### Required GitHub Secrets

```
AWS_ACCESS_KEY_ID           # For dev/staging
AWS_SECRET_ACCESS_KEY       # For dev/staging
AWS_ACCESS_KEY_ID_PROD      # For production
AWS_SECRET_ACCESS_KEY_PROD  # For production
```

## 🔒 Security

### Secrets Management

All sensitive data is managed with AWS Secrets Manager:

- RDS passwords (auto-generated)
- API keys and tokens
- SSL certificate private keys

📖 **Learn more:** [Secrets Management Guide](docs/SECRETS_MANAGEMENT.md)

### Encryption

- **At Rest**: KMS encryption for EBS, RDS, S3
- **In Transit**: TLS/SSL for all external communication
- **Secrets**: AWS Secrets Manager with automatic rotation

### Network Security

- **VPC Isolation**: Separate VPCs per environment
- **Security Groups**: Principle of least privilege
- **Network ACLs**: Additional subnet-level filtering
- **VPC Flow Logs**: All network traffic logged

### Compliance

- **Security Scanning**: Automated with tfsec and Checkov
- **Pre-commit Hooks**: Prevent secrets in code
- **Resource Tagging**: Complete audit trail

## 📊 Monitoring & Alerts

### CloudWatch Alarms

Automatic alerts for:
- EC2 CPU > 80%
- RDS CPU > 80%
- RDS storage < 10GB
- RDS connections > 80
- ALB response time > 1s
- ALB unhealthy targets > 0
- EKS node CPU > 80%

### SNS Notifications

Configure email alerts:
```bash
# Subscribe to alarm topic
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-2:xxx:prod-maestrohwithit-alarms \
  --protocol email \
  --notification-endpoint your-email@example.com
```

### VPC Flow Logs

All network traffic logged to CloudWatch:
```bash
# View recent flow logs
aws logs tail /aws/vpc/prod-maestrohwithit-flow-logs --follow
```

## 🆘 Disaster Recovery

### Backup Strategy

| Resource | Frequency | Retention (Prod) | Retention (Staging) |
|----------|-----------|------------------|---------------------|
| RDS | Continuous | 30 days | 7 days |
| EBS | Daily | 30 days | 7 days |
| EC2 AMI | Weekly | 30 days | 7 days |

### Recovery Objectives

- **RTO (Recovery Time Objective)**: 1 hour for production
- **RPO (Recovery Point Objective)**: 5 minutes for production

📖 **Full procedures:** [Disaster Recovery Runbook](docs/DISASTER_RECOVERY.md)

### Quick Recovery

```bash
# List latest backups
aws backup list-recovery-points-by-backup-vault \
  --backup-vault-name prod-maestrohwithit-backup-vault \
  --max-results 10

# Restore RDS from snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier prod-maestrohwithit-db-restored \
  --db-snapshot-identifier rds:prod-maestrohwithit-db-2024-01-01-05-00
```

## 🤖 Automation Scripts

Helpful scripts to simplify common operations:

| Script | Purpose | Example |
|--------|---------|---------|
| **deploy.sh** | Deploy infrastructure | `./scripts/deploy.sh dev apply` |
| **cost-monitor.sh** | Monitor AWS costs | `./scripts/cost-monitor.sh` |
| **check-backups.sh** | Verify backups | `./scripts/check-backups.sh prod` |
| **security-audit.sh** | Security scanning | `./scripts/security-audit.sh` |

📖 **Full documentation:** [Scripts README](scripts/README.md)

### Quick Examples

```bash
# Deploy to development
./scripts/deploy.sh dev apply

# Check monthly costs
./scripts/cost-monitor.sh

# Verify backups are working
./scripts/check-backups.sh prod

# Run security audit
./scripts/security-audit.sh
```

## 📚 Documentation

- **[Usage Guide](docs/USAGE_GUIDE.md)** - Complete real-world deployment lifecycle
- **[Quick Reference](docs/QUICK_REFERENCE.md)** - Essential commands and workflows
- **[Environment Management](docs/ENVIRONMENTS.md)** - Dev, staging, prod configuration
- **[Secrets Management](docs/SECRETS_MANAGEMENT.md)** - AWS Secrets Manager guide
- **[Disaster Recovery](docs/DISASTER_RECOVERY.md)** - DR procedures and runbooks
- **[Scripts Documentation](scripts/README.md)** - Automation scripts reference

## 🐛 Troubleshooting

### Common Issues

#### State Lock Error

```bash
# If Terraform state is locked
terraform force-unlock <LOCK_ID>
```

#### AWS Credentials Not Found

```bash
# Verify AWS configuration
aws sts get-caller-identity

# Re-configure if needed
aws configure
```

#### Pre-commit Hooks Failing

```bash
# Update pre-commit hooks
pre-commit autoupdate

# Run specific hook
pre-commit run terraform_fmt --all-files
```

#### Terraform Init Fails

```bash
# Clean and reinitialize
rm -rf .terraform
terraform init -reconfigure
```

### Getting Help

- 📧 **Email**: hello@maestrohwithit.africa
- 🎫 **Issues**: [GitHub Issues](https://github.com/maestroh1git/infra-hub-tf/issues)
- 📖 **Docs**: Check the `docs/` directory

## 🤝 Contributing

1. Create a feature branch: `git checkout -b feature/my-feature`
2. Make changes and test in `dev` environment
3. Run pre-commit hooks: `pre-commit run --all-files`
4. Commit changes: `git commit -m "feat: add new feature"`
5. Push branch: `git push origin feature/my-feature`
6. Create Pull Request

### Commit Message Format

```
<type>: <description>

Types: feat, fix, docs, style, refactor, test, chore
```

## 📄 License

Copyright © 2026 maestrohwithit Inc. All rights reserved.

## 🙏 Support

For support and questions:
- **Email**: hello@maestrohwithit.africa
- **Slack**: #infrastructure channel
- **On-Call**: PagerDuty rotation

---

**Built with ❤️ by the maestrohwithit DevOps Team**

Last Updated: 2026-01-20
