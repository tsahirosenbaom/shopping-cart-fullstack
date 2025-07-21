#!/bin/bash

echo "🧹 Cleaning up Serverless Shopping Cart..."

# Load deployment info
if [ ! -f "serverless-deployment.txt" ]; then
    echo "❌ Deployment info not found."
    exit 1
fi

source serverless-deployment.txt

read -p "⚠️  This will delete the entire serverless stack. Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled"
    exit 1
fi

echo "🗑️ Deleting CloudFormation stack..."
aws cloudformation delete-stack \
    --stack-name $STACK_NAME \
    --region $REGION

echo "⏳ Waiting for stack deletion..."
aws cloudformation wait stack-delete-complete \
    --stack-name $STACK_NAME \
    --region $REGION

echo "🗑️ Deleting S3 deployment bucket..."
aws s3 rm s3://$S3_BUCKET --recursive
aws s3 rb s3://$S3_BUCKET

echo "✅ Cleanup completed!"
echo "All serverless resources have been removed."
