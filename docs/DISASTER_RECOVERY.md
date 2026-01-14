# Disaster Recovery Runbook

## Overview

This document outlines the disaster recovery (DR) procedures for the maestrohwithit infrastructure. It defines Recovery Time Objectives (RTO), Recovery Point Objectives (RPO), and step-by-step procedures for recovering from various failure scenarios.

## DR Objectives

### Production Environment

| Component | RTO | RPO | Backup Frequency |
|-----------|-----|-----|------------------|
| RDS Database | 1 hour | 5 minutes | Continuous (automated snapshots) |
| EC2 Instances | 30 minutes | N/A | AMI snapshots weekly |
| EBS Volumes | 30 minutes | 24 hours | Daily snapshots |
| S3 Data | 15 minutes | N/A | Versioning enabled |
| EKS Cluster | 2 hours | N/A | Configuration in Git |

### Staging Environment

| Component | RTO | RPO | Backup Frequency |
|-----------|-----|-----|------------------|
| RDS Database | 4 hours | 24 hours | Daily snapshots |
| EC2 Instances | 2 hours | N/A | Weekly AMI snapshots |
| S3 Data | 1 hour | N/A | Versioning enabled |

## Backup Strategy

### Automated Backups (AWS Backup)

All resources tagged with `Backup = "true"` are automatically backed up according to the AWS Backup plan:

```bash
# Production: Daily backups, 30-day retention
# Staging: Daily backups, 7-day retention
# Dev: No automated backups (recreate from code)
```

### Manual Backup Procedures

#### 1. RDS Database Manual Snapshot

```bash
# Create manual snapshot
aws rds create-db-snapshot \
  --db-instance-identifier <environment>-maestrohwithit-db \
  --db-snapshot-identifier manual-snapshot-$(date +%Y%m%d-%H%M%S) \
  --region us-east-2

# Verify snapshot status
aws rds describe-db-snapshots \
  --db-snapshot-identifier <snapshot-id> \
  --region us-east-2
```

#### 2. EC2 AMI Creation

```bash
# Create AMI from running instance
aws ec2 create-image \
  --instance-id <instance-id> \
  --name "manual-ami-$(date +%Y%m%d-%H%M%S)" \
  --description "Manual backup before maintenance" \
  --region us-east-2
```

#### 3. EBS Snapshot

```bash
# Create EBS volume snapshot
aws ec2 create-snapshot \
  --volume-id <volume-id> \
  --description "manual-backup-$(date +%Y%m%d-%H%M%S)" \
  --region us-east-2
```

## Recovery Procedures

### Scenario 1: RDS Database Failure

**Symptoms:** Database connection errors, application cannot connect to RDS.

**Recovery Steps:**

1. **Identify the failure:**
   ```bash
   aws rds describe-db-instances \
     --db-instance-identifier prod-maestrohwithit-db \
     --region us-east-2
   ```

2. **Check recent automated snapshots:**
   ```bash
   aws rds describe-db-snapshots \
     --db-instance-identifier prod-maestrohwithit-db \
     --region us-east-2 \
     --query 'DBSnapshots[0]'
   ```

3. **Restore from latest snapshot:**
   ```bash
   aws rds restore-db-instance-from-db-snapshot \
     --db-instance-identifier prod-maestrohwithit-db-restored \
     --db-snapshot-identifier <snapshot-id> \
     --db-instance-class db.t3.medium \
     --region us-east-2
   ```

4. **Update application configuration:**
   - Update RDS endpoint in application configuration
   - Or, rename restored instance to match original

5. **Verify data integrity:**
   - Connect to restored database
   - Run validation queries
   - Check application functionality

**Estimated Time:** 30-60 minutes

### Scenario 2: EC2 Instance Failure

**Symptoms:** Instance unresponsive, status checks failing.

**Recovery Steps:**

1. **Check instance status:**
   ```bash
   aws ec2 describe-instance-status \
     --instance-ids <instance-id> \
     --region us-east-2
   ```

2. **Attempt instance recovery:**
   ```bash
   # Try stopping and starting (NOT rebooting)
   aws ec2 stop-instances --instance-ids <instance-id>
   aws ec2 start-instances --instance-ids <instance-id>
   ```

3. **If recovery fails, launch from AMI:**
   ```bash
   # Find latest AMI
   aws ec2 describe-images \
     --owners self \
     --filters "Name=tag:Environment,Values=prod" \
     --query 'Images | sort_by(@, &CreationDate) | [-1]'

   # Launch new instance from AMI
   aws ec2 run-instances \
     --image-id <ami-id> \
     --instance-type t3.medium \
     --key-name maestrohwithit-prod-key \
     --subnet-id <subnet-id> \
     --security-group-ids <sg-id> \
     --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=prod-maestrohwithit-instance-recovered}]'
   ```

4. **Restore EBS volumes if needed:**
   ```bash
   # List recent snapshots
   aws ec2 describe-snapshots \
     --owner-ids self \
     --filters "Name=tag:Environment,Values=prod"

   # Create volume from snapshot
   aws ec2 create-volume \
     --snapshot-id <snapshot-id> \
     --availability-zone us-east-2a \
     --volume-type gp3

   # Attach volume to instance
   aws ec2 attach-volume \
     --volume-id <volume-id> \
     --instance-id <instance-id> \
     --device /dev/sdf
   ```

**Estimated Time:** 20-40 minutes

### Scenario 3: Complete Region Failure

**Symptoms:** All services in us-east-2 unavailable.

**Recovery Steps:**

1. **Activate DR region (us-west-2):**
   - This requires pre-configured cross-region replication (not currently implemented)
   - **TODO:** Implement cross-region DR setup

2. **Deploy infrastructure in new region:**
   ```bash
   cd environments/prod
   
   # Update region in backend config
   # Update terraform.tfvars with new region
   
   terraform init
   terraform plan -var-file=terraform.tfvars
   terraform apply -var-file=terraform.tfvars
   ```

3. **Restore RDS from cross-region snapshot:**
   ```bash
   # If cross-region snapshots exist
   aws rds restore-db-instance-from-db-snapshot \
     --db-instance-identifier prod-maestrohwithit-db \
     --db-snapshot-identifier <snapshot-id> \
     --region us-west-2
   ```

4. **Update DNS (Route53):**
   ```bash
   # Update Route53 records to point to new region
   aws route53 change-resource-record-sets \
     --hosted-zone-id <zone-id> \
     --change-batch file://dns-update.json
   ```

**Estimated Time:** 3-6 hours (depending on data size)

### Scenario 4: Accidental Data Deletion (S3)

**Symptoms:** Important files missing from S3 buckets.

**Recovery Steps:**

1. **Check S3 versioning:**
   ```bash
   aws s3api list-object-versions \
     --bucket prod-maestrohwithit-backups-<suffix> \
     --prefix <path-to-deleted-file>
   ```

2. **Restore previous version:**
   ```bash
   aws s3api copy-object \
     --bucket prod-maestrohwithit-backups-<suffix> \
     --copy-source prod-maestrohwithit-backups-<suffix>/<key>?versionId=<version-id> \
     --key <key>
   ```

**Estimated Time:** 5-15 minutes

### Scenario 5: EKS Cluster Failure

**Symptoms:** EKS cluster unavailable, pods not running.

**Recovery Steps:**

1. **Check cluster status:**
   ```bash
   aws eks describe-cluster \
     --name prod-maestrohwithit-cluster \
     --region us-east-2
   ```

2. **Recreate cluster from Terraform:**
   ```bash
   cd environments/prod
   
   # Target only EKS resources
   terraform plan -target=module.eks
   terraform apply -target=module.eks -auto-approve
   ```

3. **Redeploy applications:**
   ```bash
   # Update kubeconfig
   aws eks update-kubeconfig \
     --name prod-maestrohwithit-cluster \
     --region us-east-2

   # Redeploy from Git
   kubectl apply -f k8s/deployments/
   ```

**Estimated Time:** 1-2 hours

## Testing DR Procedures

### Quarterly DR Drills

1. **Test RDS Restore (Quarterly)**
   - Restore production database to staging environment
   - Verify data integrity
   - Document time taken

2. **Test EC2 Recovery (Bi-annually)**
   - Launch instance from AMI in staging
   - Verify configurations
   - Test application functionality

3. **Test Complete Stack Deployment (Annually)**
   - Deploy entire infrastructure to new AWS account
   - Restore data from backups
   - Full application testing

## Monitoring & Alerts

### CloudWatch Alarms

All critical alarms notify via SNS topic: `prod-maestrohwithit-alarms`

- RDS CPU > 80%
- RDS Storage < 10GB
- EC2 Status Check Failed
- ALB Unhealthy Targets > 0

### AWS Backup Monitoring

```bash
# Check backup job status
aws backup list-backup-jobs \
  --by-state COMPLETED \
  --max-results 10

# Check failed backups
aws backup list-backup-jobs \
  --by-state FAILED
```

## Contacts

| Role | Contact | Phone |
|------|---------|-------|
| DevOps Lead | devops@maestrohwithit.com | xxx-xxx-xxxx |
| AWS Support | AWS TAM | Premium Support |
| On-Call Engineer | PagerDuty | Automated |

## Post-Incident Review

After any DR event:

1. Document the incident timeline
2. Identify root cause
3. Update runbook based on lessons learned
4. Improve automation where possible
5. Update RTO/RPO if objectives weren't met

## Appendix

### Useful Commands

```bash
# List all backups
aws backup list-recovery-points-by-backup-vault \
  --backup-vault-name prod-maestrohwithit-backup-vault

# Check terraform state
terraform state list
terraform state show <resource>

# Export RDS data
mysqldump -h <endpoint> -u admin -p database_name > backup.sql

# Import RDS data
mysql -h <endpoint> -u admin -p database_name < backup.sql
```
