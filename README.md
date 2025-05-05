# Trila Infrastructure

![GitHub last commit](https://img.shields.io/github/last-commit/Trila-USA/Trila-infra)
![GitHub issues](https://img.shields.io/github/issues/Trila-USA/Trila-infra)
![GitHub pull requests](https://img.shields.io/github/issues-pr/Trila-USA/Trila-infra)

This repository contains Terraform code for provisioning and managing AWS infrastructure for the Trila platform, including VPC, EC2, EKS, RDS, Route53, and other AWS services.

## Table of Contents

- [Architecture](#architecture)
- [Folder Structure](#folder-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Output Parameters](#output-parameters)
- [Infrastructure Components](#infrastructure-components)
- [CI/CD Integration](#cicd-integration)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Support](#support)

## Architecture

![Trila Infrastructure Architecture](architecture-diagram.png)

The architecture consists of the following components:

- **VPC**: Custom networking setup with public and private subnets across multiple availability zones  
- **EC2 Instances**: Application servers with predefined security groups and IAM roles  
- **EKS Cluster**: Kubernetes cluster for container orchestration and application deployment  
- **Route53**: DNS management for service endpoints and domain routing  
- **IAM Policies**: Security and access control configurations  
- **S3**: Storage for application assets, logs, and backups  
- **SES**: Email service integration for notifications and user communications  
- **CloudWatch**: Monitoring and logging for infrastructure and application metrics  

## Folder Structure

```bash
trila-infra/
├── environments/
│   └── dev/
│       └── vpc.tfvars
├── infra/
│   ├── acm/                  # AWS Certificate Manager configs
│   ├── backend/              # Terraform backend configuration
│   ├── ec2/                  # EC2 instance definitions
│   ├── eks-cluster/          # Kubernetes cluster setup
│   ├── iam-policies/         # Identity and access management
│   ├── rds/                  # Database configurations
│   ├── route53/              # DNS configurations
│   ├── ses/                  # Simple Email Service
│   ├── sg/                   # Security Groups
│   ├── tag-policy/           # Resource tagging policies
│   └── vpc/                  # Virtual Private Cloud setup
├── modules/
│   ├── acm/                  # Reusable Certificate Manager module
│   ├── alb/                  # Application Load Balancer module
│   ├── asg/                  # Auto Scaling Group module
│   ├── cloudwatch/           # Monitoring module
│   ├── ec2/                  # Reusable EC2 module
│   ├── eks/                  # Reusable EKS module
│   ├── iam-policy/           # IAM policy module
│   ├── rds/                  # Database module
│   └── route53/              # DNS module
├── main.tf                   # Main Terraform configuration
├── variables.tf              # Input variables
├── outputs.tf                # Output definitions
└── route-tables.tf           # Network routing configuration
```

## Prerequisites

Before you begin, ensure you have the following tools and accounts set up:

### AWS Account

- Sign up for an AWS account: [AWS Free Tier](https://aws.amazon.com/free/)
- Create an IAM user with `AdministratorAccess` or appropriate permissions: [Creating IAM Users](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)
- Generate and securely store your **Access Key** and **Secret Key**

### AWS CLI

Install the AWS CLI:

- **Windows**: [Download](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html)
- **macOS**: [Download](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html)
- **Linux**:
  ```bash
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  ```

Configure AWS CLI:
```bash
aws configure
```

### Terraform

Install Terraform v1.0 or later:

- [Download Terraform](https://www.terraform.io/downloads)
- **Windows**: `choco install terraform`
- **macOS**: `brew install terraform`
- **Linux**:
  ```bash
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install terraform
  ```

Verify:
```bash
terraform -v
```

### Git

Install Git:

- **Windows**: [Download](https://git-scm.com/download/win)
- **macOS**: `brew install git`
- **Linux**: `sudo apt install git`

Verify:
```bash
git --version
```

### kubectl (for EKS management)

Install `kubectl`:

- [Installation Guide](https://kubernetes.io/docs/tasks/tools/)
- **Windows**: `choco install kubernetes-cli`
- **macOS**: `brew install kubectl`
- **Linux**:
  ```bash
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  ```

Verify:
```bash
kubectl version --client
```

### eksctl (optional, for EKS management)

Install `eksctl`:

- [Installation Guide](https://eksctl.io/introduction/#installation)
- **Windows**: `choco install eksctl`
- **macOS**: `brew install eksctl`
- **Linux**:
  ```bash
  curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
  sudo mv /tmp/eksctl /usr/local/bin
  ```

Verify:
```bash
eksctl version
```

---

## Installation

Clone the repository:
```bash
git clone https://github.com/Trila-USA/Trila-infra.git
cd Trila-infra
```

(Recommended) Install `pre-commit` hooks:
```bash
pip install pre-commit
pre-commit install
```

Set up AWS credentials:
```bash
aws configure
# Enter AWS Access Key ID, Secret Access Key, default region, and output format
```

Initialize Terraform:
```bash
terraform init
```

### (Optional) Setup S3 Backend for Remote State

Create S3 bucket and DynamoDB table:
```bash
aws s3 mb s3://trila-terraform-state

aws dynamodb create-table \
  --table-name trila-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

Update `backend/main.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "trila-terraform-state"
    key            = "trila-infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "trila-terraform-locks"
    encrypt        = true
  }
}
```

Reinitialize the backend:
```bash
terraform init -reconfigure
```
# Trila Terraform Infrastructure

This repository manages the infrastructure for the **Trila** project using Terraform. It supports multiple environments such as `dev`, `staging`, and `prod`.

---

## 🔧 Configuration

### Environment Variables

Set up the required environment variables before running Terraform:

```bash
# Required
export TF_VAR_environment=dev         # Options: dev, staging, prod
export TF_VAR_aws_region=us-east-1

# Optional
export TF_VAR_vpc_cidr="10.0.0.0/16"
export TF_VAR_project="trila"

### Configuration Files

Create or update environment-specific variable files under `environments/{env}/`.

Example: `environments/dev/vpc.tfvars`

```hcl
project          = "trila"
environment      = "dev"
vpc_cidr         = "10.0.0.0/16"
azs              = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnets   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

---

## 🏗️ Infrastructure Components

### Virtual Private Cloud (VPC)
- Multi-AZ deployment
- Public and private subnets
- NAT Gateway for outbound connectivity
- Internet Gateway for public access

### EC2 Instances
- Auto-scaled application servers
- Security groups with principle of least privilege
- Instance profiles with appropriate IAM roles

### EKS Cluster
- Managed Kubernetes cluster
- Worker nodes distributed across AZs
- Auto-scaling node groups

### Database (RDS)
- Relational database for application data
- Encryption at rest
- Automatic backups

### Security
- IAM roles and policies
- Security groups
- Network ACLs
- Key management (KMS)

### Monitoring
- CloudWatch dashboards
- Alarms and notifications
- Log aggregation

---

## ⚙️ CI/CD Integration

This repository integrates with CI/CD pipelines through **GitHub Actions**. The workflow includes:

- **Terraform Format and Validation**: Ensures code follows best practices
- **Terraform Security Scanning**: Uses `tfsec` and `checkov` to identify security issues
- **Terraform Plan**: Generates and validates execution plan
- **Terraform Apply**: Applies changes to infrastructure (on `main` branch only)

---

## 🧪 Example GitHub Actions Workflow

Example: `.github/workflows/terraform.yml`

```yaml
name: "Terraform CI/CD"

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  terraform:
    name: "Terraform"
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.x

      - name: Terraform Format
        run: terraform fmt -check -recursive

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Security Scan
        uses: aquasecurity/tfsec-action@v1.0.0

      - name: Terraform Plan
        run: terraform plan -var-file=environments/dev/vpc.tfvars
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        run: terraform apply -var-file=environments/dev/vpc.tfvars -auto-approve
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
