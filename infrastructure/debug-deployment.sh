#!/bin/bash

echo "🔍 Debugging ECS Deployment Setup"
echo "=================================="

PROJECT_NAME="shopping-cart-system"
REGION="us-east-1"

# Check if we're in the right directory
echo "📁 Current directory: $(pwd)"
echo "📂 Directory contents:"
ls -la

echo ""
echo "🔧 Checking required scripts:"
REQUIRED_SCRIPTS=("setup-ecr.sh" "build-docker-images.sh" "deploy-react.sh")
for script in "${REQUIRED_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        echo "✅ $script exists"
        if [ -x "$script" ]; then
            echo "   ✅ $script is executable"
        else
            echo "   ❌ $script is NOT executable (need: chmod +x $script)"
        fi
    else
        echo "❌ $script is MISSING"
    fi
done

echo ""
echo "📄 Checking CloudFormation templates:"
CF_TEMPLATES=("ecs-infrastructure.yaml" "ecs-services.yaml")
for template in "${CF_TEMPLATES[@]}"; do
    if [ -f "$template" ]; then
        echo "✅ $template exists"
    else
        echo "❌ $template is MISSING"
    fi
done

echo ""
echo "🔐 Checking AWS credentials:"
if aws sts get-caller-identity &>/dev/null; then
    echo "✅ AWS credentials are configured"
    aws sts get-caller-identity
else
    echo "❌ AWS credentials are NOT configured or invalid"
fi

echo ""
echo "🌍 Checking AWS region:"
echo "Configured region: $REGION"
echo "AWS CLI default region: $(aws configure get region)"

echo ""
echo "📦 Checking Docker:"
if command -v docker &> /dev/null; then
    echo "✅ Docker is available"
    docker --version
else
    echo "❌ Docker is NOT available"
fi

echo ""
echo "🏗️ Checking if ECR repositories exist:"
REPOS=("$PROJECT_NAME-dotnet-api" "$PROJECT_NAME-nodejs-search")
for repo in "${REPOS[@]}"; do
    if aws ecr describe-repositories --repository-names "$repo" --region "$REGION" &>/dev/null; then
        echo "✅ ECR repository '$repo' exists"
    else
        echo "❌ ECR repository '$repo' does NOT exist"
    fi
done

echo ""
echo "☁️ Checking existing CloudFormation stacks:"
STACKS=("$PROJECT_NAME-infrastructure" "$PROJECT_NAME-services")
for stack in "${STACKS[@]}"; do
    STATUS=$(aws cloudformation describe-stacks --stack-name "$stack" --region "$REGION" --query 'Stacks[0].StackStatus' --output text 2>/dev/null || echo "NOT_FOUND")
    if [ "$STATUS" != "NOT_FOUND" ]; then
        echo "✅ Stack '$stack' exists with status: $STATUS"
    else
        echo "❌ Stack '$stack' does NOT exist"
    fi
done

echo ""
echo "🔍 Diagnosis complete!"
echo "======================"
