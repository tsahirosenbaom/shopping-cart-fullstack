#!/bin/bash

REGION="us-west-2"

echo "Starting cleanup in region $REGION"

# Terminate EC2 instances
echo "Checking EC2 instances..."
EC2_INSTANCES=$(aws ec2 describe-instances --region $REGION --query "Reservations[].Instances[?State.Name!='terminated'].InstanceId" --output text)

if [ -z "$EC2_INSTANCES" ]; then
  echo "No EC2 instances to terminate."
else
  echo "Terminating EC2 instances: $EC2_INSTANCES"
  aws ec2 terminate-instances --region $REGION --instance-ids $EC2_INSTANCES
fi

# Terminate Elastic Beanstalk environments & delete applications
echo "Checking Elastic Beanstalk environments..."
EB_ENVS=$(aws elasticbeanstalk describe-environments --region $REGION --query "Environments[?Status=='Ready'].[EnvironmentName,ApplicationName]" --output text)

if [ -z "$EB_ENVS" ]; then
  echo "No Elastic Beanstalk environments found."
else
  # EB_ENVS is a multi-line list: envName applicationName
  echo "$EB_ENVS" | while read ENV APP; do
    echo "Terminating EB environment: $ENV"
    aws elasticbeanstalk terminate-environment --region $REGION --environment-name "$ENV"
  done

  echo "Waiting 2 minutes for environments to terminate..."
  sleep 120

  # Get unique application names
  EB_APPS=$(echo "$EB_ENVS" | awk '{print $2}' | sort | uniq)

  for APP in $EB_APPS; do
    echo "Deleting EB application: $APP"
    aws elasticbeanstalk delete-application --region $REGION --application-name "$APP" --terminate-env-by-force
  done
fi

# Delete S3 buckets in us-west-2
echo "Checking S3 buckets in $REGION..."
BUCKETS=$(aws s3api list-buckets --query "Buckets[].Name" --output text)
for BUCKET in $BUCKETS; do
  LOC=$(aws s3api get-bucket-location --bucket "$BUCKET" --query "LocationConstraint" --output text)
  # LocationConstraint can be null for us-east-1, so check explicitly
  if [[ "$LOC" == "$REGION" ]]; then
    echo "Deleting contents of bucket: $BUCKET"
    aws s3 rm "s3://$BUCKET" --recursive
    echo "Deleting bucket: $BUCKET"
    aws s3api delete-bucket --bucket "$BUCKET" --region $REGION
  fi
done

# Delete CloudFormation stacks
echo "Checking CloudFormation stacks..."
CFN_STACKS=$(aws cloudformation describe-stacks --region $REGION --query "Stacks[].StackName" --output text)
if [ -z "$CFN_STACKS" ]; then
  echo "No CloudFormation stacks found."
else
  for STACK in $CFN_STACKS; do
    echo "Deleting CloudFormation stack: $STACK"
    aws cloudformation delete-stack --region $REGION --stack-name "$STACK"
  done
fi

# Delete ECS clusters and services
echo "Checking ECS clusters..."
ECS_CLUSTERS=$(aws ecs list-clusters --region $REGION --query "clusterArns[]" --output text)
if [ -z "$ECS_CLUSTERS" ]; then
  echo "No ECS clusters found."
else
  for CLUSTER_ARN in $ECS_CLUSTERS; do
    CLUSTER_NAME=$(basename $CLUSTER_ARN)
    echo "Deleting services in ECS cluster: $CLUSTER_NAME"

    SERVICES=$(aws ecs list-services --cluster "$CLUSTER_NAME" --region $REGION --query "serviceArns[]" --output text)
    if [ ! -z "$SERVICES" ]; then
      for SERVICE_ARN in $SERVICES; do
        SERVICE_NAME=$(basename $SERVICE_ARN)
        echo "Deleting ECS service: $SERVICE_NAME"
        aws ecs delete-service --cluster "$CLUSTER_NAME" --service "$SERVICE_NAME" --region $REGION --force
      done
    fi

    echo "Deleting ECS cluster: $CLUSTER_NAME"
    aws ecs delete-cluster --cluster "$CLUSTER_NAME" --region $REGION
  done
fi

# Delete Lambda functions
echo "Checking Lambda functions..."
LAMBDA_FUNCTIONS=$(aws lambda list-functions --region $REGION --query "Functions[].FunctionName" --output text)
if [ -z "$LAMBDA_FUNCTIONS" ]; then
  echo "No Lambda functions found."
else
  for FUNC in $LAMBDA_FUNCTIONS; do
    echo "Deleting Lambda function: $FUNC"
    aws lambda delete-function --region $REGION --function-name "$FUNC"
  done
fi

# Delete RDS instances
echo "Checking RDS instances..."
RDS_INSTANCES=$(aws rds describe-db-instances --region $REGION --query "DBInstances[?DBInstanceStatus!='deleted'].DBInstanceIdentifier" --output text)
if [ -z "$RDS_INSTANCES" ]; then
  echo "No RDS instances found."
else
  for DB in $RDS_INSTANCES; do
    echo "Deleting RDS instance: $DB"
    aws rds delete-db-instance --region $REGION --db-instance-identifier "$DB" --skip-final-snapshot
  done
fi

echo "Cleanup initiated. Some deletions take time to complete asynchronously."


