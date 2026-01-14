#!/bin/bash
#
# maestrohwithit Infrastructure Deployment Script
# This script automates the deployment process for any environment
#
# Usage: ./scripts/deploy.sh <environment> <action>
# Example: ./scripts/deploy.sh dev apply
#

set -e  # Exit on error
set -u  # Exit on undefined variable

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check arguments
if [ $# -lt 2 ]; then
    log_error "Usage: $0 <environment> <action>"
    echo ""
    echo "Environments: dev, staging, prod"
    echo "Actions: init, plan, apply, destroy, output"
    exit 1
fi

ENVIRONMENT=$1
ACTION=$2
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_DIR="$PROJECT_ROOT/environments/$ENVIRONMENT"

# Validate environment
if [ ! -d "$ENV_DIR" ]; then
    log_error "Environment '$ENVIRONMENT' not found!"
    echo "Available environments:"
    ls -1 "$PROJECT_ROOT/environments/"
    exit 1
fi

log_info "Deploying to: ${YELLOW}$ENVIRONMENT${NC}"
log_info "Action: ${YELLOW}$ACTION${NC}"
echo ""

# Change to environment directory
cd "$ENV_DIR"

# Pre-flight checks
log_info "Running pre-flight checks..."

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &>/dev/null; then
    log_error "AWS credentials not configured!"
    echo "Run: aws configure"
    exit 1
fi
log_success "AWS credentials valid"

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    log_warning "terraform.tfvars not found! Using defaults."
fi

# Check Terraform version
TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version')
log_success "Terraform version: $TERRAFORM_VERSION"

# Get AWS account info
AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)
log_info "AWS Account: $AWS_ACCOUNT"
log_info "AWS Region: $AWS_REGION"
echo ""

# Confirmation for production
if [ "$ENVIRONMENT" == "prod" ]; then
    log_warning "You are about to modify PRODUCTION infrastructure!"
    read -p "Are you sure you want to continue? (type 'yes' to confirm): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        log_info "Deployment cancelled."
        exit 0
    fi
fi

# Execute action
case $ACTION in
    init)
        log_info "Initializing Terraform..."
        terraform init -upgrade
        log_success "Terraform initialized successfully"
        ;;
        
    plan)
        log_info "Running Terraform plan..."
        terraform plan -var-file=terraform.tfvars -out=tfplan.out
        log_success "Plan saved to tfplan.out"
        echo ""
        log_info "Review the plan above. To apply, run:"
        echo "  $0 $ENVIRONMENT apply"
        ;;
        
    apply)
        # Check if plan exists
        if [ -f "tfplan.out" ]; then
            log_info "Applying existing plan..."
            terraform apply tfplan.out
            rm tfplan.out
        else
            log_warning "No existing plan found. Creating new plan..."
            terraform plan -var-file=terraform.tfvars -out=tfplan.out
            echo ""
            log_info "Review the plan above."
            read -p "Do you want to apply these changes? (yes/no): " APPLY_CONFIRM
            if [ "$APPLY_CONFIRM" == "yes" ]; then
                terraform apply tfplan.out
                rm tfplan.out
            else
                log_info "Apply cancelled. Plan saved to tfplan.out"
                exit 0
            fi
        fi
        log_success "Infrastructure deployed successfully!"
        
        # Show outputs
        echo ""
        log_info "Infrastructure outputs:"
        terraform output
        ;;
        
    destroy)
        log_error "DANGER: This will destroy all infrastructure in $ENVIRONMENT!"
        read -p "Type the environment name to confirm: " CONFIRM_ENV
        if [ "$CONFIRM_ENV" != "$ENVIRONMENT" ]; then
            log_info "Destroy cancelled."
            exit 0
        fi
        
        log_warning "Destroying infrastructure..."
        terraform destroy -var-file=terraform.tfvars
        log_success "Infrastructure destroyed"
        ;;
        
    output)
        log_info "Infrastructure outputs:"
        terraform output
        ;;
        
    validate)
        log_info "Validating Terraform configuration..."
        terraform fmt -check -recursive
        terraform validate
        log_success "Configuration is valid"
        ;;
        
    *)
        log_error "Unknown action: $ACTION"
        echo "Valid actions: init, plan, apply, destroy, output, validate"
        exit 1
        ;;
esac

echo ""
log_success "Deployment script completed successfully!"
