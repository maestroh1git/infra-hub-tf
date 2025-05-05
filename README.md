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
