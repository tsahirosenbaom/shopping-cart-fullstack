#!/bin/bash

echo "🧹 Cleaning up AWS resources..."

PROJECT_NAME="shopping-cart-system"
REGION="us-east-1"

read -p "⚠️  This will delete ALL AWS resources for the shopping cart system. Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled"
    exit 1
fi

# Delete CloudFront distribution
if [ -f "react-deployment.txt" ]; then
    source react-deployment.txt
    
    echo "🌐 Disabling CloudFront distribution..."
    aws cloudfront get-distribution-config --id $DISTRIBUTION_ID --output json > cf-config.json
    
    # Extract ETag and update config to disable
    ETAG=$(jq -r '.ETag' cf-config.json)
    jq '.DistributionConfig.Enabled = false' cf-config.json > cf-config-disabled.json
    
    aws cloudfront update-distribution \
        --id $DISTRIBUTION_ID \
        --distribution-config file://cf-config-disabled.json \
        --if-match $ETAG
    
    echo "⏳ Waiting for CloudFront to disable (this may take several minutes)..."
    aws cloudfront wait distribution-deployed --id $DISTRIBUTION_ID
    
    echo "🗑️ Deleting CloudFront distribution..."
    aws cloudfront delete-distribution --id $DISTRIBUTION_ID --if-match $ETAG
    
    # Empty and delete S3 bucket
    echo "🗑️ Emptying and deleting S3 bucket..."
    aws s3 rm "s3://$BUCKET_NAME" --recursive
    aws s3 rb "s3://$BUCKET_NAME"
fi

# Delete CloudFormation stacks
echo "🗑️ Deleting CloudFormation stacks..."
aws cloudformation delete-stack --stack-name "$PROJECT_NAME-services" --region $REGION
aws cloudformation delete-stack --stack-name "$PROJECT_NAME-infrastructure" --region $REGION

echo "⏳ Waiting for stacks to delete..."
aws cloudformation wait stack-delete-complete --stack-name "$PROJECT_NAME-services" --region $REGION
aws cloudformation wait stack-delete-complete --stack-name "$PROJECT_NAME-infrastructure" --region $REGION

# Delete ECR repositories
if [ -f "ecr-repos.txt" ]; then
    echo "🗑️ Deleting ECR repositories..."
    aws ecr delete-repository --repository-name "$PROJECT_NAME/dotnet-api" --force --region $REGION
    aws ecr delete-repository --repository-name "$PROJECT_NAME/nodejs-api" --force --region $REGION
fi

echo "✅ Cleanup complete!"
echo "All AWS resources have been removed."
