#!/bin/bash

echo "🚀 Shopping Cart Deployment Strategy Setup"
echo "=========================================="
echo ""
echo "Choose your deployment strategy:"
echo "1) Serverless (AWS Lambda) - $1-5/month, pay per use"
echo "2) ECS Fargate - $30-35/month, always available"
echo "3) Both (for comparison)"
echo ""

read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        echo "📦 Setting up Serverless deployment..."
        if [ -f ".github/workflows/deploy-serverless.yml.example" ]; then
            cp .github/workflows/deploy-serverless.yml.example .github/workflows/deploy-serverless.yml
            echo "✅ Serverless workflow enabled"
        else
            echo "❌ Serverless workflow template not found"
        fi
        ;;
    2)
        echo "🐳 Setting up ECS deployment..."
        if [ -f ".github/workflows/deploy-ecs.yml.example" ]; then
            cp .github/workflows/deploy-ecs.yml.example .github/workflows/deploy-ecs.yml
            echo "✅ ECS workflow enabled"
        else
            echo "❌ ECS workflow template not found"
        fi
        ;;
    3)
        echo "🔄 Setting up both deployments..."
        cp .github/workflows/deploy-serverless.yml.example .github/workflows/deploy-serverless.yml 2>/dev/null
        cp .github/workflows/deploy-ecs.yml.example .github/workflows/deploy-ecs.yml 2>/dev/null
        echo "✅ Both workflows enabled"
        echo "⚠️ Note: This will create resources for both - monitor costs!"
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "📋 Next steps:"
echo "1. Set up AWS credentials in GitHub Secrets:"
echo "   - AWS_ACCESS_KEY_ID"
echo "   - AWS_SECRET_ACCESS_KEY"
echo "2. Commit and push:"
echo "   git add ."
echo "   git commit -m 'Enable deployment'"
echo "   git push origin main"
echo "3. Monitor deployment in GitHub Actions tab"
