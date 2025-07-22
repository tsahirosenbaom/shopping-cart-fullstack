#!/bin/bash

echo "🔧 Creating correct ecs-services.yaml file"
echo "==========================================="

# Remove any existing file
rm -f ecs-services.yaml

# Create the file with proper formatting
cat > ecs-services.yaml << 'YAML_EOF'
AWSTemplateFormatVersion: 2010-09-09
Description: ECS Services for Shopping Cart System

Parameters:
  ProjectName:
    Type: String
    Default: shopping-cart-system
  DotNetImageURI:
    Type: String
    Description: URI of the .NET API Docker image
  NodeJsImageURI:
    Type: String
    Description: URI of the Node.js API Docker image

Resources:
  DotNetLogGroup:
    Type: AWS::Logs::LogGroup
    Properties:
      LogGroupName: !Sub /ecs/${ProjectName}-dotnet-api
      RetentionInDays: 7

  NodeJsLogGroup:
    Type: AWS::Logs::LogGroup
    Properties:
      LogGroupName: !Sub /ecs/${ProjectName}-nodejs-api
      RetentionInDays: 7

  DotNetTaskDefinition:
    Type: AWS::ECS::TaskDefinition
    Properties:
      Family: !Sub ${ProjectName}-dotnet-api
      NetworkMode: awsvpc
      RequiresCompatibilities:
        - FARGATE
      Cpu: 256
      Memory: 512
      ExecutionRoleArn: 
        Fn::ImportValue: !Sub ${ProjectName}-execution-role-arn
      TaskRoleArn:
        Fn::ImportValue: !Sub ${ProjectName}-task-role-arn
      ContainerDefinitions:
        - Name: dotnet-api
          Image: !Ref DotNetImageURI
          PortMappings:
            - ContainerPort: 80
              Protocol: tcp
          LogConfiguration:
            LogDriver: awslogs
            Options:
              awslogs-group: !Ref DotNetLogGroup
              awslogs-region: !Ref AWS::Region
              awslogs-stream-prefix: ecs
          Environment:
            - Name: ASPNETCORE_ENVIRONMENT
              Value: Production
            - Name: ASPNETCORE_URLS
              Value: http://+:80

  NodeJsTaskDefinition:
    Type: AWS::ECS::TaskDefinition
    Properties:
      Family: !Sub ${ProjectName}-nodejs-api
      NetworkMode: awsvpc
      RequiresCompatibilities:
        - FARGATE
      Cpu: 256
      Memory: 512
      ExecutionRoleArn: 
        Fn::ImportValue: !Sub ${ProjectName}-execution-role-arn
      TaskRoleArn:
        Fn::ImportValue: !Sub ${ProjectName}-task-role-arn
      ContainerDefinitions:
        - Name: nodejs-api
          Image: !Ref NodeJsImageURI
          PortMappings:
            - ContainerPort: 3001
              Protocol: tcp
          LogConfiguration:
            LogDriver: awslogs
            Options:
              awslogs-group: !Ref NodeJsLogGroup
              awslogs-region: !Ref AWS::Region
              awslogs-stream-prefix: ecs
          Environment:
            - Name: NODE_ENV
              Value: production
            - Name: PORT
              Value: "3001"

  DotNetService:
    Type: AWS::ECS::Service
    Properties:
      ServiceName: !Sub ${ProjectName}-dotnet-api
      Cluster: 
        Fn::ImportValue: !Sub ${ProjectName}-cluster
      TaskDefinition: !Ref DotNetTaskDefinition
      DesiredCount: 1
      LaunchType: FARGATE
      NetworkConfiguration:
        AwsvpcConfiguration:
          SecurityGroups:
            - Fn::ImportValue: !Sub ${ProjectName}-ecs-sg-id
          Subnets:
            - Fn::ImportValue: !Sub ${ProjectName}-public-subnet-1-id
            - Fn::ImportValue: !Sub ${ProjectName}-public-subnet-2-id
          AssignPublicIp: ENABLED
      LoadBalancers:
        - ContainerName: dotnet-api
          ContainerPort: 80
          TargetGroupArn:
            Fn::ImportValue: !Sub ${ProjectName}-dotnet-tg-arn
      HealthCheckGracePeriodSeconds: 300

  NodeJsService:
    Type: AWS::ECS::Service
    Properties:
      ServiceName: !Sub ${ProjectName}-nodejs-api
      Cluster: 
        Fn::ImportValue: !Sub ${ProjectName}-cluster
      TaskDefinition: !Ref NodeJsTaskDefinition
      DesiredCount: 1
      LaunchType: FARGATE
      NetworkConfiguration:
        AwsvpcConfiguration:
          SecurityGroups:
            - Fn::ImportValue: !Sub ${ProjectName}-ecs-sg-id
          Subnets:
            - Fn::ImportValue: !Sub ${ProjectName}-public-subnet-1-id
            - Fn::ImportValue: !Sub ${ProjectName}-public-subnet-2-id
          AssignPublicIp: ENABLED
      LoadBalancers:
        - ContainerName: nodejs-api
          ContainerPort: 3001
          TargetGroupArn:
            Fn::ImportValue: !Sub ${ProjectName}-nodejs-tg-arn
      HealthCheckGracePeriodSeconds: 300

Outputs:
  DotNetServiceName:
    Description: .NET API Service Name
    Value: !Ref DotNetService

  NodeJsServiceName:
    Description: Node.js API Service Name
    Value: !Ref NodeJsService
YAML_EOF

echo "✅ Created ecs-services.yaml"
echo "📋 Validating YAML syntax..."

# Validate the template
aws cloudformation validate-template \
    --template-body file://ecs-services.yaml \
    --region us-east-1 >/dev/null

if [ $? -eq 0 ]; then
    echo "✅ YAML syntax is valid"
    echo "🚀 Ready to deploy!"
else
    echo "❌ YAML validation failed"
    exit 1
fi
