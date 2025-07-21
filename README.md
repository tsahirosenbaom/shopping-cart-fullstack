# Shopping Cart System - Full Stack

A complete shopping cart system with React frontend and multiple backend options.

## 🏗️ Architecture Options

### Option 1: Serverless (Recommended for low traffic)
- **Frontend**: React app on S3 + CloudFront
- **Backend**: AWS Lambda + API Gateway + DynamoDB
- **Cost**: ~$1-5/month (pay per use)
- **Deployment**: `git push` → automatic deployment

### Option 2: Containerized (For consistent traffic)
- **Frontend**: React app on S3 + CloudFront
- **Backend**: ECS Fargate + Application Load Balancer
- **Cost**: ~$30-35/month (always running)
- **Deployment**: `git push` → automatic deployment

## 🚀 Quick Start

1. **Choose your deployment strategy** (edit `.github/workflows/`)
2. **Set up AWS credentials** in GitHub Secrets
3. **Push to main branch** → automatic deployment

## 📁 Project Structure

```
├── frontend/                 # React + Redux + TypeScript
├── backend/
│   ├── dotnet-api/          # .NET 8 Web API
│   ├── nodejs-search/       # Node.js search service
│   └── serverless/          # AWS Lambda functions
├── infrastructure/          # CloudFormation templates
└── .github/workflows/       # CI/CD pipelines
```

## ⚙️ Setup

### Prerequisites
- AWS Account with appropriate permissions
- GitHub repository
- Node.js 18+ and .NET 8 installed locally

### 1. GitHub Setup
```bash
# Clone or create your repository
git clone https://github.com/yourusername/shopping-cart-fullstack.git
cd shopping-cart-fullstack

# Add GitHub secrets (Settings → Secrets and variables → Actions):
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
```

### 2. Choose Deployment Strategy

#### For Serverless (Low Cost):
```bash
# Enable serverless workflow
mv .github/workflows/deploy-serverless.yml.example .github/workflows/deploy-serverless.yml

# Commit and push
git add .
git commit -m "Enable serverless deployment"
git push origin main
```

#### For ECS (High Availability):
```bash
# Enable ECS workflow
mv .github/workflows/deploy-ecs.yml.example .github/workflows/deploy-ecs.yml

# Commit and push
git add .
git commit -m "Enable ECS deployment"
git push origin main
```

### 3. Monitor Deployment
- Check GitHub Actions tab for deployment progress
- First deployment takes 10-15 minutes
- Subsequent deployments: 3-5 minutes

## 🧪 Local Development

### Frontend (React)
```bash
cd frontend
npm install
npm start  # http://localhost:3000
```

### Backend (.NET API)
```bash
cd backend/dotnet-api
dotnet run  # http://localhost:5002/swagger
```

### Backend (Node.js Search)
```bash
cd backend/nodejs-search
npm install
npm start  # http://localhost:3001
```

### Serverless Local Testing
```bash
cd backend/serverless
sam local start-api  # http://localhost:3000
```

## 🔄 Development Workflow

1. **Make changes** to frontend or backend code
2. **Push to main branch**
3. **Automatic deployment** triggers
4. **Monitor** in GitHub Actions
5. **Test** deployed application

## 📊 Monitoring & Costs

### Serverless Monitoring
```bash
# Check Lambda logs
aws logs tail /aws/lambda/serverless-shopping-cart-CategoriesFunction --follow

# Monitor costs
aws ce get-cost-and-usage --time-period Start=2025-07-01,End=2025-07-31 --granularity MONTHLY --metrics UnblendedCost
```

### ECS Monitoring
```bash
# Check service status
aws ecs describe-services --cluster shopping-cart-system-cluster --services shopping-cart-system-dotnet-api

# View logs
aws logs tail /ecs/shopping-cart-system/dotnet-api --follow
```

## 🛠️ Troubleshooting

### Common Issues
1. **AWS Permissions**: Ensure your AWS user has CloudFormation, ECS, Lambda, S3, and IAM permissions
2. **GitHub Secrets**: Verify AWS credentials are correctly set in GitHub
3. **Build Failures**: Check GitHub Actions logs for specific error messages

### Useful Commands
```bash
# Manual deployment (if needed)
cd infrastructure
./deploy-everything.sh

# Clean up resources
./cleanup-aws.sh
```

## 🔧 Configuration

### Environment Variables (Frontend)
- `REACT_APP_API_BASE_URL`: Backend API URL
- `REACT_APP_ORDERS_API_BASE_URL`: Orders API URL

### Environment Variables (Backend)
- `ASPNETCORE_ENVIRONMENT`: .NET environment
- `NODE_ENV`: Node.js environment
- AWS Lambda automatically sets DynamoDB table names

## 🚢 Deployment Details

### Serverless Deployment Includes:
- API Gateway with CORS
- Lambda functions for all APIs
- DynamoDB tables
- S3 bucket for React app
- Automatic database seeding

### ECS Deployment Includes:
- VPC with public subnets
- Application Load Balancer
- ECS cluster with Fargate
- ECR repositories
- S3 + CloudFront for React app

## 📈 Scaling

### Serverless Auto-scaling:
- Lambda: Automatic (1000 concurrent by default)
- DynamoDB: On-demand billing scales automatically
- API Gateway: Automatic

### ECS Scaling:
```yaml
# Add to ecs-services.yaml
AutoScalingTarget:
  Type: AWS::ApplicationAutoScaling::ScalableTarget
  Properties:
    MinCapacity: 1
    MaxCapacity: 10
```

## 🔒 Security

### Best Practices Implemented:
- IAM roles with least privilege
- VPC security groups
- HTTPS redirects in CloudFront
- Non-root containers
- Environment-based configuration

---

**💡 Tips:**
- Use serverless for new projects or low traffic
- Use ECS for production apps with consistent load
- Monitor costs regularly in AWS Console
- Set up CloudWatch alarms for important metrics
