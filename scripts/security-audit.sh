#!/bin/bash
#
# Security Audit Script
# Runs security checks on infrastructure
#
# Usage: ./scripts/security-audit.sh
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    Infrastructure Security Audit       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Run tfsec
echo -e "${YELLOW}━━━ Running tfsec Security Scan ━━━${NC}"
echo ""

if command -v tfsec &> /dev/null; then
    tfsec "$PROJECT_ROOT" --minimum-severity MEDIUM --format default || true
    echo ""
else
    echo -e "${YELLOW}⚠ tfsec not installed. Install with: brew install tfsec${NC}"
    echo ""
fi

# Run Checkov
echo -e "${YELLOW}━━━ Running Checkov Policy Scan ━━━${NC}"
echo ""

if command -v checkov &> /dev/null; then
    checkov -d "$PROJECT_ROOT" --framework terraform --quiet --compact || true
    echo ""
else
    echo -e "${YELLOW}⚠ checkov not installed. Install with: pip install checkov${NC}"
    echo ""
fi

# Check for exposed secrets
echo -e "${YELLOW}━━━ Checking for Exposed Secrets ━━━${NC}"
echo ""

# Check git history for secrets
if command -v git-secrets &> /dev/null; then
    cd "$PROJECT_ROOT"
    git secrets --scan || true
    echo ""
else
    echo -e "${YELLOW}⚠ git-secrets not installed${NC}"
    echo "Install with: brew install git-secrets"
    echo ""
fi

# AWS Security Checks
echo -e "${YELLOW}━━━ AWS Security Checks ━━━${NC}"
echo ""

# Check for public S3 buckets
echo "Checking S3 buckets for public access..."
PUBLIC_BUCKETS=$(aws s3api list-buckets --query 'Buckets[].Name' --output text | while read bucket; do
    PUBLIC=$(aws s3api get-bucket-public-access-block --bucket $bucket 2>/dev/null | jq -r '.PublicAccessBlockConfiguration.BlockPublicAcls' || echo "null")
    if [ "$PUBLIC" != "true" ]; then
        echo "$bucket"
    fi
done)

if [ -z "$PUBLIC_BUCKETS" ]; then
    echo -e "${GREEN}✓ No public S3 buckets found${NC}"
else
    echo -e "${RED}⚠ Public buckets found:${NC}"
    echo "$PUBLIC_BUCKETS"
fi
echo ""

# Check for unencrypted EBS volumes
echo "Checking for unencrypted EBS volumes..."
UNENCRYPTED=$(aws ec2 describe-volumes \
    --query 'Volumes[?Encrypted==`false`].[VolumeId,Size]' \
    --output text)

if [ -z "$UNENCRYPTED" ]; then
    echo -e "${GREEN}✓ All EBS volumes are encrypted${NC}"
else
    echo -e "${YELLOW}⚠ Unencrypted volumes found:${NC}"
    echo "$UNENCRYPTED"
fi
echo ""

# Check for open security groups
echo "Checking for overly permissive security groups..."
OPEN_SG=$(aws ec2 describe-security-groups \
    --query 'SecurityGroups[?IpPermissions[?IpRanges[?CidrIp==`0.0.0.0/0`] && (FromPort==`22` || FromPort==`3389`)]].[GroupId,GroupName]' \
    --output text)

if [ -z "$OPEN_SG" ]; then
    echo -e "${GREEN}✓ No security groups with open SSH/RDP${NC}"
else
    echo -e "${RED}⚠ Security groups with open SSH/RDP:${NC}"
    echo "$OPEN_SG"
fi
echo ""

# Check IAM password policy
echo "Checking IAM password policy..."
aws iam get-account-password-policy &>/dev/null && \
    echo -e "${GREEN}✓ IAM password policy configured${NC}" || \
    echo -e "${YELLOW}⚠ No IAM password policy configured${NC}"
echo ""

# Check MFA on root account
echo "Checking root account MFA..."
ROOT_MFA=$(aws iam get-account-summary --query 'SummaryMap.AccountMFAEnabled' --output text)
if [ "$ROOT_MFA" == "1" ]; then
    echo -e "${GREEN}✓ Root account MFA enabled${NC}"
else
    echo -e "${RED}⚠ Root account MFA not enabled!${NC}"
fi
echo ""

# Recommendations
echo -e "${YELLOW}━━━ Security Recommendations ━━━${NC}"
echo ""
echo "📋 Best Practices:"
echo "   • Enable MFA on all IAM users"
echo "   • Rotate access keys every 90 days"
echo "   • Use IAM roles instead of access keys where possible"
echo "   • Enable CloudTrail in all regions"
echo "   • Enable GuardDuty for threat detection"
echo "   • Implement AWS Config for compliance"
echo "   • Use AWS Secrets Manager for sensitive data"
echo "   • Regular security audits (monthly recommended)"
echo ""

echo -e "${GREEN}✓ Security audit complete${NC}"
echo ""
echo "For detailed security analysis, visit:"
echo "https://console.aws.amazon.com/securityhub"
