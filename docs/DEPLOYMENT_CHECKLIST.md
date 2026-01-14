# Initial Deployment Checklist

Complete this checklist before your first infrastructure deployment.

## ☑️ Pre-Deployment

### AWS Account Setup

- [ ] AWS account created and active
- [ ] Billing alerts configured
- [ ] IAM user created with AdministratorAccess
- [ ] Access key and secret key generated
- [ ] MFA enabled on root account
- [ ] MFA enabled on IAM user account

### Local Environment

- [ ] Terraform installed (>= 1.6.6)
- [ ] AWS CLI installed (>= 2.x)
- [ ] kubectl installed
- [ ] Git installed
- [ ] jq installed
- [ ] pre-commit installed
- [ ] Repository cloned

### AWS CLI Configuration

```bash
# Run this:
aws configure
# Verify:
aws sts get-caller-identity
```

- [ ] AWS CLI configured
- [ ] Credentials validated

### Remote State Backend

```bash
# Create S3 bucket
aws s3 mb s3://maestrohwithit-infra-bucket --region us-east-2

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket maestrohwithit-infra-bucket \
  --versioning-configuration Status=Enabled

# Create DynamoDB table
aws dynamodb create-table \
  --table-name maestrohwithit-backend-state-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-2
```

- [ ] S3 bucket created
- [ ] S3 versioning enabled
- [ ] DynamoDB table created
- [ ] State locks for staging created (`maestrohwithit-staging-state-locks`)
- [ ] State locks for production created (`maestrohwithit-prod-state-locks`)

### SSH Keys

```bash
# Generate keys
ssh-keygen -t rsa -b 4096 -f ~/.ssh/maestrohwithit-dev-key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/maestrohwithit-staging-key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/maestrohwithit-prod-key

# Import to AWS
aws ec2 import-key-pair --key-name maestrohwithit-dev-key \
  --public-key-material fileb://~/.ssh/maestrohwithit-dev-key.pub

aws ec2 import-key-pair --key-name maestrohwithit-staging-key \
  --public-key-material fileb://~/.ssh/maestrohwithit-staging-key.pub

aws ec2 import-key-pair --key-name maestrohwithit-prod-key \
  --public-key-material fileb://~/.ssh/maestrohwithit-prod-key.pub
```

- [ ] Dev SSH key created and imported
- [ ] Staging SSH key created and imported
- [ ] Production SSH key created and imported

### GitHub Repository

- [ ] Repository forked/cloned
- [ ] Pre-commit hooks installed (`pre-commit install`)
- [ ] Pre-commit hooks tested (`pre-commit run --all-files`)

### GitHub Secrets

Navigate to: Repository → Settings → Secrets and variables → Actions

Add the following secrets:

- [ ] `AWS_ACCESS_KEY_ID` (for dev/staging)
- [ ] `AWS_SECRET_ACCESS_KEY` (for dev/staging)
- [ ] `AWS_ACCESS_KEY_ID_PROD` (for production)
- [ ] `AWS_SECRET_ACCESS_KEY_PROD` (for production)

### Configuration Files

Update `environments/dev/terraform.tfvars`:

- [ ] Latest AMI ID for your region
- [ ] Correct SSH key name (`maestrohwithit-dev-key`)
- [ ] Your AWS region
- [ ] Owner and cost center details

Verify the backend configuration in `environments/dev/main.tf`:

- [ ] S3 bucket name matches
- [ ] DynamoDB table name matches
- [ ] Region is correct

---

## 🚀 Development Deployment

### Initialize Terraform

```bash
cd environments/dev
terraform init
```

**Verify:**
- [ ] No errors during init
- [ ] Backend configured successfully
- [ ] Provider plugins downloaded

### Deploy VPC First

```bash
terraform plan -target=module.vpc -var-file=terraform.tfvars
terraform apply -target=module.vpc -var-file=terraform.tfvars
```

**Capture outputs:**
- [ ] VPC ID: ________________
- [ ] Public Subnet 1: ________________
- [ ] Public Subnet 2: ________________
- [ ] Public Subnet 3: ________________
- [ ] Private Subnet 1: ________________
- [ ] Private Subnet 2: ________________
- [ ] Private Subnet 3: ________________

### Update Configuration

Update `terraform.tfvars` with actual VPC ID:

```bash
# Replace vpc-placeholder with actual VPC ID
sed -i '' 's/vpc-placeholder/<your-vpc-id>/' terraform.tfvars
```

- [ ] VPC ID updated in terraform.tfvars

### Deploy Security Groups

```bash
terraform plan -target=module.security_group -var-file=terraform.tfvars
terraform apply -target=module.security_group -var-file=terraform.tfvars
```

**Capture output:**
- [ ] Security Group ID: ________________

### Deploy EC2 Instances

Update `terraform.tfvars` with:
- [ ] First public subnet ID in `subnet_ids`
- [ ] Security group ID in `security_group_ids`

```bash
terraform plan -target=module.ec2_instances -var-file=terraform.tfvars
terraform apply -target=module.ec2_instances -var-file=terraform.tfvars
```

**Capture output:**
- [ ] EC2 Instance ID: ________________
- [ ] EC2 Public IP: ________________

### Deploy Complete Stack

```bash
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

- [ ] All resources deployed successfully
- [ ] No errors in output
- [ ] Outputs displayed correctly

### Verify Deployment

```bash
# Check EC2
aws ec2 describe-instances --filters "Name=tag:Environment,Values=dev"

# Check security groups
aws ec2 describe-security-groups --filters "Name=tag:Environment,Values=dev"

# Test SSH (if applicable)
ssh -i ~/.ssh/maestrohwithit-dev-key ec2-user@<EC2_PUBLIC_IP>
```

- [ ] EC2 instances running
- [ ] Security groups configured
- [ ] SSH access working (if needed)
- [ ] All tags present and correct

---

## 📊 Post-Deployment

### Install Monitoring

```bash
# Create CloudWatch dashboard
aws cloudwatch put-dashboard \
  --dashboard-name maestrohwithitDevelopment \
  --dashboard-body file://../../dashboards/production.json
```

- [ ] CloudWatch dashboard created
- [ ] Metrics visible

### Configure Alerts

```bash
# Create SNS topic
aws sns create-topic --name dev-maestrohwithit-alarms

# Subscribe email
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-2:<account-id>:dev-maestrohwithit-alarms \
  --protocol email \
  --notification-endpoint your-email@example.com
```

- [ ] SNS topic created
- [ ] Email subscription confirmed

### Test Backups

If you deployed the backup module:

```bash
# Tag a resource for backup
aws ec2 create-tags \
  --resources <instance-id> \
  --tags Key=Backup,Value=true

# Check backup plan
aws backup list-backup-plans
```

- [ ] Backup plan exists
- [ ] Resources tagged correctly

### Security Audit

```bash
# Run security scan
./scripts/security-audit.sh

# Check for issues
tfsec .
checkov -d . --framework terraform
```

- [ ] No critical security issues
- [ ] All checks passed

### Cost Monitoring

```bash
# Run cost check
./scripts/cost-monitor.sh dev
```

- [ ] Cost tracking working
- [ ] Within budget expectations

### Documentation

- [ ] Architecture diagram reviewed
- [ ] Team notified of deployment
- [ ] Runbooks accessible
- [ ] Secrets documented in password manager

---

## 🎯 Staging Deployment (Week 2-3)

Repeat similar steps for staging environment:

- [ ] `environments/staging/terraform.tfvars` configured
- [ ] GitHub Actions workflow tested
- [ ] Staging deployed successfully
- [ ] Application tested in staging
- [ ] Load testing completed

---

## 🚀 Production Deployment (Week 4)

### Pre-Production

- [ ] All tests passed in staging
- [ ] Security audit completed
- [ ] Disaster recovery plan reviewed
- [ ] Team training completed
- [ ] Rollback plan documented

### Production Checklist

- [ ] `environments/prod/terraform.tfvars` reviewed
- [ ] Production AWS account configured (if separate)
- [ ] GitHub environment protection rules set
- [ ] Manual approval workflow tested
- [ ] Monitoring dashboards ready
- [ ] Alert emails configured
- [ ] On-call rotation established

### Go Live

- [ ] Production infrastructure deployed
- [ ] DNS configured
- [ ] SSL certificates issued
- [ ] Application deployed
- [ ] Health checks passing
- [ ] Monitoring active
- [ ] Backups configured and tested

### Post-Launch

- [ ] Monitor for 24 hours
- [ ] Verify backups ran
- [ ] Check cost metrics
- [ ] Update documentation
- [ ] Team retrospective

---

## ✅ Validation

Run full validation:

```bash
# Format check
terraform fmt -check -recursive

# Security scan
./scripts/security-audit.sh

# Backup check
./scripts/check-backups.sh

# Cost report
./scripts/cost-monitor.sh
```

All checks passed:
- [ ] ✓ Format check
- [ ] ✓ Security scan
- [ ] ✓ Backup verification
- [ ] ✓ Cost tracking

---

## 📞 Support

If you encounter issues:

1. Check [Troubleshooting Guide](../docs/QUICK_REFERENCE.md#troubleshooting)
2. Review [Usage Guide](../docs/USAGE_GUIDE.md)
3. Contact DevOps team: devops@maestrohwithit.com
4. Slack: #infrastructure channel

---

**Deployment Date:** _______________  
**Deployed By:** _______________  
**Environment:** _______________  
**Status:** ⬜ In Progress  ⬜ Complete  ⬜ Issues

**Notes:**
_______________________________________________________
_______________________________________________________
_______________________________________________________
