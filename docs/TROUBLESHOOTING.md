# Troubleshooting Playbook

Quick solutions to common infrastructure issues.

## 🔍 Quick Diagnostics

### Health Check Script

```bash
#!/bin/bash
# Quick system health check

echo "=== Terraform Health ==="
terraform version
terraform validate

echo "=== AWS Connectivity ==="
aws sts get-caller-identity

echo "=== Resource Status ==="
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' --output table

aws rds describe-db-instances --query 'DBInstances[].[DBInstanceIdentifier,DBInstanceStatus]' --output table

echo "=== Recent Errors ==="
grep -i error terraform.log | tail -5
```

---

## 🚨 Common Issues

### 1. Terraform State Lock

**Symptom:**
```
Error: Error acquiring the state lock
Lock Info:
  ID: xxxxx-xxxx-xxxx
```

**Cause:** Previous terraform operation didn't complete cleanly

**Solution:**

```bash
# Option 1: Wait for lock to release (if operation is running)
# Check DynamoDB for active locks
aws dynamodb scan --table-name maestrohwithit-backend-state-locks

# Option 2: Force unlock (use with caution!)
terraform force-unlock <lock-id>

# Option 3: Check who has the lock
aws dynamodb get-item \
  --table-name maestrohwithit-backend-state-locks \
  --key '{"LockID":{"S":"maestrohwithit-backend/terraform.tfstate-md5"}}'
```

**Prevention:**
- Always let terraform operations complete
- Use `-lock=false` for read-only operations
- Set up timeout alerts for long-running operations

---

### 2. AWS Credentials Not Found

**Symptom:**
```
Error: No valid credential sources found
```

**Diagnosis:**
```bash
# Check current credentials
aws sts get-caller-identity

# Check configuration
aws configure list

# Check environment variables
env | grep AWS
```

**Solution:**

```bash
# Re-configure AWS CLI
aws configure

# Or set environment variables
export AWS_ACCESS_KEY_ID="your_key"
export AWS_SECRET_ACCESS_KEY="your_secret"
export AWS_DEFAULT_REGION="us-east-2"

# Or use AWS profiles
export AWS_PROFILE=maestrohwithit-prod
```

---

### 3. VPC CIDR Conflicts

**Symptom:**
```
Error: invalid CIDR address: 10.0.0.0/16 overlaps with 10.0.0.0/8
```

**Diagnosis:**
```bash
# List all VPCs and their CIDRs
aws ec2 describe-vpcs --query 'Vpcs[].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' --output table
```

**Solution:**
- Use different CIDR blocks for each environment:
  - Dev: 10.0.0.0/16
  - Staging: 10.1.0.0/16
  - Prod: 10.2.0.0/16
- Update `terraform.tfvars` with non-overlapping ranges

---

### 4. EC2 Instance Not Accessible

**Symptom:**
- SSH connection refused
- Instance shows running but unreachable

**Diagnosis:**
```bash
# Check instance status
aws ec2 describe-instance-status --instance-ids <instance-id>

# Check security group rules
aws ec2 describe-security-groups --group-ids <sg-id>

# Check network ACLs
aws ec2 describe-network-acls --filters "Name=vpc-id,Values=<vpc-id>"

# Test connectivity
ping <public-ip>
telnet <public-ip> 22
```

**Common Causes & Solutions:**

| Cause | Solution |
|-------|----------|
| Security group blocks SSH | Add rule: TCP/22 from your IP |
| Wrong SSH key | Use correct key: `-i ~/.ssh/maestrohwithit-<env>-key.pem` |
| Public IP not assigned | Enable auto-assign public IP or attach EIP |
| Instance in private subnet | Use bastion host or VPN |
| Network ACL blocks traffic | Review NACL rules |

**Solution Example:**
```bash
# Add SSH access to security group
aws ec2 authorize-security-group-ingress \
  --group-id <sg-id> \
  --protocol tcp \
  --port 22 \
  --cidr $(curl -s ifconfig.me)/32
```

---

### 5. RDS Connection Timeout

**Symptom:**
```
ERROR: could not connect to server: Connection timed out
```

**Diagnosis:**
```bash
# Check RDS status
aws rds describe-db-instances \
  --db-instance-identifier <db-id> \
  --query 'DBInstances[0].[DBInstanceStatus,Endpoint.Address,Endpoint.Port]'

# Check security group
aws rds describe-db-instances \
  --db-instance-identifier <db-id> \
  --query 'DBInstances[0].VpcSecurityGroups[].VpcSecurityGroupId'

# Test connectivity
telnet <rds-endpoint> 5432
```

**Common Solutions:**

```bash
# 1. Check security group allows your IP
aws ec2 authorize-security-group-ingress \
  --group-id <rds-sg-id> \
  --protocol tcp \
  --port 5432 \
  --cidr $(curl -s ifconfig.me)/32

# 2. Ensure RDS is in correct subnet
# RDS should be in PRIVATE subnets, accessible from app subnets

# 3. Check database is available
aws rds describe-db-instances \
  --db-instance-identifier <db-id> \
  --query 'DBInstances[0].DBInstanceStatus'
# Should return: "available"
```

---

### 6. EKS Cluster Connection Issues

**Symptom:**
```
error: You must be logged in to the server (Unauthorized)
```

**Diagnosis:**
```bash
# Check cluster status
aws eks describe-cluster --name <cluster-name>

# Check kubeconfig
kubectl config view
kubectl config current-context

# Check AWS auth
aws sts get-caller-identity
```

**Solution:**

```bash
# Update kubeconfig
aws eks update-kubeconfig \
  --name <cluster-name> \
  --region us-east-2

# Verify connection
kubectl get nodes
kubectl get pods --all-namespaces

# If still failing, check IAM permissions
aws eks describe-cluster \
  --name <cluster-name> \
  --query 'cluster.resourcesVpcConfig.endpointPublicAccess'
```

---

### 7. Terraform Apply Fails Mid-Execution

**Symptom:**
- Apply stops partway through
- Some resources created, some not
- State may be corrupted

**Diagnosis:**
```bash
# Check what's in state
terraform state list

# Compare with AWS reality
aws ec2 describe-instances --filters "Name=tag:Environment,Values=dev"

# Check for resource drift
terraform plan -refresh-only
```

**Solution:**

```bash
# Option 1: Import missing resources
terraform import module.ec2.aws_instance.main i-xxxxx

# Option 2: Remove from state and recreate
terraform state rm module.problematic_resource
terraform apply -target=module.problematic_resource

# Option 3: Refresh and reapply
terraform refresh
terraform plan
terraform apply

# Option 4: Nuclear option (use with caution!)
# Back up state first
aws s3 cp s3://maestrohwithit-infra-bucket/maestrohwithit-backend/terraform.tfstate ./backup.tfstate
# Then destroy and recreate specific resources
```

---

### 8. Cost Spike Detected

**Symptom:**
- Unexpected AWS bill
- Cost Explorer shows spike

**Diagnosis:**
```bash
# Check current month costs
./scripts/cost-monitor.sh

# Identify expensive resources
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity DAILY \
  --metrics UnblendedCost \
  --group-by Type=SERVICE

# Find untagged resources (cost leaks)
aws resourcegroupstaggingapi get-resources \
  --resource-type-filters ec2:instance \
  --query  'ResourceTagMappingList[?Tags==`[]`]'
```

**Common Causes:**

| Cause | Solution |
|-------|----------|
| Forgotten dev resources running 24/7 | Use cost-optimize.sh to stop after hours |
| Unattached EBS volumes | Delete unused volumes |
| Old snapshots | Clean up snapshots >90 days |
| Unnecessarily large instances | Downsize to appropriate size |
| Data transfer costs | Use VPC endpoints, CloudFront |

**Immediate Actions:**
```bash
# Stop all dev/staging EC2
./scripts/cost-optimize.sh stop dev
./scripts/cost-optimize.sh stop staging

# Find and delete unattached volumes
aws ec2 describe-volumes \
  --filters Name=status,Values=available \
  --query 'Volumes[].VolumeId' --output text | \
  xargs -n1 aws ec2 delete-volume --volume-id

# List old snapshots
aws ec2 describe-snapshots --owner-ids self \
  --query "Snapshots[?StartTime<'2023-10-01'].[SnapshotId,StartTime]" \
  --output table
```

---

### 9. Backup Job Failures

**Symptom:**
```
Backup job failed: Resource not found
```

**Diagnosis:**
```bash
# Check recent backup jobs
./scripts/check-backups.sh

# Check failed jobs details
aws backup list-backup-jobs \
  --by-state FAILED \
  --max-results 10

# Verify resources are tagged
aws ec2 describe-instances \
  --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Backup`].Value|[0]]'
```

**Solution:**

```bash
# Ensure resources are tagged
aws ec2 create-tags \
  --resources <instance-id> \
  --tags Key=Backup,Value=true Key=Environment,Value=prod

# Check backup plan exists
aws backup list-backup-plans

# Check IAM role has permissions
aws iam get-role --role-name AWSBackupDefaultServiceRole

# Manually trigger backup
aws backup start-backup-job \
  --backup-vault-name prod-maestrohwithit-backup-vault \
  --resource-arn arn:aws:ec2:us-east-2:xxx:instance/i-xxx \
  --iam-role-arn arn:aws:iam::xxx:role/service-role/AWSBackupDefaultServiceRole
```

---

### 10. High RDS CPU Usage

**Symptom:**
- RDS CPU constantly > 80%
- Application slow
- Database timeouts

**Diagnosis:**
```bash
# Check current CPU
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value=prod-maestrohwithit-db \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average

# Check active connections
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name DatabaseConnections \
  --dimensions Name=DBInstanceIdentifier,Value=prod-maestrohwithit-db \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average

# Connect and check queries (PostgreSQL)
psql -h <rds-endpoint> -U admin -d maestrohwithit_prod
SELECT * FROM pg_stat_activity WHERE state = 'active';
```

**Solutions:**

**Immediate (Emergency):**
```sql
-- Kill long-running queries
SELECT pg_terminate_backend(pid) 
FROM pg_stat_activity 
WHERE state = 'active' 
AND query_start < NOW() - INTERVAL '5 minutes';
```

**Short-term:**
```bash
# Scale up instance
aws rds modify-db-instance \
  --db-instance-identifier prod-maestrohwithit-db \
  --db-instance-class db.t3.large \
  --apply-immediately

# Add read replicas for read-heavy workloads
aws rds create-db-instance-read-replica \
  --db-instance-identifier prod-maestrohwithit-db-replica \
  --source-db-instance-identifier prod-maestrohwithit-db
```

**Long-term:**
- Add database indexes
- Implement query caching (Redis)
- Optimize slow queries
- Enable connection pooling
- Consider Aurora for auto-scaling

---

## 🔧 Debugging Tools

### Enable Terraform Debug Logging

```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform.log
terraform apply

# View logs
tail -f terraform.log
```

### AWS CloudTrail for Audit

```bash
# Recent API calls
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=RunInstances \
  --max-results 10

# Who did what
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=Username,AttributeValue=your-user
```

### VPC Flow Logs Analysis

```bash
# View recent flow logs
aws logs tail /aws/vpc/prod-maestrohwithit-flow-logs --follow

# Find rejected connections
aws logs filter-log-events \
  --log-group-name /aws/vpc/prod-maestrohwithit-flow-logs \
  --filter-pattern '[version, account, eni, source, destination, srcport, destport, protocol, packets, bytes, windowstart, windowend, action="REJECT", flowlogstatus]' \
  --max-items 20
```

---

## 📞 Escalation Path

### Level 1: Self-Service (0-30 minutes)
1. Check this troubleshooting guide
2. Review Quick Reference
3. Search error message in docs
4. Check GitHub Issues

### Level 2: Team Support (30-60 minutes)
1. Post in Slack #infrastructure
2. Include:
   - Error message
   - Steps to reproduce
   - Environment
   - Recent changes

### Level 3: On-Call (Critical Issues)
1. Page on-call engineer via PagerDuty
2. For:
   - Production outage
   - Security breach
   - Data loss
   - Complete service unavailable

### Level 4: AWS Support (Rare)
1. Open AWS Support ticket
2. For:
   - AWS service issues
   - Quota increases (urgent)
   - Account-level problems

---

## 📝 Post-Incident

After resolving an issue:

1. **Document the fix** in this playbook
2. **Update runbooks** if process changed
3. **Create GitHub issue** for permanent fix
4. **Share learnings** in team meeting
5. **Update monitoring** to catch earlier next time

---

**Last Updated:** 2024-01-20  
**Maintained By:** DevOps Team  
**Contributions Welcome!**
