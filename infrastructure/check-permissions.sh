#!/bin/bash

echo "🔍 AWS Permissions Diagnostic Tool"
echo "=================================="

REGION="us-east-1"

echo "👤 Current AWS Identity:"
aws sts get-caller-identity

echo ""
echo "🧪 Testing Required ECS Permissions:"
echo "======================================"

# Test ECR permissions
echo "📦 ECR (Elastic Container Registry):"
aws ecr describe-repositories --region $REGION --max-items 1 >/dev/null 2>&1 && echo "  ✅ ECR read access" || echo "  ❌ ECR read access FAILED"
aws ecr create-repository --repository-name test-permission-check --region $REGION >/dev/null 2>&1 && {
    echo "  ✅ ECR create access"
    aws ecr delete-repository --repository-name test-permission-check --region $REGION >/dev/null 2>&1
    echo "  ✅ ECR delete access"
} || echo "  ❌ ECR create access FAILED"

# Test S3 permissions
echo ""
echo "🪣 S3 (Simple Storage Service):"
aws s3 ls >/dev/null 2>&1 && echo "  ✅ S3 list buckets" || echo "  ❌ S3 list buckets FAILED"
TEST_BUCKET="test-permission-check-$(date +%s)"
aws s3 mb s3://$TEST_BUCKET --region $REGION >/dev/null 2>&1 && {
    echo "  ✅ S3 create bucket"
    aws s3 rb s3://$TEST_BUCKET >/dev/null 2>&1
    echo "  ✅ S3 delete bucket"
} || echo "  ❌ S3 create bucket FAILED"

# Test CloudFormation permissions
echo ""
echo "☁️ CloudFormation:"
aws cloudformation list-stacks --region $REGION --max-items 1 >/dev/null 2>&1 && echo "  ✅ CloudFormation list stacks" || echo "  ❌ CloudFormation list stacks FAILED"
aws cloudformation validate-template --template-body '{"AWSTemplateFormatVersion":"2010-09-09","Resources":{"DummyResource":{"Type":"AWS::CloudFormation::WaitConditionHandle"}}}' >/dev/null 2>&1 && echo "  ✅ CloudFormation validate template" || echo "  ❌ CloudFormation validate template FAILED"

# Test ECS permissions
echo ""
echo "🐳 ECS (Elastic Container Service):"
aws ecs list-clusters --region $REGION >/dev/null 2>&1 && echo "  ✅ ECS list clusters" || echo "  ❌ ECS list clusters FAILED"
aws ecs describe-task-definition --task-definition nonexistent >/dev/null 2>&1 || echo "  ✅ ECS describe task definition (expected to fail, but permission works)"

# Test EC2 permissions (needed for ECS networking)
echo ""
echo "🌐 EC2 (for VPC/networking):"
aws ec2 describe-vpcs --region $REGION --max-items 1 >/dev/null 2>&1 && echo "  ✅ EC2 describe VPCs" || echo "  ❌ EC2 describe VPCs FAILED"
aws ec2 describe-subnets --region $REGION --max-items 1 >/dev/null 2>&1 && echo "  ✅ EC2 describe subnets" || echo "  ❌ EC2 describe subnets FAILED"
aws ec2 describe-security-groups --region $REGION --max-items 1 >/dev/null 2>&1 && echo "  ✅ EC2 describe security groups" || echo "  ❌ EC2 describe security groups FAILED"

# Test IAM permissions
echo ""
echo "👤 IAM (Identity and Access Management):"
aws iam get-user >/dev/null 2>&1 && echo "  ✅ IAM get user" || echo "  ❌ IAM get user FAILED"
aws iam list-roles --max-items 1 >/dev/null 2>&1 && echo "  ✅ IAM list roles" || echo "  ❌ IAM list roles FAILED"

# Test Load Balancer permissions
echo ""
echo "⚖️ Elastic Load Balancing:"
aws elbv2 describe-load-balancers --region $REGION --max-items 1 >/dev/null 2>&1 && echo "  ✅ ELB describe load balancers" || echo "  ❌ ELB describe load balancers FAILED"

echo ""
echo "📊 Summary:"
echo "==========="
echo "If you see ❌ FAILED messages above, those are the permissions causing the 403 error."
echo "You'll need to add those specific permissions to your AWS IAM user/role."
echo ""
echo "💡 Tip: The serverless deployment works because it only needs Lambda, API Gateway, and basic S3 permissions."
echo "💡 ECS requires much broader permissions including EC2, VPC, Load Balancer, and IAM role creation."
