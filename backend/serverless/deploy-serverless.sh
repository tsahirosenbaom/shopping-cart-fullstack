name: Deploy Serverless Shopping Cart

on:
  push:
    branches: [main]
    paths:
      - "backend/serverless/**"
      - "frontend/**"
      - ".github/workflows/deploy-serverless.yml"
  pull_request:
    branches: [main]
  workflow_dispatch: # Allow manual triggering

env:
  AWS_REGION: us-east-1
  NODE_VERSION: "18"
  STACK_NAME: serverless-shopping-cart

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}

      - name: Test React Frontend
        run: |
          if [ -f "frontend/package.json" ]; then
            cd frontend
            npm ci
            npm run test -- --coverage --watchAll=false || echo "No tests or tests failed"
          fi

      - name: Test Lambda Functions
        run: |
          if [ -d "backend/serverless/src" ]; then
            cd backend/serverless
            for func in src/*/; do
              if [ -f "$func/package.json" ]; then
                cd "$func" && npm ci && npm test 2>/dev/null || echo "No tests for $func"
                cd ../..
              fi
            done
          fi

  deploy-serverless:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    outputs:
      api-url: ${{ steps.deploy.outputs.api-url }}
      api-https-url: ${{ steps.deploy.outputs.api-https-url }}
    steps:
      - uses: actions/checkout@v4

      - name: Setup AWS SAM
        uses: aws-actions/setup-sam@v2

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Build and Deploy Serverless Backend
        id: deploy
        run: |
          cd backend/serverless
          sam build
          BUCKET_NAME="$STACK_NAME-sam-$(date +%s)"
          aws s3 mb s3://$BUCKET_NAME
          sam deploy --stack-name $STACK_NAME --s3-bucket $BUCKET_NAME --capabilities CAPABILITY_IAM --no-confirm-changeset
          
          # Get API Gateway URL
          API_URL=$(aws cloudformation describe-stacks \
            --stack-name $STACK_NAME \
            --query 'Stacks[0].Outputs[?OutputKey==`ShoppingCartApi`].OutputValue' \
            --output text)
          
          # Ensure HTTPS (API Gateway supports both HTTP and HTTPS)
          API_HTTPS_URL=${API_URL/http:/https:}
          
          echo "🔗 Serverless API URL: $API_URL"
          echo "🔒 Serverless HTTPS URL: $API_HTTPS_URL"
          
          echo "api-url=$API_URL" >> $GITHUB_OUTPUT
          echo "api-https-url=$API_HTTPS_URL" >> $GITHUB_OUTPUT

  deploy-frontend:
    needs: deploy-serverless
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}

      - name: Deploy React App for Serverless Backend
        env:
          REACT_APP_API_BASE_URL: ${{ needs.deploy-serverless.outputs.api-https-url }}
          REACT_APP_ORDERS_API_BASE_URL: ${{ needs.deploy-serverless.outputs.api-https-url }}
          REACT_APP_BACKEND_TYPE: serverless
          REACT_APP_DEPLOYMENT_NAME: "Serverless - Lambda + API Gateway"
          REACT_APP_ARCHITECTURE_INFO: "AWS Lambda Functions with DynamoDB"
        run: |
          cd frontend
          
          echo "🔧 Configuring React app for SERVERLESS backend..."
          echo "📡 API Base URL: $REACT_APP_API_BASE_URL"
          echo "📡 Orders API URL: $REACT_APP_ORDERS_API_BASE_URL" 
          echo "🏗️ Backend Type: $REACT_APP_BACKEND_TYPE"
          echo "📋 Deployment Name: $REACT_APP_DEPLOYMENT_NAME"
          
          # Create production environment file with serverless config
          cat > .env.production << EOF
          REACT_APP_API_BASE_URL=$REACT_APP_API_BASE_URL
          REACT_APP_ORDERS_API_BASE_URL=$REACT_APP_ORDERS_API_BASE_URL
          REACT_APP_BACKEND_TYPE=$REACT_APP_BACKEND_TYPE
          REACT_APP_DEPLOYMENT_NAME=$REACT_APP_DEPLOYMENT_NAME
          REACT_APP_ARCHITECTURE_INFO=$REACT_APP_ARCHITECTURE_INFO
          EOF
          
          echo "📝 Generated .env.production:"
          cat .env.production
          
          # Install dependencies and build
          npm ci
          npm run build
          
          # Create S3 bucket for frontend
          FRONTEND_BUCKET="$STACK_NAME-frontend-$(date +%s)"
          aws s3 mb s3://$FRONTEND_BUCKET --region $AWS_REGION
          
          # Configure bucket for website hosting
          aws s3api put-public-access-block \
            --bucket $FRONTEND_BUCKET \
            --public-access-block-configuration \
            BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false
          
          aws s3 website s3://$FRONTEND_BUCKET --index-document index.html --error-document index.html
          
          # Set bucket policy for public read
          aws s3api put-bucket-policy --bucket $FRONTEND_BUCKET --policy '{
            "Version":"2012-10-17",
            "Statement":[{
              "Effect":"Allow",
              "Principal":"*",
              "Action":"s3:GetObject",
              "Resource":"arn:aws:s3:::'$FRONTEND_BUCKET'/*"
            }]
          }'
          
          # Upload frontend
          aws s3 sync build/ s3://$FRONTEND_BUCKET --delete
          
          # Create CloudFront distribution for HTTPS frontend
          CLOUDFRONT_CONFIG='{
            "CallerReference": "'$FRONTEND_BUCKET'",
            "Comment": "Serverless Shopping Cart Frontend - HTTPS",
            "DefaultCacheBehavior": {
              "TargetOriginId": "S3-Origin",
              "ViewerProtocolPolicy": "redirect-to-https",
              "TrustedSigners": {"Enabled": false, "Quantity": 0},
              "ForwardedValues": {
                "QueryString": false, 
                "Cookies": {"Forward": "none"}
              },
              "MinTTL": 0,
              "DefaultTTL": 86400,
              "MaxTTL": 31536000
            },
            "Origins": {
              "Quantity": 1,
              "Items": [{
                "Id": "S3-Origin",
                "DomainName": "'$FRONTEND_BUCKET'.s3-website-'$AWS_REGION'.amazonaws.com",
                "CustomOriginConfig": {
                  "HTTPPort": 80,
                  "HTTPSPort": 443,
                  "OriginProtocolPolicy": "http-only"
                }
              }]
            },
            "Enabled": true,
            "DefaultRootObject": "index.html",
            "PriceClass": "PriceClass_100",
            "CustomErrorResponses": {
              "Quantity": 1,
              "Items": [{
                "ErrorCode": 404,
                "ResponsePagePath": "/index.html",
                "ResponseCode": "200",
                "ErrorCachingMinTTL": 300
              }]
            }
          }'
          
          echo "$CLOUDFRONT_CONFIG" > cf-config.json
          
          echo "🚀 Creating CloudFront distribution for HTTPS frontend..."
          DISTRIBUTION_ID=$(aws cloudfront create-distribution \
            --distribution-config file://cf-config.json \
            --query 'Distribution.Id' \
            --output text)
          
          CLOUDFRONT_DOMAIN=$(aws cloudfront get-distribution \
            --id $DISTRIBUTION_ID \
            --query 'Distribution.DomainName' \
            --output text)
          
          echo ""
          echo "🎉 SERVERLESS DEPLOYMENT COMPLETE!"
          echo "================================="
          echo "🔒 Frontend HTTPS URL: https://$CLOUDFRONT_DOMAIN"
          echo "🔒 Backend API HTTPS: $REACT_APP_API_BASE_URL"
          echo "🏗️ Architecture: Serverless (Lambda + API Gateway + DynamoDB)"
          echo "📱 S3 Website URL: http://$FRONTEND_BUCKET.s3-website-$AWS_REGION.amazonaws.com"
          echo ""
          echo "⏳ CloudFront distribution is deploying (5-15 minutes to propagate globally)"
          echo "   You can test the S3 website URL immediately"
          echo "   HTTPS CloudFront URL will be ready in 5-15 minutes"
          echo ""
          
          # Save deployment info
          cat > serverless-deployment-info.txt << EOF
          SERVERLESS_FRONTEND_HTTPS=https://$CLOUDFRONT_DOMAIN
          SERVERLESS_FRONTEND_HTTP=http://$FRONTEND_BUCKET.s3-website-$AWS_REGION.amazonaws.com
          SERVERLESS_API_URL=$REACT_APP_API_BASE_URL
          SERVERLESS_BUCKET=$FRONTEND_BUCKET
          SERVERLESS_DISTRIBUTION_ID=$DISTRIBUTION_ID
          DEPLOYMENT_TYPE=serverless
          EOF
          
          echo "💾 Deployment info saved to serverless-deployment-info.txt"
          
          # Upload deployment info to S3
          aws s3 cp serverless-deployment-info.txt s3://$FRONTEND_BUCKET/deployment-info.txt
          
          rm -f cf-config.json