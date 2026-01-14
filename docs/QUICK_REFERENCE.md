# maestrohwithit Infrastructure - Quick Reference

Essential commands and workflows for daily operations.

## 🚀 Quick Commands

### Deployment

```bash
# Development
cd environments/dev && terraform apply -var-file=terraform.tfvars

# Staging (via script)
./scripts/deploy.sh staging apply

# Production (manual approval required)
# Use GitHub Actions workflow
```

### Verification

```bash
# Check infrastructure state
terraform show

# View outputs
terraform output

# List all resources
terraform state list
```

### Monitoring

```bash
# Cost report
./scripts/cost-monitor.sh

# Backup status
./scripts/check-backups.sh

# Security audit
./scripts/security-audit.sh
```

## 📁 Directory Structure

```
maestrohwithit-infra/
├── environments/          # Environment configs
│   ├── dev/              # Development
│   ├── staging/          # Staging
│   └── prod/             # Production
├── modules/              # Reusable modules
├── scripts/              # Automation scripts
├── docs/                 # Documentation
└── .github/workflows/    # CI/CD pipelines
```

## 🌍 Environments

| Env | VPC CIDR | Deploy Method | Approval |
|-----|----------|---------------|----------|
| **dev** | 10.0.0.0/16 | Auto (push to main) | No |
| **staging** | 10.1.0.0/16 | Auto/Manual | No |
| **prod** | 10.2.0.0/16 | Manual only | Required |

## 🔑 AWS Secrets

### Create Secret

```bash
aws secretsmanager create-secret \
  --name /maestrohwithit/<env>/<service>/<key> \
  --secret-string '{"key":"value"}' \
  --region us-east-2
```

### Retrieve Secret

```bash
aws secretsmanager get-secret-value \
  --secret-id /maestrohwithit/prod/rds/master-password \
  --query SecretString \
  --output text
```

## 💾 Backups

### Manual RDS Snapshot

```bash
aws rds create-db-snapshot \
  --db-instance-identifier <env>-maestrohwithit-db \
  --db-snapshot-identifier manual-$(date +%Y%m%d-%H%M%S)
```

### Restore from Snapshot

```bash
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier <new-name> \
  --db-snapshot-identifier <snapshot-id>
```

## 🔍 Troubleshooting

### State Lock

```bash
terraform force-unlock <lock-id>
```

### Reset and Reinitialize

```bash
rm -rf .terraform
terraform init -reconfigure
```

### View AWS Credentials

```bash
aws sts get-caller-identity
```

### Check Resource Status

```bash
# EC2
aws ec2 describe-instances --filters "Name=tag:Environment,Values=prod"

# RDS
aws rds describe-db-instances --query "DBInstances[?DBInstanceIdentifier=='prod-maestrohwithit-db']"

# EKS
aws eks describe-cluster --name prod-maestrohwithit-cluster
```

## 📊 CloudWatch

### View Logs

```bash
# VPC Flow Logs
aws logs tail /aws/vpc/<env>-maestrohwithit-flow-logs --follow

# Application Logs
kubectl logs -f deployment/maestrohwithit-api -n production
```

### Create Alarm

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name high-cpu \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --period 300 \
  --statistic Average \
  --threshold 80
```

## 🐳 Kubernetes (EKS)

### Connect to Cluster

```bash
aws eks update-kubeconfig \
  --name <env>-maestrohwithit-cluster \
  --region us-east-2
```

### Common Commands

```bash
# View pods
kubectl get pods -n production

# View logs
kubectl logs -f <pod-name> -n production

# Scale deployment
kubectl scale deployment maestrohwithit-api --replicas=5 -n production

# Port forward
kubectl port-forward svc/maestrohwithit-api-service 8080:80 -n production
```

## 🔐 Security

### Scan for Vulnerabilities

```bash
tfsec .
checkov -d . --framework terraform
```

### Check S3 Bucket Public Access

```bash
aws s3api get-bucket-public-access-block --bucket <bucket-name>
```

### Enable MFA on IAM User

```bash
aws iam enable-mfa-device \
  --user-name <username> \
  --serial-number <mfa-device-arn> \
  --authentication-code1 <code1> \
  --authentication-code2 <code2>
```

## 💰 Cost Optimization

### Stop Dev Instances (After Hours)

```bash
# Stop all dev EC2 instances
aws ec2 stop-instances \
  --instance-ids $(aws ec2 describe-instances \
    --filters "Name=tag:Environment,Values=dev" \
    --query "Reservations[].Instances[].InstanceId" \
    --output text)
```

### Start Dev Instances (Morning)

```bash
aws ec2 start-instances \
  --instance-ids $(aws ec2 describe-instances \
    --filters "Name=tag:Environment,Values=dev" \
    --query "Reservations[].Instances[].InstanceId" \
    --output text)
```

### Clean Up Old Snapshots

```bash
# List snapshots older than 90 days
aws ec2 describe-snapshots \
  --owner-ids self \
  --query "Snapshots[?StartTime<\`$(date -d '90 days ago' -u +%Y-%m-%d)\`].[SnapshotId,StartTime]"
```

## 📈 Scaling

### EKS Auto Scaling

```bash
# Scale node group
aws eks update-nodegroup-config \
  --cluster-name prod-maestrohwithit-cluster \
  --nodegroup-name prod-nodes \
  --scaling-config minSize=2,maxSize=10,desiredSize=3
```

### RDS Scale Up

```bash
aws rds modify-db-instance \
  --db-instance-identifier prod-maestrohwithit-db \
  --db-instance-class db.t3.medium \
  --apply-immediately
```

## 🆘 Emergency Procedures

### RDS Failure

```bash
# 1. List snapshots
aws rds describe-db-snapshots --db-instance-identifier prod-maestrohwithit-db

# 2. Restore latest
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier prod-maestrohwithit-db-restored \
  --db-snapshot-identifier <latest-snapshot>
```

### EC2 Instance Unresponsive

```bash
# 1. Stop instance
aws ec2 stop-instances --instance-ids <instance-id>

# 2. Start instance
aws ec2 start-instances --instance-ids <instance-id>

# 3. If still failing, launch from AMI
aws ec2 run-instances --image-id <ami-id> ...
```

### Complete Region Failure

See [Disaster Recovery Runbook](./docs/DISASTER_RECOVERY.md)

## 📚 Documentation

- **[Usage Guide](./docs/USAGE_GUIDE.md)** - Complete application lifecycle
- **[Environments](./docs/ENVIRONMENTS.md)** - Environment management
- **[Secrets](./docs/SECRETS_MANAGEMENT.md)** - Secret management
- **[DR Runbook](./docs/DISASTER_RECOVERY.md)** - Disaster recovery
- **[Scripts README](./scripts/README.md)** - Automation scripts

## 🔗 Useful Links

- [AWS Console](https://console.aws.amazon.com/)
- [Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub Actions](https://github.com/maestrohwithit-USA/maestrohwithit-infra/actions)
- [Cost Explorer](https://console.aws.amazon.com/cost-management)
- [CloudWatch Dashboards](https://console.aws.amazon.com/cloudwatch)

## 📞 Support Contacts

- **DevOps Team:** devops@maestrohwithit.com
- **On-Call:** PagerDuty
- **Slack:** #infrastructure channel
- **AWS Support:** Premium Support

---

**Last Updated:** 2024-01-20  
**Maintained By:** DevOps Team
