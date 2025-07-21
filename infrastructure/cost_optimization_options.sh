#!/bin/bash

# AWS Cost Optimization Options
echo "💰 Creating cost optimization configurations..."

cd ~/aws-deployment

# Option 1: Auto-scaling based on demand
cat > auto-scaling-config.yaml << 'EOF'
# Add to ecs-services.yaml for auto-scaling
Resources:
  # Auto Scaling Target for .NET API
  DotNetScalingTarget:
    Type: AWS::ApplicationAutoScaling::ScalableTarget
    Properties:
      MaxCapacity: 10
      MinCapacity: 0  # Can scale to 0 when no traffic
      ResourceId: !Sub service/${ProjectName}-cluster/${ProjectName}-dotnet-api
      RoleARN: !Sub arn:aws:iam::${AWS::AccountId}:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService
      ScalableDimension: ecs:service:DesiredCount
      ServiceNamespace: ecs

  # Auto Scaling Policy - Scale Up
  DotNetScaleUpPolicy:
    Type: AWS::ApplicationAutoScaling::ScalingPolicy
    Properties:
      PolicyName: DotNetScaleUpPolicy
      PolicyType: TargetTrackingScaling
      ScalingTargetId: !Ref DotNetScalingTarget
      TargetTrackingScalingPolicyConfiguration:
        PredefinedMetricSpecification:
          PredefinedMetricType: ECSServiceAverageCPUUtilization
        TargetValue: 50.0
        ScaleOutCooldown: 300
        ScaleInCooldown: 300

  # Similar configuration for Node.js API
  NodeJsScalingTarget:
    Type: AWS::ApplicationAutoScaling::ScalableTarget
    Properties:
      MaxCapacity: 10
      MinCapacity: 0
      ResourceId: !Sub service/${ProjectName}-cluster/${ProjectName}-nodejs-api
      RoleARN: !Sub arn:aws:iam::${AWS::AccountId}:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService
      ScalableDimension: ecs:service:DesiredCount
      ServiceNamespace: ecs
EOF

# Option 2: Scheduled scaling (turn off at night)
cat > scheduled-scaling.yaml << 'EOF'
# Scheduled Actions for Cost Savings
Resources:
  # Scale down at night (11 PM UTC = 2 AM Israel time)
  ScaleDownSchedule:
    Type: AWS::ApplicationAutoScaling::ScheduledAction
    Properties:
      ResourceId: !Sub service/${ProjectName}-cluster/${ProjectName}-dotnet-api
      ScalableDimension: ecs:service:DesiredCount
      ServiceNamespace: ecs
      Schedule: cron(0 23 * * ? *)  # 11 PM UTC daily
      ScalableTargetAction:
        MinCapacity: 0
        MaxCapacity: 0

  # Scale up in the morning (6 AM UTC = 9 AM Israel time)
  ScaleUpSchedule:
    Type: AWS::ApplicationAutoScaling::ScheduledAction
    Properties:
      ResourceId: !Sub service/${ProjectName}-cluster/${ProjectName}-dotnet-api
      ScalableDimension: ecs:service:DesiredCount
      ServiceNamespace: ecs
      Schedule: cron(0 6 * * ? *)   # 6 AM UTC daily
      ScalableTargetAction:
        MinCapacity: 1
        MaxCapacity: 10
EOF

# Option 3: Lambda + API Gateway (Serverless)
cat > serverless-alternative.yaml << 'EOF'
# Serverless Alternative using Lambda
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31

Resources:
  # API Gateway
  ShoppingCartApi:
    Type: AWS::Serverless::Api
    Properties:
      StageName: prod
      Cors:
        AllowMethods: "'*'"
        AllowHeaders: "'*'"
        AllowOrigin: "'*'"

  # Lambda for Categories (replaces .NET API)
  CategoriesFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: lambda/categories/
      Handler: index.handler
      Runtime: nodejs18.x
      Environment:
        Variables:
          DB_CONNECTION_STRING: !Ref DatabaseConnectionString
      Events:
        GetCategories:
          Type: Api
          Properties:
            RestApiId: !Ref ShoppingCartApi
            Path: /api/categories
            Method: get

  # Lambda for Orders (replaces Node.js API)
  OrdersFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: lambda/orders/
      Handler: index.handler
      Runtime: nodejs18.x
      Events:
        CreateOrder:
          Type: Api
          Properties:
            RestApiId: !Ref ShoppingCartApi
            Path: /api/orders
            Method: post
        GetOrders:
          Type: Api
          Properties:
            RestApiId: !Ref ShoppingCartApi
            Path: /api/orders
            Method: get

# Cost: Only pay when functions are invoked
# Free tier: 1M requests/month + 400,000 GB-seconds compute time
EOF

# Option 4: Container on-demand with ECS + ALB
cat > on-demand-containers.sh << 'EOF'
#!/bin/bash

# On-Demand Container Management Scripts
echo "🔄 Managing containers on-demand..."

PROJECT_NAME="shopping-cart-system"
REGION="us-east-1"

# Function to scale services to 0 (stop containers)
stop_services() {
    echo "⏹️ Stopping all services..."
    
    aws ecs update-service \
        --cluster "$PROJECT_NAME-cluster" \
        --service "$PROJECT_NAME-dotnet-api" \
        --desired-count 0 \
        --region $REGION
    
    aws ecs update-service \
        --cluster "$PROJECT_NAME-cluster" \
        --service "$PROJECT_NAME-nodejs-api" \
        --desired-count 0 \
        --region $REGION
    
    echo "✅ Services stopped. Saving ~$0.50/hour (~$12/day)"
}

# Function to scale services to 1 (start containers)
start_services() {
    echo "▶️ Starting all services..."
    
    aws ecs update-service \
        --cluster "$PROJECT_NAME-cluster" \
        --service "$PROJECT_NAME-dotnet-api" \
        --desired-count 1 \
        --region $REGION
    
    aws ecs update-service \
        --cluster "$PROJECT_NAME-cluster" \
        --service "$PROJECT_NAME-nodejs-api" \
        --desired-count 1 \
        --region $REGION
    
    echo "✅ Services starting... (takes 2-3 minutes to be ready)"
}

# Function to check if services are running
check_status() {
    echo "📊 Checking service status..."
    
    DOTNET_RUNNING=$(aws ecs describe-services \
        --cluster "$PROJECT_NAME-cluster" \
        --services "$PROJECT_NAME-dotnet-api" \
        --query 'services[0].runningCount' \
        --output text \
        --region $REGION)
    
    NODEJS_RUNNING=$(aws ecs describe-services \
        --cluster "$PROJECT_NAME-cluster" \
        --services "$PROJECT_NAME-nodejs-api" \
        --query 'services[0].runningCount' \
        --output text \
        --region $REGION)
    
    if [ "$DOTNET_RUNNING" = "0" ] && [ "$NODEJS_RUNNING" = "0" ]; then
        echo "⏹️ All services stopped - Saving money! 💰"
    elif [ "$DOTNET_RUNNING" = "1" ] && [ "$NODEJS_RUNNING" = "1" ]; then
        echo "✅ All services running - Ready for traffic! 🚀"
    else
        echo "⚠️ Services in transition state..."
    fi
}

# Command line interface
case "$1" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    status)
        check_status
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        echo ""
        echo "Commands:"
        echo "  start  - Start all services (costs ~$0.50/hour)"
        echo "  stop   - Stop all services (saves money)"
        echo "  status - Check current status"
        exit 1
        ;;
esac
EOF

chmod +x on-demand-containers.sh

# Option 5: AWS App Runner (Simplest managed option)
cat > app-runner-alternative.yaml << 'EOF'
# AWS App Runner - Managed Container Service
AWSTemplateFormatVersion: '2010-09-09'

Resources:
  # App Runner service for .NET API
  DotNetAppRunnerService:
    Type: AWS::AppRunner::Service
    Properties:
      ServiceName: !Sub ${ProjectName}-dotnet-api
      SourceConfiguration:
        ImageRepository:
          ImageIdentifier: !Ref DotNetImageURI
          ImageConfiguration:
            Port: '80'
            RuntimeEnvironmentVariables:
              - Name: ASPNETCORE_ENVIRONMENT
                Value: Production
          ImageRepositoryType: ECR
        AutoDeploymentsEnabled: false
      InstanceConfiguration:
        Cpu: 0.25 vCPU
        Memory: 0.5 GB
      # Auto-scaling configuration
      AutoScalingConfigurationArn: !Ref AppRunnerAutoScalingConfig

  # Auto-scaling configuration with ability to scale to 0
  AppRunnerAutoScalingConfig:
    Type: AWS::AppRunner::AutoScalingConfiguration
    Properties:
      AutoScalingConfigurationName: !Sub ${ProjectName}-autoscaling
      MinSize: 0  # Can scale to 0 when no traffic
      MaxSize: 10
      MaxConcurrency: 100

# Benefits:
# - Automatic scaling to 0 when no traffic
# - Only pay for active request time
# - Managed load balancing and SSL
# - Built-in monitoring
EOF

echo "✅ Cost optimization options created!"
echo ""
echo "💰 Cost Comparison:"
echo "==================="
echo ""
echo "1️⃣ Current Setup (Always Running):"
echo "   • Cost: ~$32-36/month"
echo "   • Availability: 99.9%"
echo "   • Cold start: None"
echo ""
echo "2️⃣ Auto-scaling (Scale to 0):"
echo "   • Cost: ~$16-20/month + usage"
echo "   • Availability: 99.5%"
echo "   • Cold start: 30-60 seconds"
echo ""
echo "3️⃣ Scheduled Scaling (Off at night):"
echo "   • Cost: ~$20-25/month"
echo "   • Availability: 16 hours/day"
echo "   • Cold start: 2-3 minutes"
echo ""
echo "4️⃣ On-Demand Management:"
echo "   • Cost: ~$16/month + $0.50/hour when running"
echo "   • Availability: When you start it"
echo "   • Cold start: 2-3 minutes"
echo ""
echo "5️⃣ Lambda Serverless:"
echo "   • Cost: ~$1-5/month (free tier)"
echo "   • Availability: 99.9%"
echo "   • Cold start: 1-5 seconds"
echo ""
echo "6️⃣ AWS App Runner:"
echo "   • Cost: ~$15-25/month"
echo "   • Availability: 99.9%"
echo "   • Cold start: 10-30 seconds"
echo "   • Auto-scales to 0"
echo ""
echo "🎯 Recommendations:"
echo "=================="
echo ""
echo "📊 For Production/Demo: Current setup (always running)"
echo "💰 For Development: On-demand management"
echo "🚀 For High Traffic: Auto-scaling"
echo "💡 For Minimal Cost: Lambda serverless"
echo ""
echo "🔧 To use on-demand management:"
echo "./on-demand-containers.sh start   # Start when needed"
echo "./on-demand-containers.sh stop    # Stop to save money"
echo "./on-demand-containers.sh status  # Check current state"
