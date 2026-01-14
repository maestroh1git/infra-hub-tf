# maestrohwithit Infrastructure Scripts

Automation scripts to simplify common infrastructure operations.

## 📁 Available Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `deploy.sh` | Deploy infrastructure to any environment | `./scripts/deploy.sh <env> <action>` |
| `cost-monitor.sh` | Monitor AWS costs by environment | `./scripts/cost-monitor.sh [env]` |
| `check-backups.sh` | Verify backup status and recovery points | `./scripts/check-backups.sh [env]` |
| `security-audit.sh` | Run security checks on infrastructure | `./scripts/security-audit.sh` |

## 🚀 Quick Start

### 1. Deploy Infrastructure

```bash
# Deploy to development
./scripts/deploy.sh dev apply

# Deploy to staging ./scripts/deploy.sh staging apply

# Deploy to production (requires confirmation)
./scripts/deploy.sh prod apply
```

### 2. Monitor Costs

```bash
# View all environment costs
./scripts/cost-monitor.sh

# View specific environment
./scripts/cost-monitor.sh prod
```

### 3. Check Backups

```bash
# Check all backups
./scripts/check-backups.sh

# Check specific environment
./scripts/check-backups.sh prod
```

### 4. Run Security Audit

```bash
# Run full security scan
./scripts/security-audit.sh
```

## 📖 Detailed Usage

### deploy.sh

Automated deployment script with safety checks.

**Actions:**
- `init` - Initialize Terraform
- `plan` - Generate execution plan
- `apply` - Apply infrastructure changes
- `destroy` - Destroy infrastructure (with confirmation)
- `output` - Show infrastructure outputs
- `validate` - Validate configuration

**Examples:**

```bash
# Initialize new environment
./scripts/deploy.sh dev init

# Plan changes
./scripts/deploy.sh staging plan

# Apply with existing plan
./scripts/deploy.sh staging apply

# Destroy dev environment
./scripts/deploy.sh dev destroy

# View outputs
./scripts/deploy.sh prod output
```

**Features:**
- ✅ Pre-flight AWS credential checks
- ✅ Production confirmation prompts
- ✅ Colored output for better readability
- ✅ Automatic plan generation
- ✅ Environment validation

### cost-monitor.sh

Track AWS spending and identify cost optimization opportunities.

**Output:**
- Costs by environment (dev, staging, prod)
- Top services by cost
- Cost forecast for next month
- Savings recommendations

**Example:**

```bash
$ ./scripts/cost-monitor.sh

╔════════════════════════════════════════╗
║   maestrohwithit Infrastructure Cost Report    ║
╚════════════════════════════════════════╝

📊 Cost Period: 2024-01-01 to 2024-01-20

━━━ Costs by Environment ━━━
dev:         $58.32
staging:     $143.87
prod:        $487.21

━━━ Top Services by Cost ━━━
EC2              $245.60
RDS              $156.80
 S3               $42.30
EKS              $185.50

━━━ Cost Forecast ━━━
Estimated next month: $694.52
```

### check-backups.sh

Verify backup health and compliance.

**Checks:**
- AWS Backup vault status
- Recent backup jobs (last 24 hours)
- Failed backups
- RDS snapshots
- EC2 AMIs
- EBS snapshots

**Example:**

```bash
$ ./scripts/check-backups.sh prod

╔════════════════════════════════════════╗
║      Backup Status Report              ║
╚════════════════════════════════════════╝

━━━ Backup Vaults ━━━
prod-maestrohwithit-backup-vault    15

━━━ Recent Backup Jobs ━━━
✓ 12 successful backups in last 24 hours

━━━ RDS Snapshots ━━━
rds:prod-maestrohwithit-db-2024-01-20    2024-01-20T05:00:00    20GB
rds:prod-maestrohwithit-db-2024-01-19    2024-01-19T05:00:00    20GB
```

### security-audit.sh

Comprehensive security scanning.

**Checks:**
- tfsec security scan
- Checkov policy compliance
- Git secrets detection
- Public S3 buckets
- Unencrypted EBS volumes
- Overly permissive security groups
- IAM password policy
- Root account MFA

**Example:**

```bash
$ ./scripts/security-audit.sh

╔════════════════════════════════════════╗
║    Infrastructure Security Audit       ║
╚════════════════════════════════════════╝

━━━ Running tfsec Security Scan ━━━
✓ No critical issues found

━━━ AWS Security Checks ━━━
✓ No public S3 buckets found
✓ All EBS volumes are encrypted
✓ No security groups with open SSH/RDP
✓ IAM password policy configured
✓ Root account MFA enabled
```

## 🔧 Prerequisites

### Required Tools

```bash
# Core tools
terraform >= 1.6.6
aws-cli >= 2.x
jq

# Security tools (optional but recommended)
tfsec
checkov
git-secrets
```

### Installation

```bash
# macOS
brew install terraform awscli jq tfsec
pip install checkov
brew install git-secrets

# Linux
# Install terraform, awscli, jq using package manager
pip install checkov
```

### AWS Configuration

```bash
# Configure AWS credentials
aws configure

# Verify
aws sts get-caller-identity
```

## 🔒 Security Notes

- **Never commit** AWS credentials or secrets
- Scripts validate AWS credentials before execution
- Production deployments require manual confirmation
- All scripts use `-e` flag to exit on errors
- Sensitive operations require environment name confirmation

## 🐛 Troubleshooting

### Script Permission Denied

```bash
chmod +x scripts/*.sh
```

### AWS Credentials Not Found

```bash
aws configure
# Enter your Access Key, Secret Key, Region
```

### Terraform Init Fails

```bash
cd environments/dev
terraform init -upgrade
```

### Cost Report Returns "0"

Ensure resources are tagged with `Environment` tag:
```hcl
tags = {
  Environment = "prod"
  Application = "maestrohwithit"
}
```

## 📋 Best Practices

1. **Always run `plan` before `apply`**
   ```bash
   ./scripts/deploy.sh prod plan
   # Review the output
   ./scripts/deploy.sh prod apply
   ```

2. **Monitor costs weekly**
   ```bash
   ./scripts/cost-monitor.sh >> cost-reports/$(date +%Y-%m-%d).txt
   ```

3. **Verify backups after deployment**
   ```bash
   ./scripts/check-backups.sh prod
   ```

4. **Run security audits monthly**
   ```bash
   ./scripts/security-audit.sh > security-reports/$(date +%Y-%m-%d).txt
   ```

5. **Test disaster recovery procedures**
   ```bash
   # Quarterly DR drill
   ./scripts/check-backups.sh prod
   # Follow disaster recovery runbook
   ```

## 📚 Related Documentation

- [Disaster Recovery](../docs/DISASTER_RECOVERY.md)
- [Secrets Management](../docs/SECRETS_MANAGEMENT.md)
- [Environment Management](../docs/ENVIRONMENTS.md)
- [Usage Guide](../docs/USAGE_GUIDE.md)

## 🤝 Contributing

When adding new scripts:

1. Follow the naming convention: `action-noun.sh`
2. Include usage instructions in header comment
3. Use colored output for better UX
4. Add error handling (`set -e`)
5. Update this README
6. Make script executable: `chmod +x scripts/your-script.sh`

## 📝 Script Template

```bash
#!/bin/bash
#
# Script Name
# Description of what it does
#
# Usage: ./scripts/script-name.sh [arguments]
#

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Your code here
echo -e "${GREEN}✓ Success${NC}"
```

## 📞 Support

For issues with scripts:
- Check the troubleshooting section above
- Review script output for error messages
- Verify AWS credentials and permissions
- Consult main project documentation

---

**Happy automating!** 🚀
