#!/bin/bash

echo "🚀 Deploying Complete Shopping Cart System to AWS"
echo "=================================================="

PROJECT_NAME="shopping-cart-system"
REGION="us-east-1"

# Step 1: Setup ECR repositories
echo "1️⃣ Setting up ECR repositories..."
./setup-ecr.sh

# Step 2: Build and push Docker images
echo "2️⃣ Building and pushing Docker images..."
./build-docker-images.sh

# Load repository URIs
source ecr-repos.txt

# Step 3: Deploy infrastructure
echo "3️⃣ Deploying infrastructure..."
aws cloudformation deploy \
    --template-file ecs-infrastructure.yaml \
    --stack-name "$PROJECT_NAME-infrastructure" \
    --parameter-overrides \
        ProjectName=$PROJECT_NAME \
        DotNetImageURI=$DOTNET_REPO_URI:latest \
        NodeJsImageURI=$NODEJS_REPO_URI:latest \
    --capabilities CAPABILITY_IAM \
    --region $REGION

# Step 4: Deploy ECS services
echo "4️⃣ Deploying ECS services..."
aws cloudformation deploy \
    --template-file ecs-services.yaml \
    --stack-name "$PROJECT_NAME-services" \
    --parameter-overrides \
        ProjectName=$PROJECT_NAME \
        DotNetImageURI=$DOTNET_REPO_URI:latest \
        NodeJsImageURI=$NODEJS_REPO_URI:latest \
    --capabilities CAPABILITY_IAM \
    --region $REGION

# Step 5: Deploy React app
echo "5️⃣ Deploying React app..."
./deploy-react.sh

echo ""
echo "🎉 Complete deployment finished!"
echo "==============================="

# Get final URLs
ALB_DNS_NAME=$(aws cloudformation describe-stacks \
    --stack-name "$PROJECT_NAME-infrastructure" \
    --query 'Stacks[0].Outputs[?OutputKey==`ALBDNSName`].OutputValue' \
    --output text \
    --region $REGION)

if [ -f "react-deployment.txt" ]; then
    source react-deployment.txt
    echo "📱 React App: https://$CLOUDFRONT_DOMAIN"
fi

echo "🔗 API Endpoints:"
echo "   .NET API: http://$ALB_DNS_NAME/swagger"
echo "   Node.js API: http://$ALB_DNS_NAME/health"
echo ""
echo "📊 AWS Resources Created:"
echo "   • VPC with public subnets"
echo "   • Application Load Balancer"
echo "   • ECS Cluster with Fargate services"
echo "   • ECR repositories"
echo "   • S3 bucket for React app"
echo "   • CloudFront distribution"
echo ""
echo "⏱️  Initial deployment may take 10-15 minutes for all services to be healthy"
echo "📋 Monitor deployment: aws ecs describe-services --cluster $PROJECT_NAME-cluster --services $PROJECT_NAME-dotnet-api $PROJECT_NAME-nodejs-api"
