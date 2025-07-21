#!/bin/bash

echo "🔍 Diagnosing ECS Infrastructure"
echo "================================"

REGION="us-east-1"
PROJECT_NAME="shopping-cart-system"

echo "1️⃣ Checking CloudFormation stacks..."
echo "======================================"

# List all stacks related to shopping cart
echo "All shopping-cart related stacks:"
aws cloudformation list-stacks \
    --region $REGION \
    --query 'StackSummaries[?contains(StackName, `shopping-cart`) && StackStatus!=`DELETE_COMPLETE`].[StackName,StackStatus,CreationTime]' \
    --output table

echo ""
echo "2️⃣ Checking specific stack: $PROJECT_NAME-infrastructure"
echo "========================================================="

# Check infrastructure stack specifically
INFRA_STACK_STATUS=$(aws cloudformation describe-stacks \
    --stack-name "$PROJECT_NAME-infrastructure" \
    --region $REGION \
    --query 'Stacks[0].StackStatus' \
    --output text 2>/dev/null)

if [ "$INFRA_STACK_STATUS" != "None" ] && [ -n "$INFRA_STACK_STATUS" ]; then
    echo "✅ Infrastructure stack exists with status: $INFRA_STACK_STATUS"
    
    echo "📋 Stack outputs:"
    aws cloudformation describe-stacks \
        --stack-name "$PROJECT_NAME-infrastructure" \
        --region $REGION \
        --query 'Stacks[0].Outputs' \
        --output table 2>/dev/null || echo "No outputs found"
        
    echo ""
    echo "📋 Stack resources:"
    aws cloudformation list-stack-resources \
        --stack-name "$PROJECT_NAME-infrastructure" \
        --region $REGION \
        --query 'StackResourceSummaries[?ResourceType==`AWS::ElasticLoadBalancingV2::LoadBalancer`].[LogicalResourceId,PhysicalResourceId,ResourceStatus]' \
        --output table 2>/dev/null || echo "No load balancers found"
        
else
    echo "❌ Infrastructure stack not found or failed"
fi

echo ""
echo "3️⃣ Checking services stack: $PROJECT_NAME-services"
echo "=================================================="

SERVICES_STACK_STATUS=$(aws cloudformation describe-stacks \
    --stack-name "$PROJECT_NAME-services" \
    --region $REGION \
    --query 'Stacks[0].StackStatus' \
    --output text 2>/dev/null)

if [ "$SERVICES_STACK_STATUS" != "None" ] && [ -n "$SERVICES_STACK_STATUS" ]; then
    echo "✅ Services stack exists with status: $SERVICES_STACK_STATUS"
    
    echo "📋 Stack outputs:"
    aws cloudformation describe-stacks \
        --stack-name "$PROJECT_NAME-services" \
        --region $REGION \
        --query 'Stacks[0].Outputs' \
        --output table 2>/dev/null || echo "No outputs found"
else
    echo "❌ Services stack not found or failed"
fi

echo ""
echo "4️⃣ Checking ECS resources directly..."
echo "====================================="

echo "ECS Clusters:"
aws ecs list-clusters --region $REGION --query 'clusterArns' --output table 2>/dev/null || echo "No ECS clusters found"

echo ""
echo "Load Balancers:"
aws elbv2 describe-load-balancers --region $REGION --query 'LoadBalancers[?contains(LoadBalancerName, `shopping-cart`)].[LoadBalancerName,DNSName,State.Code]' --output table 2>/dev/null || echo "No load balancers found"

echo ""
echo "5️⃣ Checking ECR repositories..."
echo "==============================="

echo "ECR repositories:"
aws ecr describe-repositories --region $REGION --query 'repositories[?contains(repositoryName, `shopping-cart`)].[repositoryName,repositoryUri]' --output table 2>/dev/null || echo "No ECR repositories found"

echo ""
echo "6️⃣ Summary and Next Steps"
echo "========================="

if [ "$INFRA_STACK_STATUS" == "CREATE_COMPLETE" ] || [ "$INFRA_STACK_STATUS" == "UPDATE_COMPLETE" ]; then
    echo "✅ Infrastructure stack is healthy"
    if [ "$SERVICES_STACK_STATUS" == "CREATE_COMPLETE" ] || [ "$SERVICES_STACK_STATUS" == "UPDATE_COMPLETE" ]; then
        echo "✅ Services stack is healthy"
        echo "💡 The ALB DNS should be available. Check if there's a different output key name."
    else
        echo "❌ Services stack is not ready. You need to deploy ECS services."
    fi
else
    echo "❌ Infrastructure stack is not ready. You need to run the full ECS deployment."
    echo ""
    echo "🚀 To deploy ECS infrastructure, run:"
    echo "   cd infrastructure"
    echo "   ./deploy-everything.sh"
fi
