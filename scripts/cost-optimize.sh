#!/bin/bash
#
# Cost Optimization - Auto Shutdown Script
# Automatically stops dev/staging resources during off-hours
#
# Usage: Run via cron or EventBridge
# Example cron: 0 18 * * 1-5 /path/to/shutdown.sh  # 6 PM weekdays
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ACTION=${1:-stop}  # stop or start
ENVIRONMENT=${2:-dev}  # dev or staging

echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Cost Optimization - Resource Manager   ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Action:${NC} $ACTION"
echo -e "${YELLOW}Environment:${NC} $ENVIRONMENT"
echo ""

# Function to stop EC2 instances
stop_ec2_instances() {
    local env=$1
    echo -e "${YELLOW}━━━ Stopping EC2 Instances ($env) ━━━${NC}"
    
    INSTANCES=$(aws ec2 describe-instances \
        --filters "Name=tag:Environment,Values=$env" "Name=instance-state-name,Values=running" \
        --query 'Reservations[].Instances[].InstanceId' \
        --output text)
    
    if [ -z "$INSTANCES" ]; then
        echo "No running instances found"
    else
        echo "Stopping instances: $INSTANCES"
        aws ec2 stop-instances --instance-ids $INSTANCES
        echo -e "${GREEN}✓ Instances stopped${NC}"
    fi
    echo ""
}

# Function to start EC2 instances
start_ec2_instances() {
    local env=$1
    echo -e "${YELLOW}━━━ Starting EC2 Instances ($env) ━━━${NC}"
    
    INSTANCES=$(aws ec2 describe-instances \
        --filters "Name=tag:Environment,Values=$env" "Name=instance-state-name,Values=stopped" \
        --query 'Reservations[].Instances[].InstanceId' \
        --output text)
    
    if [ -z "$INSTANCES" ]; then
        echo "No stopped instances found"
    else
        echo "Starting instances: $INSTANCES"
        aws ec2 start-instances --instance-ids $INSTANCES
        echo -e "${GREEN}✓ Instances started${NC}"
    fi
    echo ""
}

# Function to stop RDS instances
stop_rds_instances() {
    local env=$1
    echo -e "${YELLOW}━━━ Stopping RDS Instances ($env) ━━━${NC}"
    
    DATABASES=$(aws rds describe-db-instances \
        --query "DBInstances[?contains(DBInstanceIdentifier,'$env') && DBInstanceStatus=='available'].DBInstanceIdentifier" \
        --output text)
    
    if [ -z "$DATABASES" ]; then
        echo "No available databases found"
    else
        for db in $DATABASES; do
            echo "Stopping database: $db"
            aws rds stop-db-instance --db-instance-identifier $db 2>/dev/null || echo "Already stopped or cannot stop"
        done
        echo -e "${GREEN}✓ Databases stopped${NC}"
    fi
    echo ""
}

# Function to start RDS instances  
start_rds_instances() {
    local env=$1
    echo -e "${YELLOW}━━━ Starting RDS Instances ($env) ━━━${NC}"
    
    DATABASES=$(aws rds describe-db-instances \
        --query "DBInstances[?contains(DBInstanceIdentifier,'$env') && DBInstanceStatus=='stopped'].DBInstanceIdentifier" \
        --output text)
    
    if [ -z "$DATABASES" ]; then
        echo "No stopped databases found"
    else
        for db in $DATABASES; do
            echo "Starting database: $db"
            aws rds start-db-instance --db-instance-identifier $db
        done
        echo -e "${GREEN}✓ Databases started${NC}"
    fi
    echo ""
}

# Function to scale down EKS node groups
scale_down_eks() {
    local env=$1
    echo -e "${YELLOW}━━━ Scaling Down EKS ($env) ━━━${NC}"
    
    CLUSTERS=$(aws eks list-clusters --query "clusters[?contains(@,'$env')]" --output text)
    
    if [ -z "$CLUSTERS" ]; then
        echo "No EKS clusters found"
    else
        for cluster in $CLUSTERS; do
            echo "Scaling down cluster: $cluster"
            
            NODE_GROUPS=$(aws eks list-nodegroups --cluster-name $cluster --query 'nodegroups' --output text)
            
            for ng in $NODE_GROUPS; do
                echo "  Scaling node group: $ng to 0"
                aws eks update-nodegroup-config \
                    --cluster-name $cluster \
                    --nodegroup-name $ng \
                    --scaling-config minSize=0,maxSize=0,desiredSize=0 2>/dev/null || echo "  Cannot scale"
            done
        done
        echo -e "${GREEN}✓ EKS scaled down${NC}"
    fi
    echo ""
}

# Function to scale up EKS node groups
scale_up_eks() {
    local env=$1
    echo -e "${YELLOW}━━━ Scaling Up EKS ($env) ━━━${NC}"
    
    CLUSTERS=$(aws eks list-clusters --query "clusters[?contains(@,'$env')]" --output text)
    
    if [ -z "$CLUSTERS" ]; then
        echo "No EKS clusters found"
    else
        for cluster in $CLUSTERS; do
            echo "Scaling up cluster: $cluster"
            
            NODE_GROUPS=$(aws eks list-nodegroups --cluster-name $cluster --query 'nodegroups' --output text)
            
            for ng in $NODE_GROUPS; do
                if [ "$env" == "dev" ]; then
                    echo "  Scaling node group: $ng to 1"
                    aws eks update-nodegroup-config \
                        --cluster-name $cluster \
                        --nodegroup-name $ng \
                        --scaling-config minSize=1,maxSize=2,desiredSize=1
                else
                    echo "  Scaling node group: $ng to 2"
                    aws eks update-nodegroup-config \
                        --cluster-name $cluster \
                        --nodegroup-name $ng \
                        --scaling-config minSize=1,maxSize=5,desiredSize=2
                fi
            done
        done
        echo -e "${GREEN}✓ EKS scaled up${NC}"
    fi
    echo ""
}

# Calculate potential savings
calculate_savings() {
    echo -e "${YELLOW}━━━ Cost Savings Calculation ━━━${NC}"
    echo ""
    
    # Assuming 12 hours/day * 5 days/week = 60 hours/week stopped
    # Out of 168 hours/week = ~36% time stopped
    
    if [ "$ENVIRONMENT" == "dev" ]; then
        MONTHLY_COST=100
    else
        MONTHLY_COST=250
    fi
    
    SAVINGS=$(echo "$MONTHLY_COST * 0.36" | bc)
    
    echo "Monthly cost (running 24/7): \$$MONTHLY_COST"
    echo "Estimated savings (12h/day off): \$$SAVINGS"
    echo "Annual savings: \$$(echo "$SAVINGS * 12" | bc)"
    echo ""
}

# Main execution
case $ACTION in
    stop)
        echo -e "${YELLOW}Stopping resources for $ENVIRONMENT environment...${NC}"
        echo ""
        
        stop_ec2_instances $ENVIRONMENT
        stop_rds_instances $ENVIRONMENT
        
        if [ "$ENVIRONMENT" != "prod" ]; then
            scale_down_eks $ENVIRONMENT
        fi
        
        calculate_savings
        
        echo -e "${GREEN}✓ Shutdown complete!${NC}"
        echo "Resources will be stopped in a few minutes."
        ;;
        
    start)
        echo -e "${YELLOW}Starting resources for $ENVIRONMENT environment...${NC}"
        echo ""
        
        start_ec2_instances $ENVIRONMENT
        start_rds_instances $ENVIRONMENT
        
        if [ "$ENVIRONMENT" != "prod" ]; then
            scale_up_eks $ENVIRONMENT
        fi
        
        echo -e "${GREEN}✓ Startup complete!${NC}"
        echo "Resources will be available in a few minutes."
        ;;
        
    *)
        echo -e "${RED}Unknown action: $ACTION${NC}"
        echo "Usage: $0 {stop|start} {dev|staging}"
        exit 1
        ;;
esac

# Send notification (optional)
if command -v aws &> /dev/null; then
    SNS_TOPIC="arn:aws:sns:us-east-2:$(aws sts get-caller-identity --query Account --output text):maestrohwithit-notifications"
    
    aws sns publish \
        --topic-arn "$SNS_TOPIC" \
        --subject "Cost Optimization: $ENVIRONMENT resources $ACTION" \
        --message "All $ENVIRONMENT resources have been ${ACTION}ped for cost savings." \
        2>/dev/null || echo ""
fi

echo ""
echo "═════════════════════════════════════════════════"
echo "💰 Cost Optimization Script Complete"
echo "═════════════════════════════════════════════════"
