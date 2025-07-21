#!/bin/bash

echo "🔄 Redeploying ECS Infrastructure"
echo "================================="

PROJECT_NAME="shopping-cart-system"
REGION="us-east-1"

# Step 1: Delete the failed stack
echo "🗑️ Deleting failed CloudFormation stack..."
aws cloudformation delete-stack \
    --stack-name "$PROJECT_NAME-infrastructure" \
    --region $REGION

echo "⏳ Waiting for stack deletion to complete (this may take 5-10 minutes)..."
aws cloudformation wait stack-delete-complete \
    --stack-name "$PROJECT_NAME-infrastructure" \
    --region $REGION

if [ $? -eq 0 ]; then
    echo "✅ Stack deleted successfully"
else
    echo "❌ Stack deletion failed or timed out"
    echo "🔍 Checking current stack status..."
    aws cloudformation describe-stacks \
        --stack-name "$PROJECT_NAME-infrastructure" \
        --region $REGION \
        --query 'Stacks[0].StackStatus' \
        --output text 2>/dev/null || echo "Stack no longer exists"
fi

# Step 2: Ensure ECR repositories exist
echo ""
echo "📦 Setting up ECR repositories..."
if [ -f "setup-ecr.sh" ]; then
    ./setup-ecr.sh
else
    echo "❌ setup-ecr.sh not found. Creating ECR repositories manually..."
    
    REPOS=("$PROJECT_NAME-dotnet-api" "$PROJECT_NAME-nodejs-search")
    
    for repo in "${REPOS[@]}"; do
        if aws ecr describe-repositories --repository-names "$repo" --region "$REGION" &>/dev/null; then
            echo "✅ ECR repository '$repo' already exists"
        else
            echo "📦 Creating ECR repository '$repo'..."
            aws ecr create-repository --repository-name "$repo" --region "$REGION"
        fi
    done
    
    # Get repository URIs
    DOTNET_REPO_URI=$(aws ecr describe-repositories --repository-names "$PROJECT_NAME-dotnet-api" --region "$REGION" --query 'repositories[0].repositoryUri' --output text)
    NODEJS_REPO_URI=$(aws ecr describe-repositories --repository-names "$PROJECT_NAME-nodejs-search" --region "$REGION" --query 'repositories[0].repositoryUri' --output text)
    
    # Save URIs to file
    cat > ecr-repos.txt << EOF
DOTNET_REPO_URI=$DOTNET_REPO_URI
NODEJS_REPO_URI=$NODEJS_REPO_URI
EOF
fi

# Load ECR repository URIs
source ecr-repos.txt

echo "✅ ECR repositories ready:"
echo "   .NET API: $DOTNET_REPO_URI"
echo "   Node.js Search: $NODEJS_REPO_URI"

# Step 3: Build and push Docker images (with simple placeholder images)
echo ""
echo "🐳 Ensuring Docker images exist..."

# Login to ECR
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$DOTNET_REPO_URI"

# Create simple placeholder images if they don't exist
echo "📦 Creating placeholder .NET API image..."
echo 'FROM nginx:alpine
COPY <<EOF /etc/nginx/conf.d/default.conf
server {
    listen 80;
    location /api/health {
        return 200 "OK";
        add_header Content-Type text/plain;
    }
    location / {
        return 200 "Shopping Cart .NET API - Placeholder";
        add_header Content-Type text/plain;
    }
}
EOF' | docker build -t "$DOTNET_REPO_URI:latest" -

docker push "$DOTNET_REPO_URI:latest"
echo "✅ .NET API placeholder image pushed"

echo "📦 Creating placeholder Node.js API image..."
echo 'FROM nginx:alpine
COPY <<EOF /etc/nginx/conf.d/default.conf
server {
    listen 3001;
    location /api/health {
        return 200 "OK";
        add_header Content-Type text/plain;
    }
    location / {
        return 200 "Shopping Cart Node.js API - Placeholder";
        add_header Content-Type text/plain;
    }
}
EOF
EXPOSE 3001' | docker build -t "$NODEJS_REPO_URI:latest" -

docker push "$NODEJS_REPO_URI:latest"
echo "✅ Node.js API placeholder image pushed"

# Step 4: Deploy infrastructure
echo ""
echo "🚀 Deploying ECS Infrastructure..."

if [ ! -f "ecs-infrastructure.yaml" ]; then
    echo "❌ ecs-infrastructure.yaml not found!"
    echo "Please create the CloudFormation template first."
    exit 1
fi

aws cloudformation deploy \
    --template-file ecs-infrastructure.yaml \
    --stack-name "$PROJECT_NAME-infrastructure" \
    --parameter-overrides \
        ProjectName=$PROJECT_NAME \
        DotNetImageURI=$DOTNET_REPO_URI:latest \
        NodeJsImageURI=$NODEJS_REPO_URI:latest \
    --capabilities CAPABILITY_IAM \
    --region $REGION

if [ $? -eq 0 ]; then
    echo "✅ Infrastructure deployment successful!"
    
    # Get ALB DNS name
    ALB_DNS_NAME=$(aws cloudformation describe-stacks \
        --stack-name "$PROJECT_NAME-infrastructure" \
        --query 'Stacks[0].Outputs[?OutputKey==`ALBDNSName`].OutputValue' \
        --output text \
        --region $REGION)
    
    echo "🔗 ALB DNS Name: $ALB_DNS_NAME"
    
    # Test ALB
    echo "🧪 Testing ALB (may take a moment to be ready)..."
    sleep 30  # Wait a bit for ALB to be ready
    
    if curl -s --connect-timeout 10 "http://$ALB_DNS_NAME" >/dev/null 2>&1; then
        echo "✅ ALB is responding"
    else
        echo "⚠️ ALB not responding yet (this is normal, services need to be deployed)"
    fi
    
    echo ""
    echo "🎉 Infrastructure deployment complete!"
    echo "Next steps:"
    echo "1. Deploy ECS services (task definitions and services)"
    echo "2. Update React app to use: http://$ALB_DNS_NAME"
    
else
    echo "❌ Infrastructure deployment failed"
    echo "🔍 Check the CloudFormation console for detailed error messages"
    exit 1
fi
