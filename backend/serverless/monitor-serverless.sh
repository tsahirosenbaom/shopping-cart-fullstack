#!/bin/bash

echo "📊 Monitoring Serverless Shopping Cart..."

# Load deployment info
if [ ! -f "serverless-deployment.txt" ]; then
    echo "❌ Deployment info not found. Please deploy first."
    exit 1
fi

source serverless-deployment.txt

echo "📋 Stack: $STACK_NAME"
echo "🌐 API: $API_URL"
echo ""

# Check CloudFormation stack status
echo "🏗️ CloudFormation Stack Status:"
STACK_STATUS=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --query 'Stacks[0].StackStatus' \
    --output text \
    --region $REGION 2>/dev/null)

echo "Status: $STACK_STATUS"
echo ""

# Check Lambda functions
echo "⚡ Lambda Functions:"
aws lambda list-functions \
    --query "Functions[?contains(FunctionName, '$STACK_NAME')].{Name:FunctionName,Runtime:Runtime,LastModified:LastModified}" \
    --output table \
    --region $REGION

echo ""

# Check DynamoDB tables
echo "🗃️ DynamoDB Tables:"
TABLES=$(aws cloudformation describe-stack-resources \
    --stack-name $STACK_NAME \
    --query 'StackResources[?ResourceType==`AWS::DynamoDB::Table`].PhysicalResourceId' \
    --output text \
    --region $REGION)

for table in $TABLES; do
    ITEM_COUNT=$(aws dynamodb describe-table \
        --table-name $table \
        --query 'Table.ItemCount' \
        --output text \
        --region $REGION)
    echo "$table: $ITEM_COUNT items"
done

echo ""

# Quick health check
echo "🏥 Health Check:"
curl -s --max-time 10 "$API_URL/health" | jq '.status' 2>/dev/null || echo "❌ Health check failed"

echo ""
echo "💰 Cost Estimate (Current Month):"
echo "================================="

# Get Lambda invocations for current month
START_DATE=$(date -d "$(date +%Y-%m-01)" -I)
END_DATE=$(date -I)

echo "📊 Lambda Metrics (since $START_DATE):"
aws lambda list-functions \
    --query "Functions[?contains(FunctionName, '$STACK_NAME')].FunctionName" \
    --output text \
    --region $REGION | while read function; do
    
    INVOCATIONS=$(aws logs filter-log-events \
        --log-group-name "/aws/lambda/$function" \
        --start-time $(date -d "$START_DATE" +%s)000 \
        --query 'events[?message=~`START`]' \
        --output text \
        --region $REGION 2>/dev/null | wc -l)
    
    echo "  $function: $INVOCATIONS invocations"
done

echo ""
echo "🔄 To refresh status: ./monitor-serverless.sh"
