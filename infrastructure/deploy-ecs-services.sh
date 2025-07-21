#!/bin/bash

echo "🚀 Deploying ECS Services"
echo "========================="

PROJECT_NAME="shopping-cart-system"
REGION="us-east-1"

# Load ECR repository URIs
if [ ! -f "ecr-repos.txt" ]; then
    echo "❌ ecr-repos.txt not found!"
    exit 1
fi

source ecr-repos.txt

echo "📦 Using Docker images:"
echo "   .NET API: $DOTNET_REPO_URI:latest"
echo "   Node.js API: $NODEJS_REPO_URI:latest"

# Deploy ECS services
echo ""
echo "🚀 Deploying ECS Services CloudFormation stack..."

aws cloudformation deploy \
    --template-file ecs-services.yaml \
    --stack-name "$PROJECT_NAME-services" \
    --parameter-overrides \
        ProjectName=$PROJECT_NAME \
        DotNetImageURI=$DOTNET_REPO_URI:latest \
        NodeJsImageURI=$NODEJS_REPO_URI:latest \
    --capabilities CAPABILITY_IAM \
    --region $REGION

if [ $? -eq 0 ]; then
    echo "✅ ECS Services deployment successful!"
    
    # Wait for services to become stable
    echo ""
    echo "⏳ Waiting for services to become healthy (this may take 5-10 minutes)..."
    
    # Check service status
    echo "📊 Checking service status..."
    aws ecs describe-services \
        --cluster "$PROJECT_NAME-cluster" \
        --services "$PROJECT_NAME-dotnet-api" "$PROJECT_NAME-nodejs-api" \
        --region $REGION \
        --query 'services[*].[serviceName,status,runningCount,desiredCount,taskDefinition]' \
        --output table
    
    # Get ALB DNS name
    ALB_DNS_NAME=$(aws cloudformation describe-stacks \
        --stack-name "$PROJECT_NAME-infrastructure" \
        --query 'Stacks[0].Outputs[?OutputKey==`ALBDNSName`].OutputValue' \
        --output text \
        --region $REGION)
    
    echo ""
    echo "🧪 Testing API endpoints..."
    echo "ALB DNS: $ALB_DNS_NAME"
    
    # Wait a bit for load balancer to register targets
    sleep 60
    
    # Test health endpoints
    echo "Testing .NET API health..."
    if curl -s --connect-timeout 10 "http://$ALB_DNS_NAME/api/health" 2>/dev/null | grep -q "OK"; then
        echo "✅ .NET API health check passed"
    else
        echo "⚠️ .NET API health check not responding yet"
    fi
    
    echo "Testing Node.js API health..."
    if curl -s --connect-timeout 10 "http://$ALB_DNS_NAME/api/search/health" 2>/dev/null | grep -q "OK"; then
        echo "✅ Node.js API health check passed"
    else
        echo "⚠️ Node.js API health check not responding yet"
    fi
    
    echo ""
    echo "🎉 ECS Services deployment complete!"
    echo "=================================="
    echo "🔗 API Base URL: http://$ALB_DNS_NAME"
    echo ""
    echo "🧪 Test these endpoints:"
    echo "   .NET API Health: http://$ALB_DNS_NAME/api/health"
    echo "   .NET API Swagger: http://$ALB_DNS_NAME/swagger"
    echo "   Node.js API Health: http://$ALB_DNS_NAME/api/search/health"
    echo ""
    echo "📋 Monitor services:"
    echo "   aws ecs describe-services --cluster $PROJECT_NAME-cluster --services $PROJECT_NAME-dotnet-api $PROJECT_NAME-nodejs-api --region $REGION"
    echo ""
    echo "🔗 Next step: Update React app to use http://$ALB_DNS_NAME"
    
else
    echo "❌ ECS Services deployment failed"
    echo "🔍 Check CloudFormation console for detailed error messages"
    exit 1
fi
