# Shopping Cart System - Full Stack

Complete shopping cart system organized for development and AWS deployment.

## 🎯 Quick Start

```bash
# 1. Verify your setup
npm run verify

# 2. Install all dependencies  
npm run setup-local

# 3. Start development (choose one)
npm run dev:frontend    # React app (port 3000)
npm run dev:backend     # .NET API (port 5002)
npm run dev:search      # Node.js API (port 3001)
npm run dev:serverless  # Lambda local (port 3000)
```

## 📁 Project Structure

```
shopping-cart-fullstack/
├── frontend/                    # React + Redux + TypeScript
│   ├── src/                    # Source code
│   ├── public/                 # Static assets  
│   └── package.json           # Dependencies
├── backend/
│   ├── dotnet-api/            # .NET 8 Web API
│   │   ├── Controllers/       # API controllers
│   │   ├── Models/           # Data models
│   │   └── *.csproj          # Project file
│   ├── nodejs-search/         # Node.js search service
│   │   ├── server.js         # Main server file
│   │   └── package.json      # Dependencies
│   └── serverless/           # AWS Lambda functions
│       ├── src/              # Lambda source code
│       └── template.yaml     # SAM template
├── infrastructure/           # Deployment scripts
├── scripts/                 # Helper scripts
│   ├── verify-setup.sh      # Verify installation
│   ├── setup-local-dev.sh   # Install dependencies
│   ├── test-all.sh          # Run all tests
│   └── choose-deployment.sh # Setup deployment
└── .github/workflows/       # CI/CD pipelines
    ├── deploy-serverless.yml.example
    └── deploy-ecs.yml.example
```

## 🛠️ Available Commands

### Development
```bash
npm run verify           # Check setup status
npm run setup-local      # Install all dependencies
npm run dev:frontend     # Start React app
npm run dev:backend      # Start .NET API  
npm run dev:search       # Start Node.js API
npm run dev:serverless   # Start Lambda local
```

### Testing
```bash
npm run test:all         # Run all tests
npm run test:frontend    # Test React app
npm run test:backend     # Test .NET API
npm run test:search      # Test Node.js API
```

### Building
```bash
npm run build:frontend   # Build React for production
npm run build:backend    # Build .NET API
```

### Deployment Setup
```bash
npm run setup-deployment # Choose deployment strategy
```

## 🔧 Prerequisites

Make sure you have these installed:

- **Node.js 18+** - [Download](https://nodejs.org/)
- **.NET 8 SDK** - [Download](https://dotnet.microsoft.com/download)
- **Git** - [Download](https://git-scm.com/)
- **AWS CLI** (for deployment) - [Install Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- **SAM CLI** (for serverless) - [Install Guide](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html)

Check prerequisites: `npm run verify`

## 🚀 Development Workflow

1. **Start with verification**:
   ```bash
   npm run verify
   ```

2. **Install dependencies**:
   ```bash
   npm run setup-local
   ```

3. **Start your components** (in separate terminals):
   ```bash
   # Terminal 1: Frontend
   npm run dev:frontend
   
   # Terminal 2: Backend API
   npm run dev:backend
   
   # Terminal 3: Search API  
   npm run dev:search
   ```

4. **Access your applications**:
   - **React App**: http://localhost:3000
   - **.NET API**: http://localhost:5002/swagger
   - **Node.js Search**: http://localhost:3001
   - **Lambda Local**: http://localhost:3000 (if using serverless)

## 🧪 Testing

Run tests to ensure everything works:

```bash
# Test everything
npm run test:all

# Test individual components
npm run test:frontend    # React tests
npm run test:backend     # .NET tests  
npm run test:search      # Node.js tests
```

## 🌐 Deployment Options

### Option 1: Serverless ($1-5/month)
- **Best for**: New projects, variable traffic
- **Stack**: AWS Lambda + API Gateway + DynamoDB + S3
- **Cost**: Pay per use, scales to zero
- **Setup**: `npm run setup-deployment` → Choose option 1

### Option 2: ECS Containers ($30-35/month)
- **Best for**: Production apps, consistent traffic
- **Stack**: ECS Fargate + ALB + S3 + CloudFront
- **Cost**: Always running containers
- **Setup**: `npm run setup-deployment` → Choose option 2

### Deployment Steps
1. **Choose strategy**: `npm run setup-deployment`
2. **Set up AWS credentials** in GitHub Secrets
3. **Push to GitHub**: Automatic deployment!

## 🔍 Troubleshooting

### Common Issues

**"Command not found" errors**:
```bash
# Check what's missing
npm run verify

# Install missing tools:
# - Node.js: https://nodejs.org/
# - .NET: https://dotnet.microsoft.com/download
# - Git: https://git-scm.com/
```

**Port already in use**:
```bash
# Find what's using the port
netstat -tln | grep :3000
# Kill the process or use different port
```

**Dependencies fail to install**:
```bash
# Clear cache and retry
npm cache clean --force
cd frontend && npm install
cd ../backend/nodejs-search && npm install
```

**Build errors**:
```bash
# For .NET issues
cd backend/dotnet-api
dotnet clean
dotnet restore
dotnet build
```

### Getting Help

1. **Run verification**: `npm run verify`
2. **Check component logs** in their respective terminals
3. **Review error messages** carefully
4. **Ensure all prerequisites** are installed

## 📊 Component Status

Use `npm run verify` to see:

- ✅ Components found and configured
- ❌ Missing components  
- ⚠️ Components with issues
- 🛠️ Prerequisites status
- 🌐 Port availability

## 💡 Development Tips

### Frontend (React)
- Hot reload enabled - changes appear instantly
- Check browser console for errors
- Use Redux DevTools browser extension
- API calls go to backend automatically

### Backend (.NET API)
- Swagger UI available at `/swagger`
- Auto-restart on file changes
- Check terminal for compilation errors
- Entity Framework for database

### Search API (Node.js)
- RESTful API endpoints
- Express.js framework
- JSON responses
- CORS enabled for frontend

### Serverless (AWS Lambda)
- SAM local for testing
- Multiple Lambda functions
- DynamoDB for data storage
- API Gateway for routing

## 🎯 Next Steps

1. **Verify setup**: `npm run verify`
2. **Install dependencies**: `npm run setup-local` 
3. **Start development**: Use `npm run dev:*` commands
4. **Add features**: Develop in your components
5. **Test changes**: `npm run test:all`
6. **Deploy**: Set up automated deployment

## 📚 Learning Resources

- **React**: [Official Docs](https://reactjs.org/docs)
- **.NET**: [Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/)
- **Node.js**: [Official Docs](https://nodejs.org/en/docs/)
- **AWS Lambda**: [AWS Docs](https://docs.aws.amazon.com/lambda/)
- **AWS SAM**: [SAM Developer Guide](https://docs.aws.amazon.com/serverless-application-model/)

---

**Ready to code? Start with `npm run verify` to check your setup!** 🚀
