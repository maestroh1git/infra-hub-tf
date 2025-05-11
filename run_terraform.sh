#!/bin/bash

# Set the directory where your Terraform files are located
TERRAFORM_DIR="/path/to/your/terraform/project"

# Exit if any command fails
set -e

# Navigate to the Terraform directory
cd "$TERRAFORM_DIR" || { echo "Directory not found: $TERRAFORM_DIR"; exit 1; }

# Initialize Terraform
echo "Initializing Terraform..."
terraform init -input=false

# Validate Terraform configuration
echo "Validating Terraform configuration..."
terraform validate

# Run a Terraform plan to test
echo "Running Terraform plan..."
terraform plan -out=tfplan.out

# Apply the plan
echo "Applying Terraform plan..."
terraform apply -auto-approve tfplan.out

echo "Terraform apply complete ✅"
