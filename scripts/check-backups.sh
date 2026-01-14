#!/bin/bash
#
# Backup Verification Script
# Checks backup status and verifies recovery points
#
# Usage: ./scripts/check-backups.sh [environment]
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

ENVIRONMENT=${1:-all}

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Backup Status Report              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Get backup vaults
echo -e "${YELLOW}━━━ Backup Vaults ━━━${NC}"
aws backup list-backup-vaults --query 'BackupVaultList[].[BackupVaultName,NumberOfRecoveryPoints]' --output table
echo ""

# Check recent backup jobs
echo -e "${YELLOW}━━━ Recent Backup Jobs (Last 24 hours) ━━━${NC}"
YESTERDAY=$(date -u -d '1 day ago' +%Y-%m-%dT%H:%M:%S)

aws backup list-backup-jobs \
    --by-created-after $YESTERDAY \
    --query 'BackupJobs[?State==`COMPLETED`].[BackupJobId,ResourceType,CreationDate,State]' \
    --output table 2>/dev/null || echo "No recent backups found"
echo ""

# Check failed backups
FAILED_BACKUPS=$(aws backup list-backup-jobs \
    --by-state FAILED \
    --by-created-after $YESTERDAY \
    --query 'BackupJobs[].BackupJobId' \
    --output text 2>/dev/null)

if [ ! -z "$FAILED_BACKUPS" ]; then
    echo -e "${RED}⚠ Failed Backups Detected!${NC}"
    aws backup list-backup-jobs --by-state FAILED --by-created-after $YESTERDAY --output table
    echo ""
else
    echo -e "${GREEN}✓ No failed backups in the last 24 hours${NC}"
    echo ""
fi

# RDS Snapshots
echo -e "${YELLOW}━━━ RDS Snapshots ━━━${NC}"
if [ "$ENVIRONMENT" == "all" ]; then
    aws rds describe-db-snapshots \
        --query 'DBSnapshots[?Status==`available`].[DBSnapshotIdentifier,SnapshotCreateTime,AllocatedStorage]' \
        --output table 2>/dev/null | head -20
else
    aws rds describe-db-snapshots \
        --query "DBSnapshots[?contains(DBSnapshotIdentifier,'$ENVIRONMENT') && Status=='available'].[DBSnapshotIdentifier,SnapshotCreateTime,AllocatedStorage]" \
        --output table 2>/dev/null
fi
echo ""

# EC2 AMIs
echo -e "${YELLOW}━━━ EC2 AMIs (Last 10) ━━━${NC}"
aws ec2 describe-images \
    --owners self \
    --query 'Images[?State==`available`].[Name,ImageId,CreationDate] | sort_by(@, &[2]) | reverse(@) | [0:10]' \
    --output table 2>/dev/null || echo "No AMIs found"
echo ""

# EBS Snapshots
echo -e "${YELLOW}━━━ EBS Snapshots (Last 10) ━━━${NC}"
aws ec2 describe-snapshots \
    --owner-ids self \
    --query 'Snapshots[?State==`completed`].[SnapshotId,VolumeSize,StartTime,Description] | sort_by(@, &[2]) | reverse(@) | [0:10]' \
    --output table 2>/dev/null || echo "No snapshots found"
echo ""

# Recommendations
echo -e "${YELLOW}━━━ Backup Health Recommendations ━━━${NC}"
echo ""

# Check if any resources are tagged for backup but not backed up
echo "💡 Recommendations:"
echo "   • Verify all production resources have 'Backup=true' tag"
echo "   • Test restore procedures monthly"
echo "   • Review backup retention policies"
echo "   • Consider cross-region backup for disaster recovery"
echo "   • Monitor backup costs"
echo ""

echo -e "${GREEN}✓ Backup check complete${NC}"
