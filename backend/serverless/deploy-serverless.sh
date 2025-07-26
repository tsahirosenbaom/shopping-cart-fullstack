#!/bin/bash

echo "🚀 Deploying Serverless Shopping Cart..."

STACK_NAME="serverless-shopping-cart"
REGION="us-east-1"
S3_BUCKET="$STACK_NAME-deployments-$(date +%s)"

# Check prerequisites
if ! command -v sam &> /dev/null; then
    echo "❌ AWS SAM CLI not found. Installing..."
    
    # Install SAM CLI
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
        unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
        sudo ./sam-installation/install
        rm -rf sam-installation aws-sam-cli-linux-x86_64.zip
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew tap aws/tap
        brew install aws-sam-cli
    else
        echo "Please install AWS SAM CLI manually: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html"
        exit 1
    fi
fi

# Create S3 bucket for deployments
echo "📦 Creating S3 bucket for deployments..."
aws s3 mb s3://$S3_BUCKET --region $REGION

# Build the application
echo "🏗️ Building SAM application..."
sam build

# Deploy the application
echo "🚀 Deploying to AWS..."
sam deploy \
    --stack-name $STACK_NAME \
    --s3-bucket $S3_BUCKET \
    --capabilities CAPABILITY_IAM \
    --region $REGION \
    --parameter-overrides Stage=prod \
    --confirm-changeset

# Get API Gateway URL
API_URL=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --query 'Stacks[0].Outputs[?OutputKey==`ShoppingCartApi`].OutputValue' \
    --output text \
    --region $REGION)

echo ""
echo "✅ Deployment completed!"
echo "========================"
echo ""
echo "🌐 API Gateway URL: $API_URL"
echo ""

# Seed the database
echo "🌱 Seeding database with initial data..."
SEED_FUNCTION_NAME=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --query 'Stacks[0].Outputs[?contains(OutputKey, `DataSeedFunction`)].OutputValue' \
    --output text \
    --region $REGION 2>/dev/null)

if [ -z "$SEED_FUNCTION_NAME" ]; then
    SEED_FUNCTION_NAME="$STACK_NAME-DataSeedFunction-"
    # Find the actual function name
    ACTUAL_FUNCTION=$(aws lambda list-functions \
        --query "Functions[?contains(FunctionName, '$SEED_FUNCTION_NAME')].FunctionName" \
        --output text \
        --region $REGION)
    
    if [ ! -z "$ACTUAL_FUNCTION" ]; then
        echo "📥 Invoking seed function: $ACTUAL_FUNCTION"
        aws lambda invoke \
            --function-name "$ACTUAL_FUNCTION" \
            --region $REGION \
            seed-response.json
        
        cat seed-response.json
        rm -f seed-response.json
    else
        echo "⚠️ Could not find seed function. You may need to seed data manually."
    fi
fi

echo ""
echo "🧪 Test the APIs:"
echo "================"
echo "Health Check:"
echo "curl $API_URL/health"
echo ""
echo "Get Categories:"
echo "curl $API_URL/api/categories"
echo ""
echo "Get Products:"
echo "curl $API_URL/api/products"
echo ""

# Save deployment info
cat > serverless-deployment.txt << DEPLOYEOF
STACK_NAME=$STACK_NAME
API_URL=$API_URL
S3_BUCKET=$S3_BUCKET
REGION=$REGION
DEPLOYEOF

echo "📝 Deployment info saved to serverless-deployment.txt"
echo ""
echo "💰 Estimated Costs:"
echo "=================="
echo "• API Gateway: $3.50 per million requests"
echo "• Lambda: $0.20 per million requests + compute time"
echo "• DynamoDB: $1.25 per million read/write requests"
echo "• S3: $0.023 per GB storage"
echo ""
echo "🎯 For typical usage: $1-5 per month"
echo "🆓 AWS Free Tier includes:"
echo "  • 1 million Lambda requests/month"
echo "  • 1 million API Gateway requests/month"
echo "  • 25 GB DynamoDB storage"
