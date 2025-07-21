#!/bin/bash

echo "🚀 Deploying Shopping Cart System to AWS..."
echo "============================================"

# Variables
REGION="us-east-1"
PROJECT_NAME="shopping-cart-system"
CLUSTER_NAME="$PROJECT_NAME-cluster"

echo "📋 Deployment Overview:"
echo "• Region: $REGION"
echo "• Project: $PROJECT_NAME"
echo "• ECS Cluster: $CLUSTER_NAME"
echo ""

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install it first."
    exit 1
fi

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install it first."
    exit 1
fi

echo "✅ Prerequisites checked"
echo ""

# Load infrastructure IDs if they exist
if [ -f "../infrastructure-ids.txt" ]; then
    source ../infrastructure-ids.txt
    echo "📁 Using existing infrastructure"
else
    echo "🏗️ Will create new infrastructure"
fi

echo "🚀 Starting deployment process..."
