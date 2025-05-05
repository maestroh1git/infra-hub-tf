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

