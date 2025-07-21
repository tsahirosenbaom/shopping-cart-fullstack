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
