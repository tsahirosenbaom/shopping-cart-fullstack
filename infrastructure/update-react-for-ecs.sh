#!/bin/bash

echo "🔗 Updating React App for ECS Backend"
echo "====================================="

PROJECT_NAME="shopping-cart-system"
REGION="us-east-1"

# Get ALB DNS name
ALB_DNS_NAME=$(aws cloudformation describe-stacks \
    --stack-name "$PROJECT_NAME-infrastructure" \
    --query 'Stacks[0].Outputs[?OutputKey==`ALBDNSName`].OutputValue' \
    --output text \
    --region $REGION)

if [ -z "$ALB_DNS_NAME" ]; then
    echo "❌ Could not get ALB DNS name"
    exit 1
fi

echo "✅ Using ALB DNS: $ALB_DNS_NAME"

# Navigate to frontend
cd ../frontend

# Update environment configuration
echo "📝 Updating React environment configuration..."

cat > .env.production << EOF
REACT_APP_API_BASE_URL=http://$ALB_DNS_NAME
REACT_APP_ORDERS_API_BASE_URL=http://$ALB_DNS_NAME
EOF

echo "✅ Created .env.production:"
cat .env.production

# Also create .env.local for immediate testing
cp .env.production .env.local

# Rebuild React app
echo ""
echo "🏗️ Rebuilding React app with ECS backend..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ React build successful!"
    
    # Get React deployment info from previous deployment
    cd ../infrastructure
    if [ -f "react-deployment.txt" ]; then
        source react-deployment.txt
        echo "✅ Found existing React deployment:"
        echo "   S3 Bucket: $BUCKET_NAME"
        echo "   CloudFront Domain: $CLOUDFRONT_DOMAIN"
        
        # Redeploy to S3
        echo "📤 Updating S3 deployment..."
        cd ../frontend
        aws s3 sync build/ "s3://$BUCKET_NAME" --delete
        
        # Invalidate CloudFront cache
        if [ -n "$DISTRIBUTION_ID" ]; then
            echo "🌐 Creating CloudFront invalidation..."
            INVALIDATION_ID=$(aws cloudfront create-invalidation \
                --distribution-id "$DISTRIBUTION_ID" \
                --paths "/*" \
                --query 'Invalidation.Id' \
                --output text)
            echo "✅ CloudFront invalidation created: $INVALIDATION_ID"
        fi
        
        echo ""
        echo "🎉 React app updated!"
        echo "==================="
        echo "🌐 React App: https://$CLOUDFRONT_DOMAIN"
        echo "🔗 API Backend: http://$ALB_DNS_NAME"
        echo ""
        echo "⏱️ CloudFront changes will be live in 5-10 minutes"
        echo "🧪 Test the app to see if the Hebrew error is gone!"
        
    else
        echo "⚠️ React deployment info not found. Need to deploy React app first."
        echo "💡 Run: ./deploy-react.sh"
    fi
    
else
    echo "❌ React build failed"
    exit 1
fi
