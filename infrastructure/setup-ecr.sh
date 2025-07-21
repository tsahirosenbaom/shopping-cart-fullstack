#!/bin/bash

echo "📦 Setting up ECR repositories..."

REGION="us-east-1"
PROJECT_NAME="shopping-cart-system"

# Create ECR repositories
echo "Creating ECR repositories..."

# .NET API repository
aws ecr create-repository \
    --repository-name "$PROJECT_NAME/dotnet-api" \
    --region $REGION || echo "Repository may already exist"

# Node.js API repository
aws ecr create-repository \
    --repository-name "$PROJECT_NAME/nodejs-api" \
    --region $REGION || echo "Repository may already exist"

# Get ECR login token
aws ecr get-login-password --region $REGION | docker login --username AWS --passw>
echo "✅ ECR repositories created and logged in"

# Save repository URIs
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
DOTNET_REPO_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$PROJECT_NAME/dotnet-a>NODEJS_REPO_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$PROJECT_NAME/nodejs-a>
echo "DOTNET_REPO_URI=$DOTNET_REPO_URI" > ecr-rep

#!/bin/bash

echo "📦 Setting up ECR repositories..."

REGION="us-east-1"
PROJECT_NAME="shopping-cart-system"

# Create ECR repositories
echo "Creating ECR repositories..."

# .NET API repository
aws ecr create-repository \
    --repository-name "$PROJECT_NAME/dotnet-api" \
    --region $REGION || echo "Repository may already exist"

# Node.js API repository  
aws ecr create-repository \
    --repository-name "$PROJECT_NAME/nodejs-api" \
    --region $REGION || echo "Repository may already exist"

# Get ECR login token
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.$REGION.amazonaws.com

echo "✅ ECR repositories created and logged in"

# Save repository URIs
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
DOTNET_REPO_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$PROJECT_NAME/dotnet-api"
NODEJS_REPO_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$PROJECT_NAME/nodejs-api"

echo "DOTNET_REPO_URI=$DOTNET_REPO_URI" > ecr-repos.txt
echo "NODEJS_REPO_URI=$NODEJS_REPO_URI" >> ecr-repos.txt
echo "ACCOUNT_ID=$ACCOUNT_ID" >> ecr-repos.txt
echo "REGION=$REGION" >> ecr-repos.txt

echo "📝 Repository URIs saved to ecr-repos.txt"
