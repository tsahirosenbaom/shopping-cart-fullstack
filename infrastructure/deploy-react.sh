#!/bin/bash

echo "⚛️ Deploying React App to S3 + CloudFront..."

PROJECT_NAME="shopping-cart-system"
REGION="us-east-1"

# Get ALB DNS name from CloudFormation outputs
ALB_DNS_NAME=$(aws cloudformation describe-stacks \
    --stack-name "$PROJECT_NAME-infrastructure" \
    --query 'Stacks[0].Outputs[?OutputKey==`ALBDNSName`].OutputValue' \
    --output text \
    --region $REGION)

if [ -z "$ALB_DNS_NAME" ]; then
    echo "❌ Could not get ALB DNS name. Make sure infrastructure is deployed."
    exit 1
fi

echo "🔗 Using ALB DNS: $ALB_DNS_NAME"

# Update React app API URLs
cd ~/shopping-cart-app

# Create production environment file
cat > .env.production << ENVEOF
REACT_APP_API_BASE_URL=http://$ALB_DNS_NAME
REACT_APP_ORDERS_API_BASE_URL=http://$ALB_DNS_NAME
ENVEOF

# Update API services to use environment variables
cat > src/services/api.ts << 'APIEOF'
import axios from 'axios';
import { Category, Product, CreateProductRequest, Order, CreateOrderRequest } from '../types';

const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || 'http://localhost:5002/api';
const ORDERS_API_BASE_URL = process.env.REACT_APP_ORDERS_API_BASE_URL || 'http://localhost:3000/api';

// Category API
export const categoryAPI = {
  getAll: async (): Promise<Category[]> => {
    const response = await axios.get(`${API_BASE_URL}/api/categories`);
    return response.data;
  },
};

// Product API  
export const productAPI = {
  getAll: async (): Promise<Product[]> => {
    const response = await axios.get(`${API_BASE_URL}/api/products`);
    return response.data;
  },

  create: async (product: CreateProductRequest): Promise<Product> => {
    const response = await axios.post(`${API_BASE_URL}/api/products`, product);
    return response.data;
  },

  search: async (query: string): Promise<Product[]> => {
    const response = await axios.get(`${API_BASE_URL}/api/products/search?query=${query}`);
    return response.data;
  }
};

// Order API
export const orderAPI = {
  create: async (order: CreateOrderRequest): Promise<Order> => {
    const response = await axios.post(`${ORDERS_API_BASE_URL}/api/orders`, order);
    return response.data;
  },

  getAll: async (): Promise<Order[]> => {
    const response = await axios.get(`${ORDERS_API_BASE_URL}/api/orders`);
    return response.data;
  },

  getById: async (id: string): Promise<Order> => {
    const response = await axios.get(`${ORDERS_API_BASE_URL}/api/orders/${id}`);
    return response.data;
  }
};
APIEOF

# Build React app for production
echo "🏗️ Building React app..."
npm run build

# Create S3 bucket for static hosting
BUCKET_NAME="$PROJECT_NAME-frontend-$(date +%s)"
aws s3 mb "s3://$BUCKET_NAME" --region $REGION

# Configure bucket for static website hosting
aws s3 website "s3://$BUCKET_NAME" \
    --index-document index.html \
    --error-document index.html

# Create bucket policy for public read access
cat > bucket-policy.json << POLICYEOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
        }
    ]
}
POLICYEOF

aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy file://bucket-policy.json

# Upload build files to S3
echo "📤 Uploading React app to S3..."
aws s3 sync build/ "s3://$BUCKET_NAME" --delete

# Create CloudFront distribution
echo "🌐 Creating CloudFront distribution..."
cat > cloudfront-config.json << CFEOF
{
    "CallerReference": "$PROJECT_NAME-$(date +%s)",
    "Comment": "CloudFront distribution for Shopping Cart React app",
    "DefaultRootObject": "index.html",
    "Origins": {
        "Quantity": 1,
        "Items": [
            {
                "Id": "S3-$BUCKET_NAME",
                "DomainName": "$BUCKET_NAME.s3-website-$REGION.amazonaws.com",
                "CustomOriginConfig": {
                    "HTTPPort": 80,
                    "HTTPSPort": 443,
                    "OriginProtocolPolicy": "http-only"
                }
            }
        ]
    },
    "DefaultCacheBehavior": {
        "TargetOriginId": "S3-$BUCKET_NAME",
        "ViewerProtocolPolicy": "redirect-to-https",
        "MinTTL": 0,
        "ForwardedValues": {
            "QueryString": false,
            "Cookies": {"Forward": "none"}
        },
        "Compress": true
    },
    "CustomErrorResponses": {
        "Quantity": 1,
        "Items": [
            {
                "ErrorCode": 404,
                "ResponsePagePath": "/index.html",
                "ResponseCode": "200",
                "ErrorCachingMinTTL": 300
            }
        ]
    },
    "Enabled": true,
    "PriceClass": "PriceClass_100"
}
CFEOF

DISTRIBUTION_ID=$(aws cloudfront create-distribution \
    --distribution-config file://cloudfront-config.json \
    --query 'Distribution.Id' \
    --output text)

echo "✅ CloudFront distribution created: $DISTRIBUTION_ID"

# Get CloudFront domain name
CLOUDFRONT_DOMAIN=$(aws cloudfront get-distribution \
    --id $DISTRIBUTION_ID \
    --query 'Distribution.DomainName' \
    --output text)

echo ""
echo "🎉 React app deployment complete!"
echo "================================="
echo "S3 Bucket: $BUCKET_NAME"
echo "CloudFront Distribution: $DISTRIBUTION_ID"
echo "React App URL: https://$CLOUDFRONT_DOMAIN"
echo ""
echo "⚠️  Note: CloudFront distribution takes 15-20 minutes to deploy globally"
echo "You can check status with: aws cloudfront get-distribution --id $DISTRIBUTION_ID"

# Save deployment info
cat > react-deployment.txt << DEPLOYEOF
BUCKET_NAME=$BUCKET_NAME
DISTRIBUTION_ID=$DISTRIBUTION_ID
CLOUDFRONT_DOMAIN=$CLOUDFRONT_DOMAIN
ALB_DNS_NAME=$ALB_DNS_NAME
DEPLOYEOF

echo "📝 Deployment info saved to react-deployment.txt"
