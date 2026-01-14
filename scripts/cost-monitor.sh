#!/bin/bash
#
# AWS Cost Monitoring Script
# Generates cost reports and checks for budget alerts
#
# Usage: ./scripts/cost-monitor.sh [environment]
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

ENVIRONMENT=${1:-all}

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   maestrohwithit Infrastructure Cost Report    ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo ""

# Get current month
START_DATE=$(date -u -d "$(date +%Y-%m-01)" +%Y-%m-%d)
END_DATE=$(date -u +%Y-%m-%d)

echo -e "${GREEN}📊 Cost Period:${NC} $START_DATE to $END_DATE"
echo ""

# Function to format currency
format_currency() {
    printf "$%.2f" $1
}

# Get costs by environment
get_environment_cost() {
    local env=$1
    local cost=$(aws ce get-cost-and-usage \
        --time-period Start=$START_DATE,End=$END_DATE \
        --granularity MONTHLY \
        --metrics UnblendedCost \
        --filter file:/dev/stdin <<EOF 2>/dev/null | jq -r '.ResultsByTime[0].Total.UnblendedCost.Amount // "0"'
{
    "Tags": {
        "Key": "Environment",
        "Values": ["$env"]
    }
}
EOF
    )
    echo $cost
}

# Get costs by service
get_service_costs() {
    aws ce get-cost-and-usage \
        --time-period Start=$START_DATE,End=$END_DATE \
        --granularity MONTHLY \
        --metrics UnblendedCost \
        --group-by Type=SERVICE \
        --query 'ResultsByTime[0].Groups[?MetricValues.UnblendedCost.Amount>`1`].[Keys[0],MetricValues.UnblendedCost.Amount]' \
        --output table 2>/dev/null || echo "Error fetching service costs"
}

# Environment-specific costs
if [ "$ENVIRONMENT" == "all" ]; then
    echo -e "${YELLOW}━━━ Costs by Environment ━━━${NC}"
    echo ""
    
    for env in dev staging prod; do
        cost=$(get_environment_cost $env)
        if [ "$cost" != "0" ]; then
            printf "%-12s %s\n" "$env:" "\$$cost"
        fi
    done
    echo ""
else
    cost=$(get_environment_cost $ENVIRONMENT)
    echo -e "${YELLOW}━━━ Cost for $ENVIRONMENT ━━━${NC}"
    printf "Total: \$%s\n" "$cost"
    echo ""
fi

# Top services by cost
echo -e "${YELLOW}━━━ Top Services by Cost ━━━${NC}"
echo ""
get_service_costs
echo ""

# Forecast next month
echo -e "${YELLOW}━━━ Cost Forecast ━━━${NC}"
NEXT_MONTH_START=$(date -u -d "$(date +%Y-%m-01) +1 month" +%Y-%m-%d)
NEXT_MONTH_END=$(date -u -d "$NEXT_MONTH_START +1 month -1 day" +%Y-%m-%d)

FORECAST=$(aws ce get-cost-forecast \
    --time-period Start=$NEXT_MONTH_START,End=$NEXT_MONTH_END \
    --metric UNBLENDED_COST \
    --granularity MONTHLY \
    --query 'Total.Amount' \
    --output text 2>/dev/null || echo "N/A")

echo "Estimated next month: \$$FORECAST"
echo ""

# Savings recommendations
echo -e "${YELLOW}━━━ Cost Optimization Recommendations ━━━${NC}"
echo ""
echo "💡 Recommendations:"
echo "   • Review unused EC2 instances"
echo "   • Check for unattached EBS volumes"
echo "   • Consider Reserved Instances for production"
echo "   • Schedule dev/staging shutdown for off-hours"
echo "   • Enable S3 Intelligent-Tiering"
echo ""

# Check for budget alerts (if configured)
BUDGETS=$(aws budgets describe-budgets --account-id $(aws sts get-caller-identity --query Account --output text) --query 'Budgets[].BudgetName' --output text 2>/dev/null || echo "")

if [ ! -z "$BUDGETS" ]; then
    echo -e "${YELLOW}━━━ Budget Alerts ━━━${NC}"
    for budget in $BUDGETS; do
        echo "Budget: $budget"
    done
    echo ""
fi

echo -e "${GREEN}✓ Cost report complete${NC}"
echo ""
echo "For detailed analysis, visit: https://console.aws.amazon.com/cost-management"
