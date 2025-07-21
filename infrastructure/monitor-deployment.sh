#!/bin/bash

echo "📊 Monitoring Shopping Cart System Deployment..."

PROJECT_NAME="shopping-cart-system"
REGION="us-east-1"

# Function to check service health
check_service_health() {
    local service_name=$1
    local cluster_name="$PROJECT_NAME-cluster"
    
    echo "Checking $service_name..."
    
    # Get service status
    SERVICE_STATUS=$(aws ecs describe-services \
        --cluster $cluster_name \
        --services $service_name \
        --query 'services[0].status' \
        --output text \
        --region $REGION 2>/dev/null)
    
    # Get running task count
    RUNNING_COUNT=$(aws ecs describe-services \
        --cluster $cluster_name \
        --services $service_name \
        --query 'services[0].runningCount' \
        --output text \
        --region $REGION 2>/dev/null)
    
    # Get desired task count
    DESIRED_COUNT=$(aws ecs describe-services \
        --cluster $cluster_name \
        --services $service_name \
        --query 'services[0].desiredCount' \
        --output text \
        --region $REGION 2>/dev/null)
    
    if [ "$SERVICE_STATUS" = "ACTIVE" ] && [ "$RUNNING_COUNT" = "$DESIRED_COUNT" ] && [ "$RUNNING_COUNT" != "0" ]; then
        echo "✅ $service_name: HEALTHY ($RUNNING_COUNT/$DESIRED_COUNT tasks running)"
    else
        echo "⚠️  $service_name: Status=$SERVICE_STATUS, Tasks=$RUNNING_COUNT/$DESIRED_COUNT"
    fi
}

# Check CloudFormation stacks
echo "🏗️ CloudFormation Stacks:"
echo "Infrastructure stack:"
aws cloudformation describe-stacks \
    --stack-name "$PROJECT_NAME-infrastructure" \
    --query 'Stacks[0].StackStatus' \
    --output text \
    --region $REGION 2>/dev/null || echo "Not found"

echo "Services stack:"
aws cloudformation describe-stacks \
    --stack-name "$PROJECT_NAME-services" \
    --query 'Stacks[0].StackStatus' \
    --output text \
    --region $REGION 2>/dev/null || echo "Not found"

echo ""
echo "🐳 ECS Services:"
check_service_health "$PROJECT_NAME-dotnet-api"
check_service_health "$PROJECT_NAME-nodejs-api"

echo ""
echo "🔗 Load Balancer Health:"
ALB_DNS_NAME=$(aws cloudformation describe-stacks \
    --stack-name "$PROJECT_NAME-infrastructure" \
    --query 'Stacks[0].Outputs[?OutputKey==`ALBDNSName`].OutputValue' \
    --output text \
    --region $REGION 2>/dev/null)

if [ ! -z "$ALB_DNS_NAME" ]; then
    echo "ALB DNS: $ALB_DNS_NAME"
    
    # Test .NET API
    echo -n "Testing .NET API... "
    if curl -s --max-time 10 "http://$ALB_DNS_NAME/swagger" > /dev/null; then
        echo "✅ Responding"
    else
        echo "❌ Not responding"
    fi
    
    # Test Node.js API
    echo -n "Testing Node.js API... "
    if curl -s --max-time 10 "http://$ALB_DNS_NAME/health" > /dev/null; then
        echo "✅ Responding"
    else
        echo "❌ Not responding"
    fi
else
    echo "❌ ALB DNS not found"
fi

echo ""
echo "📱 React App Status:"
if [ -f "react-deployment.txt" ]; then
    source react-deployment.txt
    echo "CloudFront Distribution: $DISTRIBUTION_ID"
    
    # Check CloudFront status
    CF_STATUS=$(aws cloudfront get-distribution \
        --id $DISTRIBUTION_ID \
        --query 'Distribution.Status' \
        --output text 2>/dev/null)
    
    echo "Status: $CF_STATUS"
    
    if [ "$CF_STATUS" = "Deployed" ]; then
        echo "✅ React App URL: https://$CLOUDFRONT_DOMAIN"
    else
        echo "⚠️  CloudFront still deploying (takes 15-20 minutes)"
    fi
else
    echo "React deployment info not found"
fi

echo ""
echo "🔄 To refresh this status: ./monitor-deployment.sh"
