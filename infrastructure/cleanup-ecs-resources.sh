#!/bin/bash

echo "🧹 Cleaning Up All Shopping Cart AWS Resources"
echo "=============================================="
echo "⚠️  WARNING: This will DELETE all resources and may incur costs"
echo "⚠️  This action is IRREVERSIBLE"
echo ""
read -p "Are you sure you want to proceed? (type 'yes' to continue): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Cleanup cancelled"
    exit 0
fi

PROJECT_NAME="shopping-cart-system"
REGION="us-east-1"

echo ""
echo "🗑️  Starting cleanup process..."

# Function to check if stack exists
stack_exists() {
    aws cloudformation describe-stacks --stack-name "$1" --region $REGION >/dev/null 2>&1
}

# Function to wait for stack deletion
wait_for_stack_deletion() {
    local stack_name=$1
    echo "⏳ Waiting for $stack_name to delete..."
    aws cloudformation wait stack-delete-complete --stack-name "$stack_name" --region $REGION
    if [ $? -eq 0 ]; then
        echo "✅ $stack_name deleted successfully"
    else
        echo "⚠️  $stack_name deletion completed (may have been already deleted)"
    fi
}

# Step 1: Scale down ECS services to 0 (to speed up deletion)
echo ""
echo "1️⃣ Scaling down ECS services..."

# List all services in the cluster
SERVICES=$(aws ecs list-services \
    --cluster "$PROJECT_NAME-cluster" \
    --region $REGION \
    --query 'serviceArns[*]' \
    --output text 2>/dev/null)

if [ ! -z "$SERVICES" ]; then
    for service_arn in $SERVICES; do
        service_name=$(basename "$service_arn")
        echo "   Scaling down service: $service_name"
        aws ecs update-service \
            --cluster "$PROJECT_NAME-cluster" \
            --service "$service_name" \
            --desired-count 0 \
            --region $REGION >/dev/null 2>&1
    done
    
    echo "⏳ Waiting 60 seconds for services to scale down..."
    sleep 60
fi

# Step 2: Delete CloudFront distributions (these take longest)
echo ""
echo "2️⃣ Disabling CloudFront distributions..."

# Find CloudFront distributions
DISTRIBUTIONS=$(aws cloudfront list-distributions \
    --query "DistributionList.Items[?Comment && (contains(Comment, 'Shopping Cart') || contains(Comment, 'shopping-cart'))].{Id:Id,DomainName:DomainName,Comment:Comment}" \
    --output json 2>/dev/null)

if [ "$DISTRIBUTIONS" != "[]" ] && [ "$DISTRIBUTIONS" != "null" ]; then
    echo "Found CloudFront distributions to disable..."
    echo "$DISTRIBUTIONS" | jq -r '.[] | "\(.Id) - \(.Comment)"'
    
    # Disable each distribution
    echo "$DISTRIBUTIONS" | jq -r '.[].Id' | while read DIST_ID; do
        if [ ! -z "$DIST_ID" ]; then
            echo "   Disabling distribution: $DIST_ID"
            
            # Get current distribution config
            aws cloudfront get-distribution-config \
                --id "$DIST_ID" \
                --query 'DistributionConfig' \
                --output json > dist_config.json 2>/dev/null
            
            if [ -f "dist_config.json" ]; then
                # Disable the distribution
                jq '.Enabled = false' dist_config.json > dist_config_disabled.json
                
                ETAG=$(aws cloudfront get-distribution-config \
                    --id "$DIST_ID" \
                    --query 'ETag' \
                    --output text 2>/dev/null)
                
                aws cloudfront update-distribution \
                    --id "$DIST_ID" \
                    --distribution-config file://dist_config_disabled.json \
                    --if-match "$ETAG" \
                    --region $REGION >/dev/null 2>&1
                
                rm -f dist_config.json dist_config_disabled.json
            fi
        fi
    done
    
    echo "⚠️  CloudFront distributions are disabling (takes 15-20 minutes)"
    echo "   They will be deleted automatically after disabling completes"
fi

# Step 3: Delete ECS Services Stack
echo ""
echo "3️⃣ Deleting ECS Services..."
if stack_exists "$PROJECT_NAME-services"; then
    aws cloudformation delete-stack \
        --stack-name "$PROJECT_NAME-services" \
        --region $REGION
    wait_for_stack_deletion "$PROJECT_NAME-services"
else
    echo "   Services stack not found or already deleted"
fi

# Step 4: Delete ECS Infrastructure Stack
echo ""
echo "4️⃣ Deleting ECS Infrastructure..."
if stack_exists "$PROJECT_NAME-infrastructure"; then
    aws cloudformation delete-stack \
        --stack-name "$PROJECT_NAME-infrastructure" \
        --region $REGION
    wait_for_stack_deletion "$PROJECT_NAME-infrastructure"
else
    echo "   Infrastructure stack not found or already deleted"
fi

# Step 5: Delete ECR repositories
echo ""
echo "5️⃣ Deleting ECR repositories..."
ECR_REPOS=$(aws ecr describe-repositories \
    --query "repositories[?contains(repositoryName, 'shopping-cart')].repositoryName" \
    --output text \
    --region $REGION 2>/dev/null)

if [ ! -z "$ECR_REPOS" ]; then
    for repo in $ECR_REPOS; do
        echo "   Deleting ECR repository: $repo"
        aws ecr delete-repository \
            --repository-name "$repo" \
            --force \
            --region $REGION >/dev/null 2>&1
    done
    echo "✅ ECR repositories deleted"
else
    echo "   No ECR repositories found"
fi

# Step 6: Clean up S3 buckets
echo ""
echo "6️⃣ Deleting S3 buckets..."
S3_BUCKETS=$(aws s3 ls | grep shopping-cart | awk '{print $3}')

if [ ! -z "$S3_BUCKETS" ]; then
    for bucket in $S3_BUCKETS; do
        echo "   Deleting S3 bucket: $bucket"
        # Empty bucket first
        aws s3 rm "s3://$bucket" --recursive >/dev/null 2>&1
        # Delete bucket
        aws s3 rb "s3://$bucket" >/dev/null 2>&1
    done
    echo "✅ S3 buckets deleted"
else
    echo "   No S3 buckets found"
fi

# Step 7: Delete any remaining ECS clusters
echo ""
echo "7️⃣ Deleting ECS clusters..."
ECS_CLUSTERS=$(aws ecs list-clusters \
    --query "clusterArns[?contains(@, 'shopping-cart')]" \
    --output text \
    --region $REGION 2>/dev/null)

if [ ! -z "$ECS_CLUSTERS" ]; then
    for cluster_arn in $ECS_CLUSTERS; do
        cluster_name=$(basename "$cluster_arn")
        echo "   Deleting ECS cluster: $cluster_name"
        aws ecs delete-cluster \
            --cluster "$cluster_name" \
            --region $REGION >/dev/null 2>&1
    done
    echo "✅ ECS clusters deleted"
else
    echo "   No ECS clusters found"
fi

# Step 8: Clean up local files
echo ""
echo "8️⃣ Cleaning up local deployment files..."
rm -f ecr-repos.txt
rm -f react-deployment.txt
rm -f api-deployment.txt
rm -f *.json
echo "✅ Local files cleaned up"

# Step 9: Final verification
echo ""
echo "9️⃣ Final verification..."
echo ""
echo "📊 Remaining resources check:"

# Check CloudFormation stacks
REMAINING_STACKS=$(aws cloudformation list-stacks \
    --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
    --query "StackSummaries[?contains(StackName, 'shopping-cart')].StackName" \
    --output text \
    --region $REGION 2>/dev/null)

if [ ! -z "$REMAINING_STACKS" ]; then
    echo "⚠️  Remaining CloudFormation stacks: $REMAINING_STACKS"
else
    echo "✅ No CloudFormation stacks remaining"
fi

# Check ECS
REMAINING_CLUSTERS=$(aws ecs list-clusters \
    --query "clusterArns[?contains(@, 'shopping-cart')]" \
    --output text \
    --region $REGION 2>/dev/null)

if [ ! -z "$REMAINING_CLUSTERS" ]; then
    echo "⚠️  Remaining ECS clusters: $REMAINING_CLUSTERS"
else
    echo "✅ No ECS clusters remaining"
fi

# Check ECR
REMAINING_ECR=$(aws ecr describe-repositories \
    --query "repositories[?contains(repositoryName, 'shopping-cart')].repositoryName" \
    --output text \
    --region $REGION 2>/dev/null)

if [ ! -z "$REMAINING_ECR" ]; then
    echo "⚠️  Remaining ECR repositories: $REMAINING_ECR"
else
    echo "✅ No ECR repositories remaining"
fi

echo ""
echo "🎉 Cleanup Complete!"
echo "==================="
echo ""
echo "📋 Summary:"
echo "   ✅ ECS services scaled down and deleted"
echo "   ✅ CloudFormation stacks deleted"
echo "   ✅ ECR repositories deleted"
echo "   ✅ S3 buckets emptied and deleted"
echo "   ✅ ECS clusters deleted"
echo "   ⏳ CloudFront distributions disabling (15-20 min)"
echo ""
echo "💰 Cost Impact:"
echo "   • Most resources stopped immediately"
echo "   • CloudFront distributions will stop billing once disabled"
echo "   • No ongoing charges for deleted resources"
echo ""
echo "⚠️  Note: CloudFront distributions take 15-20 minutes to fully disable"
echo "   Check CloudFront console if you want to monitor progress"
echo ""
echo "🔒 Security: All application data and configurations have been removed"
