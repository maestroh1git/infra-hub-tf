# Secrets Management Guide

## Overview

This guide explains how to manage secrets securely in the maestrohwithit infrastructure using AWS Secrets Manager, Parameter Store, and GitHub Secrets.

## Secrets Management Strategy

### AWS Secrets Manager

Use AWS Secrets Manager for:
- Database credentials (RDS passwords)
- API keys and tokens
- TLS/SSL certificates private keys
- Application secrets that rotate

### AWS Systems Manager Parameter Store

Use Parameter Store for:
- Configuration values
- Non-sensitive environment variables
- Feature flags

### GitHub Secrets

Use GitHub Secrets for:
- AWS credentials for CI/CD
- Terraform Cloud API tokens
- Deployment keys

## AWS Secrets Manager

###Creating Secrets

#### 1. RDS Database Password

```bash
# Create secret for RDS password
aws secretsmanager create-secret \
  --name /maestrohwithit/prod/rds/master-password \
  --description "Master password for production RDS instance" \
  --secret-string '{"username":"admin","password":"YourSecurePassword123!"}' \
  --region us-east-2 \
  --tags Key=Environment,Value=prod Key=Application,Value=maestrohwithit
```

#### 2. API Keys

```bash
# Create secret for third-party API key
aws secretsmanager create-secret \
  --name /maestrohwithit/prod/api/stripe-key \
  --description "Stripe API key for production" \
  --secret-string '{"api_key":"sk_live_xxxxxxxxxxxxx"}' \
  --region us-east-2
```

### Retrieving Secrets

#### From AWS CLI

```bash
# Get secret value
aws secretsmanager get-secret-value \
  --secret-id /maestrohwithit/prod/rds/master-password \
  --region us-east-2 \
  --query SecretString \
  --output text
```

#### From Terraform

```hcl
# Reference secret in Terraform
data "aws_secretsmanager_secret" "rds_password" {
  name = "/maestrohwithit/${var.environment}/rds/master-password"
}

data "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = data.aws_secretsmanager_secret.rds_password.id
}

# Use in RDS module
resource "aws_db_instance" "main" {
  # Option 1: Let AWS manage the password (RECOMMENDED)
  manage_master_user_password = true
  
  # Option 2: Use existing secret
  # password = jsondecode(data.aws_secretsmanager_secret_version.rds_password.secret_string)["password"]
}
```

#### From Application Code (Node.js)

```javascript
const AWS = require('aws-sdk');
const secretsManager = new AWS.SecretsManager({ region: 'us-east-2' });

async function getSecret(secretName) {
  try {
    const data = await secretsManager.getSecretValue({
      SecretId: secretName
    }).promise();
    
    return JSON.parse(data.SecretString);
  } catch (error) {
    console.error('Error retrieving secret:', error);
    throw error;
  }
}

// Usage
const dbCreds = await getSecret('/maestrohwithit/prod/rds/master-password');
console.log(dbCreds.username); // admin
console.log(dbCreds.password); // YourSecurePassword123!
```

### Secret Rotation

#### Enable Automatic Rotation for RDS

```bash
# Enable rotation using Lambda
aws secretsmanager rotate-secret \
  --secret-id /maestrohwithit/prod/rds/master-password \
  --rotation-lambda-arn arn:aws:lambda:us-east-2:123456789012:function:SecretsManagerRDSRotation \
  --rotation-rules AutomaticallyAfterDays=30
```

#### Terraform Configuration for Rotation

```hcl
resource "aws_secretsmanager_secret_rotation" "rds" {
  secret_id           = aws_secretsmanager_secret.rds_password.id
  rotation_lambda_arn = aws_lambda_function.rotate_secret.arn

  rotation_rules {
    automatically_after_days = 30
  }
}
```

### Updating Secrets

```bash
# Update secret value
aws secretsmanager update-secret \
  --secret-id /maestrohwithit/prod/api/stripe-key \
  --secret-string '{"api_key":"sk_live_newkeyxxxxxxxxx"}' \
  --region us-east-2
```

### Deleting Secrets

```bash
# Schedule deletion (7-30 days recovery window)
aws secretsmanager delete-secret \
  --secret-id /maestrohwithit/prod/api/old-service-key \
  --recovery-window-in-days 7 \
  --region us-east-2

# Restore deleted secret (within recovery window)
aws secretsmanager restore-secret \
  --secret-id /maestrohwithit/prod/api/old-service-key \
  --region us-east-2

# Force delete (immediate, no recovery)
aws secretsmanager delete-secret \
  --secret-id /maestrohwithit/prod/api/old-service-key \
  --force-delete-without-recovery \
  --region us-east-2
```

## AWS Systems Manager Parameter Store

### Creating Parameters

```bash
# Standard parameter (free tier)
aws ssm put-parameter \
  --name /maestrohwithit/prod/app/database-name \
  --value "maestrohwithit_production" \
  --type String \
  --tags Key=Environment,Value=prod \
  --region us-east-2

# Secure parameter (encrypted)
aws ssm put-parameter \
  --name /maestrohwithit/prod/app/jwt-secret \
  --value "super-secret-jwt-key" \
  --type SecureString \
  --key-id alias/aws/ssm \
  --tags Key=Environment,Value=prod \
  --region us-east-2
```

### Retrieving Parameters

```bash
# Get parameter
aws ssm get-parameter \
  --name /maestrohwithit/prod/app/database-name \
  --region us-east-2 \
  --query Parameter.Value \
  --output text

# Get decrypted secure parameter
aws ssm get-parameter \
  --name /maestrohwithit/prod/app/jwt-secret \
  --with-decryption \
  --region us-east-2
```

### Terraform Data Source

```hcl
data "aws_ssm_parameter" "database_name" {
  name = "/maestrohwithit/${var.environment}/app/database-name"
}

resource "aws_instance" "app" {
  # Use parameter value
  user_data = <<-EOF
    #!/bin/bash
    export DB_NAME="${data.aws_ssm_parameter.database_name.value}"
  EOF
}
```

## GitHub Secrets for CI/CD

### Setting Up GitHub Secrets

1. **Navigate to Repository Settings**
   - Go to: `Settings` → `Secrets and variables` → `Actions`

2. **Add Repository Secrets**

Required secrets for dev environment:
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

Required secrets for production:
```
AWS_ACCESS_KEY_ID_PROD
AWS_SECRET_ACCESS_KEY_PROD
```

### Using GitHub Secrets in Workflows

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-2
```

### Environment-Specific Secrets

Create GitHub environments (Settings → Environments):
- `dev`
- `staging`
- `production` (with required reviewers)

Then use environment-specific secrets:

```yaml
jobs:
  deploy-prod:
    environment: production
    steps:
      - name: Deploy
        env:
          API_KEY: ${{ secrets.STRIPE_API_KEY }}  # Environment-specific
```

## Secret Naming Conventions

### AWS Secrets Manager

Format: `/<application>/<environment>/<service>/<secret-name>`

Examples:
```
/maestrohwithit/prod/rds/master-password
/maestrohwithit/staging/api/stripe-key
/maestrohwithit/dev/cache/redis-password
```

### AWS Parameter Store

Format: `/<application>/<environment>/<category>/<parameter-name>`

Examples:
```
/maestrohwithit/prod/app/database-name
/maestrohwithit/staging/app/api-endpoint
/maestrohwithit/dev/feature/enable-debug-mode
```

## Security Best Practices

### 1. Never Commit Secrets to Git

```bash
# Check for secrets before committing
git secrets --scan

# Use .gitignore
echo "*.tfvars" >> .gitignore
echo "secrets.yaml" >> .gitignore
```

### 2. Use IAM Policies for Access Control

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "arn:aws:secretsmanager:us-east-2:*:secret:/maestrohwithit/prod/*"
    }
  ]
}
```

### 3. Enable Audit Logging

```bash
# Enable CloudTrail for Secrets Manager
aws cloudtrail create-trail \
  --name maestrohwithit-secrets-audit \
  --s3-bucket-name maestrohwithit-cloudtrail-logs

# Enable logging
aws cloudtrail start-logging \
  --name maestrohwithit-secrets-audit
```

### 4. Rotate Secrets Regularly

- Database passwords: Every 30 days
- API keys: Every 90 days
- Certificates: Before expiration

### 5. Use KMS for Encryption

```bash
# Create KMS key for secrets
aws kms create-key \
  --description "maestrohwithit secrets encryption key" \
  --tags TagKey=Application,TagValue=maestrohwithit

# Create alias
aws kms create-alias \
  --alias-name alias/maestrohwithit-secrets \
  --target-key-id <key-id>
```

## Emergency Procedures

### Lost/Compromised Secret

1. **Immediately rotate the secret:**
   ```bash
   aws secretsmanager rotate-secret \
     --secret-id /maestrohwithit/prod/api/compromised-key \
     --region us-east-2
   ```

2. **Update applications:**
   - Restart services that cache secrets
   - Verify new secret is being used

3. **Audit access logs:**
   ```bash
   aws cloudtrail lookup-events \
     --lookup-attributes AttributeKey=ResourceName,AttributeValue=/maestrohwithit/prod/api/compromised-key \
     --start-time $(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%S) \
     --end-time $(date -u +%Y-%m-%dT%H:%M:%S)
   ```

### RDS Auto-Generated Password Retrieval

When using `manage_master_user_password = true` in RDS:

```bash
# Find the secret ARN
aws rds describe-db-instances \
  --db-instance-identifier prod-maestrohwithit-db \
  --query 'DBInstances[0].MasterUserSecret.SecretArn' \
  --output text

# Get the password
aws secretsmanager get-secret-value \
  --secret-id <secret-arn> \
  --query SecretString \
  --output text | jq -r '.password'
```

## Monitoring & Alerts

### CloudWatch Alarms for Secrets Access

```bash
# Create metric filter for failed secret access
aws logs put-metric-filter \
  --log-group-name /aws/secretsmanager \
  --filter-name FailedSecretAccess \
  --filter-pattern "[time, request_id, event_type = GetSecretValue, status_code = 4*]" \
  --metric-transformations \
    metricName=FailedSecretAccess,metricNamespace=maestrohwithit/Security,metricValue=1

# Create alarm
aws cloudwatch put-metric-alarm \
  --alarm-name maestrohwithit-failed-secret-access \
  --alarm-description "Alert on failed secret access attempts" \
  --metric-name FailedSecretAccess \
  --namespace maestrohwithit/Security \
  --statistic Sum \
  --period 300 \
  --evaluation-periods 1 \
  --threshold 5 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions <sns-topic-arn>
```

## Cost Optimization

- **Secrets Manager**: $0.40/secret/month + $0.05/10,000 API calls
- **Parameter Store Standard**: Free
- **Parameter Store Advanced**: $0.05/parameter/month

**Recommendation:**
- Use Secrets Manager for sensitive data that needs rotation
- Use Parameter Store for configuration values
- Clean up unused secrets regularly

```bash
# List all secrets
aws secretsmanager list-secrets --region us-east-2

# Check last accessed time
aws secretsmanager describe-secret \
  --secret-id /maestrohwithit/prod/unused-secret \
  --query 'LastAccessedDate'
```
