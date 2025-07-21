# Shopping Cart Full Stack - DevOps Project 🛒

A complete serverless e-commerce shopping cart system with automated DevOps pipeline, built with modern technologies and deployed on AWS.

## 🎯 Project Overview

This project demonstrates a **production-ready serverless architecture** with full DevOps automation, featuring React frontend, Node.js Lambda backend, and complete CI/CD pipeline.

**Live Demo**: [Your deployed URL here]
**Repository**: https://github.com/tsahirosenbaom/shopping-cart-fullstack

## 📊 CI/CD Pipeline Architecture

```mermaid
graph TB
    subgraph "Development"
        DEV[👨‍💻 Developer]
        LOCAL[🖥️ Local Development]
        DEV --> LOCAL
    end

    subgraph "Source Control"
        GITHUB[📚 GitHub Repository<br/>shopping-cart-fullstack]
        LOCAL --> |git push| GITHUB
    end

    subgraph "CI/CD Pipeline - GitHub Actions"
        TRIGGER[🔄 Trigger on Push to Main]

        subgraph "Build & Test Stage"
            TEST_FRONTEND[🧪 Test React App<br/>- Unit Tests<br/>- Type Checking<br/>- Lint]
            TEST_BACKEND[🧪 Test Lambda Functions<br/>- Unit Tests<br/>- Integration Tests]
            BUILD[🏗️ Build Applications<br/>- React Build<br/>- Lambda Packaging]
        end

        subgraph "Deploy Stage"
            DEPLOY_INFRA[☁️ Deploy Infrastructure<br/>- CloudFormation/SAM<br/>- Lambda Functions<br/>- API Gateway<br/>- DynamoDB]
            DEPLOY_FRONTEND[🚀 Deploy Frontend<br/>- Build React App<br/>- Upload to S3/Amplify<br/>- Invalidate CDN]
        end

        subgraph "Post Deploy"
            INTEGRATION_TEST[🔍 Integration Tests<br/>- API Health Checks<br/>- End-to-End Tests]
            NOTIFY[📱 Notifications<br/>- Slack/Email<br/>- Status Updates]
        end

        GITHUB --> TRIGGER
        TRIGGER --> TEST_FRONTEND
        TRIGGER --> TEST_BACKEND
        TEST_FRONTEND --> BUILD
        TEST_BACKEND --> BUILD
        BUILD --> DEPLOY_INFRA
        DEPLOY_INFRA --> DEPLOY_FRONTEND
        DEPLOY_FRONTEND --> INTEGRATION_TEST
        INTEGRATION_TEST --> NOTIFY
    end

    subgraph "AWS Cloud Environment"
        subgraph "Frontend Hosting"
            AMPLIFY[📱 AWS Amplify<br/>React SPA]
            CDN[🌐 CloudFront CDN<br/>Global Distribution]
            AMPLIFY --> CDN
        end

        subgraph "Backend Services"
            API[🔌 API Gateway<br/>REST Endpoints]

            subgraph "Lambda Functions"
                LAMBDA_CAT[⚡ Categories API]
                LAMBDA_PROD[⚡ Products API]
                LAMBDA_ORDER[⚡ Orders API]
                LAMBDA_HEALTH[⚡ Health Check]
            end

            API --> LAMBDA_CAT
            API --> LAMBDA_PROD
            API --> LAMBDA_ORDER
            API --> LAMBDA_HEALTH
        end

        subgraph "Data Layer"
            DDB_CAT[(🗄️ DynamoDB<br/>Categories)]
            DDB_PROD[(🗄️ DynamoDB<br/>Products)]
            DDB_ORDER[(🗄️ DynamoDB<br/>Orders)]

            LAMBDA_CAT --> DDB_CAT
            LAMBDA_PROD --> DDB_PROD
            LAMBDA_ORDER --> DDB_ORDER
        end

        subgraph "Monitoring"
            CLOUDWATCH[📊 CloudWatch<br/>Logs & Metrics]
            XRAY[🔍 X-Ray Tracing]

            LAMBDA_CAT --> CLOUDWATCH
            LAMBDA_PROD --> CLOUDWATCH
            LAMBDA_ORDER --> CLOUDWATCH
            API --> XRAY
        end

        DEPLOY_INFRA --> API
        DEPLOY_FRONTEND --> AMPLIFY
        CDN --> |HTTPS API Calls| API
    end

    subgraph "Users"
        USER[👥 End Users]
        USER --> CDN
    end

    style GITHUB fill:#24292e,stroke:#fff,color:#fff
    style AMPLIFY fill:#ff9900,stroke:#fff,color:#fff
    style API fill:#ff9900,stroke:#fff,color:#fff
    style LAMBDA_CAT fill:#ff9900,stroke:#fff,color:#000
    style LAMBDA_PROD fill:#ff9900,stroke:#fff,color:#000
    style LAMBDA_ORDER fill:#ff9900,stroke:#fff,color:#000
    style LAMBDA_HEALTH fill:#ff9900,stroke:#fff,color:#000
    style DDB_CAT fill:#3949ab,stroke:#fff,color:#fff
    style DDB_PROD fill:#3949ab,stroke:#fff,color:#fff
    style DDB_ORDER fill:#3949ab,stroke:#fff,color:#fff
    style CLOUDWATCH fill:#ff9900,stroke:#fff,color:#fff
```

## 🏗️ Architecture Overview

### Technology Stack

- **Frontend**: React 18 + TypeScript + Redux Toolkit + Tailwind CSS
- **Backend**: Node.js Lambda Functions + Express.js
- **Database**: Amazon DynamoDB (NoSQL)
- **API**: Amazon API Gateway (REST)
- **Hosting**: AWS Amplify + CloudFront CDN
- **CI/CD**: GitHub Actions
- **IaC**: AWS SAM (Serverless Application Model)
- **Monitoring**: CloudWatch + X-Ray

# Shopping Cart Architecture

<div align="center">

<svg width="1200" height="1400" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <!-- Gradients -->
    <linearGradient id="awsOrange" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#FF9900"/>
      <stop offset="100%" style="stop-color:#FFB84D"/>
    </linearGradient>
    
    <linearGradient id="awsBlue" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#4A90E2"/>
      <stop offset="100%" style="stop-color:#7BB3F0"/>
    </linearGradient>
    
    <linearGradient id="dotnetPurple" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#512BD4"/>
      <stop offset="100%" style="stop-color:#7B68EE"/>
    </linearGradient>
    
    <linearGradient id="nodeGreen" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#339933"/>
      <stop offset="100%" style="stop-color:#66BB33"/>
    </linearGradient>
    
    <linearGradient id="headerGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#667eea"/>
      <stop offset="100%" style="stop-color:#764ba2"/>
    </linearGradient>
    
    <!-- Arrow marker -->
    <defs>
      <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
        <polygon points="0 0, 10 3.5, 0 7" fill="#333"/>
      </marker>
    </defs>
  </defs>

  <!-- Background -->
  <rect width="1200" height="1400" fill="#f8f9fa"/>
  
  <!-- Title -->
  <rect x="0" y="0" width="1200" height="80" fill="url(#headerGradient)"/>
  <text x="600" y="50" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="24" font-weight="bold">Shopping Cart - Complete Architecture Options</text>
  
  <!-- Shared Frontend Layer -->
  <text x="600" y="120" text-anchor="middle" fill="#333" font-family="Arial, sans-serif" font-size="18" font-weight="bold">Shared Frontend Layer</text>
  
  <!-- Internet Users -->
  <rect x="400" y="140" width="400" height="50" rx="8" fill="url(#headerGradient)" stroke="#5a6fd8" stroke-width="2"/>
  <text x="600" y="170" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="14" font-weight="bold">🌍 Internet Users</text>
  
  <!-- CloudFront -->
  <rect x="400" y="220" width="400" height="50" rx="8" fill="url(#awsOrange)" stroke="#FF9900" stroke-width="2"/>
  <text x="600" y="250" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="14" font-weight="bold">🌐 CloudFront CDN</text>
  
  <!-- React Frontend -->
  <rect x="400" y="300" width="400" height="50" rx="8" fill="url(#awsOrange)" stroke="#FF9900" stroke-width="2"/>
  <text x="600" y="330" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="14" font-weight="bold">📱 React App (Amplify/S3)</text>
  
  <!-- Arrows -->
  <line x1="600" y1="190" x2="600" y2="220" stroke="#333" stroke-width="2" marker-end="url(#arrowhead)"/>
  <line x1="600" y1="270" x2="600" y2="300" stroke="#333" stroke-width="2" marker-end="url(#arrowhead)"/>
  
  <!-- Split Arrow -->
  <line x1="600" y1="350" x2="600" y2="380" stroke="#333" stroke-width="3"/>
  <line x1="600" y1="380" x2="300" y2="420" stroke="#333" stroke-width="3" marker-end="url(#arrowhead)"/>
  <line x1="600" y1="380" x2="900" y2="420" stroke="#333" stroke-width="3" marker-end="url(#arrowhead)"/>
  
  <!-- Option Labels -->
  <text x="150" y="410" fill="#FF9900" font-family="Arial, sans-serif" font-size="16" font-weight="bold">Option A: Serverless</text>
  <text x="900" y="410" fill="#512BD4" font-family="Arial, sans-serif" font-size="16" font-weight="bold">Option B: Containerized</text>
  
  <!-- SERVERLESS SIDE (LEFT) -->
  <!-- API Gateway -->
  <rect x="50" y="440" width="500" height="50" rx="8" fill="url(#awsOrange)" stroke="#FF9900" stroke-width="2"/>
  <text x="300" y="470" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="14" font-weight="bold">🔌 API Gateway (Serverless)</text>
  
  <!-- Lambda Functions Row -->
  <text x="300" y="520" text-anchor="middle" fill="#333" font-family="Arial, sans-serif" font-size="12" font-weight="bold">Lambda Functions</text>
  
  <!-- Lambda 1 -->
  <rect x="50" y="530" width="80" height="60" rx="6" fill="url(#awsOrange)" stroke="#FF9900" stroke-width="1"/>
  <text x="90" y="550" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="10" font-weight="bold">⚡Categories</text>
  <text x="90" y="565" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="8">128MB</text>
  
  <!-- Lambda 2 -->
  <rect x="140" y="530" width="80" height="60" rx="6" fill="url(#awsOrange)" stroke="#FF9900" stroke-width="1"/>
  <text x="180" y="550" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="10" font-weight="bold">⚡Products</text>
  <text x="180" y="565" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="8">256MB</text>
  
  <!-- Lambda 3 -->
  <rect x="230" y="530" width="80" height="60" rx="6" fill="url(#awsOrange)" stroke="#FF9900" stroke-width="1"/>
  <text x="270" y="550" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="10" font-weight="bold">⚡Orders</text>
  <text x="270" y="565" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="8">256MB</text>
  
  <!-- Lambda 4 -->
  <rect x="320" y="530" width="80" height="60" rx="6" fill="url(#awsOrange)" stroke="#FF9900" stroke-width="1"/>
  <text x="360" y="550" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="10" font-weight="bold">⚡Health</text>
  <text x="360" y="565" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="8">128MB</text>
  
  <!-- Lambda 5 -->
  <rect x="410" y="530" width="80" height="60" rx="6" fill="url(#awsOrange)" stroke="#FF9900" stroke-width="1"/>
  <text x="450" y="550" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="10" font-weight="bold">⚡Search</text>
  <text x="450" y="565" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="8">256MB</text>
  
  <!-- DynamoDB -->
  <rect x="50" y="630" width="500" height="80" rx="8" fill="url(#awsBlue)" stroke="#4A90E2" stroke-width="2"/>
  <text x="300" y="660" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="14" font-weight="bold">🗄️ DynamoDB Tables</text>
  <text x="150" y="680" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="10">Categories</text>
  <text x="300" y="680" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="10">Products</text>
  <text x="450" y="680" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="10">Orders</text>
  <text x="300" y="695" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="9">(Pay-per-request)</text>
  
  <!-- CONTAINERIZED SIDE (RIGHT) -->
  <!-- Load Balancer -->
  <rect x="650" y="440" width="500" height="50" rx="8" fill="url(#awsOrange)" stroke="#FF9900" stroke-width="2"/>
  <text x="900" y="470" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="14" font-weight="bold">🔄 Application Load Balancer</text>
  
  <!-- ECS Cluster Header -->
  <text x="900" y="520" text-anchor="middle" fill="#333" font-family="Arial, sans-serif" font-size="12" font-weight="bold">ECS Fargate Cluster</text>
  
  <!-- .NET API Container -->
  <rect x="670" y="530" width="200" height="80" rx="8" fill="url(#dotnetPurple)" stroke="#512BD4" stroke-width="2"/>
  <text x="770" y="550" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="12" font-weight="bold">🔧 .NET 8 Web API</text>
  <text x="770" y="565" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="9">• ASP.NET Core</text>
  <text x="770" y="577" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="9">• Products CRUD</text>
  <text x="770" y="589" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="9">• Swagger UI</text>
  <text x="770" y="601" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="8">Port: 5002 | 512MB</text>
  
  <!-- Node.js API Container -->
  <rect x="890" y="530" width="200" height="80" rx="8" fill="url(#nodeGreen)" stroke="#339933" stroke-width="2"/>
  <text x="990" y="550" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="12" font-weight="bold">🔍 Node.js Search</text>
  <text x="990" y="565" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="9">• Express.js</text>
  <text x="990" y="577" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="9">• Orders API</text>
  <text x="990" y="589" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="9">• Advanced Search</text>
  <text x="990" y="601" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="8">Port: 3001 | 256MB</text>
  
  <!-- Database Layer -->
  <text x="900" y="650" text-anchor="middle" fill="#333" font-family="Arial, sans-serif" font-size="12" font-weight="bold">Database Layer</text>
  
  <!-- PostgreSQL -->
  <rect x="670" y="660" width="200" height="60" rx="8" fill="url(#awsBlue)" stroke="#4A90E2" stroke-width="2"/>
  <text x="770" y="680" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="12" font-weight="bold">🐘 PostgreSQL RDS</text>
  <text x="770" y="695" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="9">Relational Database</text>
  <text x="770" y="707" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="8">ACID • Backup • Multi-AZ</text>
  
  <!-- Elasticsearch -->
  <rect x="890" y="660" width="200" height="60" rx="8" fill="#FFA500" stroke="#FF8C00" stroke-width="2"/>
  <text x="990" y="680" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="12" font-weight="bold">🔍 Elasticsearch</text>
  <text x="990" y="695" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="9">Advanced Search</text>
  <text x="990" y="707" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="8">Analytics • Aggregations</text>
  
  <!-- Connection Lines - Serverless -->
  <line x1="300" y1="490" x2="300" y2="530" stroke="#333" stroke-width="2" marker-end="url(#arrowhead)"/>
  <line x1="180" y1="590" x2="200" y2="630" stroke="#333" stroke-width="2" marker-end="url(#arrowhead)"/>
  <line x1="270" y1="590" x2="300" y2="630" stroke="#333" stroke-width="2" marker-end="url(#arrowhead)"/>
  <line x1="360" y1="590" x2="400" y2="630" stroke="#333" stroke-width="2" marker-end="url(#arrowhead)"/>
  
  <!-- Connection Lines - Containerized -->
  <line x1="900" y1="490" x2="900" y2="530" stroke="#333" stroke-width="2" marker-end="url(#arrowhead)"/>
  <line x1="770" y1="610" x2="770" y2="660" stroke="#333" stroke-width="2" marker-end="url(#arrowhead)"/>
  <line x1="990" y1="610" x2="990" y2="660" stroke="#333" stroke-width="2" marker-end="url(#arrowhead)"/>
  
  <!-- Monitoring Layer -->
  <rect x="50" y="760" width="500" height="50" rx="8" fill="#232F3E" stroke="#FF9900" stroke-width="2"/>
  <text x="300" y="790" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="12" font-weight="bold">📊 CloudWatch + X-Ray</text>
  
  <rect x="650" y="760" width="500" height="50" rx="8" fill="#232F3E" stroke="#FF9900" stroke-width="2"/>
  <text x="900" y="790" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="12" font-weight="bold">📊 CloudWatch + Application Insights</text>
  
  <!-- Monitoring Arrows -->
  <line x1="300" y1="710" x2="300" y2="760" stroke="#333" stroke-width="2" marker-end="url(#arrowhead)"/>
  <line x1="900" y1="720" x2="900" y2="760" stroke="#333" stroke-width="2" marker-end="url(#arrowhead)"/>
  
  <!-- Comparison Table -->
  <rect x="50" y="850" width="1100" height="200" rx="10" fill="white" stroke="#ddd" stroke-width="2"/>
  <text x="600" y="880" text-anchor="middle" fill="#333" font-family="Arial, sans-serif" font-size="16" font-weight="bold">📊 Architecture Comparison</text>
  
  <!-- Table Headers -->
  <text x="100" y="910" fill="#333" font-family="Arial, sans-serif" font-size="12" font-weight="bold">Feature</text>
  <text x="400" y="910" fill="#FF9900" font-family="Arial, sans-serif" font-size="12" font-weight="bold">Serverless (Lambda)</text>
  <text x="800" y="910" fill="#512BD4" font-family="Arial, sans-serif" font-size="12" font-weight="bold">Containerized (.NET + Node.js)</text>
  
  <!-- Table Rows -->
  <text x="100" y="930" fill="#333" font-family="Arial, sans-serif" font-size="10">Cost</text>
  <text x="400" y="930" fill="#333" font-family="Arial, sans-serif" font-size="10">$1-5/month</text>
  <text x="800" y="930" fill="#333" font-family="Arial, sans-serif" font-size="10">$30-50/month</text>
  
  <text x="100" y="950" fill="#333" font-family="Arial, sans-serif" font-size="10">Scaling</text>
  <text x="400" y="950" fill="#333" font-family="Arial, sans-serif" font-size="10">Auto (0-1000+)</text>
  <text x="800" y="950" fill="#333" font-family="Arial, sans-serif" font-size="10">Manual/Auto (1-10+)</text>
  
  <text x="100" y="970" fill="#333" font-family="Arial, sans-serif" font-size="10">Maintenance</text>
  <text x="400" y="970" fill="#333" font-family="Arial, sans-serif" font-size="10">Zero</text>
  <text x="800" y="970" fill="#333" font-family="Arial, sans-serif" font-size="10">Moderate</text>
  
  <text x="100" y="990" fill="#333" font-family="Arial, sans-serif" font-size="10">Database</text>
  <text x="400" y="990" fill="#333" font-family="Arial, sans-serif" font-size="10">DynamoDB (NoSQL)</text>
  <text x="800" y="990" fill="#333" font-family="Arial, sans-serif" font-size="10">PostgreSQL + Elasticsearch</text>
  
  <text x="100" y="1010" fill="#333" font-family="Arial, sans-serif" font-size="10">Best For</text>
  <text x="400" y="1010" fill="#333" font-family="Arial, sans-serif" font-size="10">Variable traffic, MVP</text>
  <text x="800" y="1010" fill="#333" font-family="Arial, sans-serif" font-size="10">Enterprise, consistent load</text>
  
  <!-- Deployment Commands -->
  <rect x="50" y="1100" width="1100" height="120" rx="10" fill="#f8f9fa" stroke="#ddd" stroke-width="1"/>
  <text x="600" y="1130" text-anchor="middle" fill="#333" font-family="Arial, sans-serif" font-size="16" font-weight="bold">🚀 Deployment Commands</text>
  
  <!-- Serverless Commands -->
  <text x="100" y="1160" fill="#FF9900" font-family="Arial, sans-serif" font-size="12" font-weight="bold">Serverless Deployment:</text>
  <text x="100" y="1175" fill="#333" font-family="Monaco, monospace" font-size="10">cd backend/serverless</text>
  <text x="100" y="1190" fill="#333" font-family="Monaco, monospace" font-size="10">sam deploy --stack-name shopping-cart</text>
  
  <!-- Container Commands -->
  <text x="100" y="1210" fill="#512BD4" font-family="Arial, sans-serif" font-size="12" font-weight="bold">Container Deployment:</text>
  <text x="100" y="1225" fill="#333" font-family="Monaco, monospace" font-size="10">cd infrastructure</text>
  <text x="100" y="1240" fill="#333" font-family="Monaco, monospace" font-size="10">./deploy-everything.sh</text>
  
  <!-- URLs -->
  <text x="600" y="1280" text-anchor="middle" fill="#333" font-family="Arial, sans-serif" font-size="12" font-weight="bold">Both options include complete CI/CD pipelines with GitHub Actions</text>
  
  <!-- Tech Stack Icons -->
  <text x="50" y="1320" fill="#333" font-family="Arial, sans-serif" font-size="12" font-weight="bold">🛠️ Technology Stack:</text>
  <text x="50" y="1340" fill="#333" font-family="Arial, sans-serif" font-size="10">📱 React 18 + TypeScript + Redux • 🔧 .NET 8 + ASP.NET Core • 🟢 Node.js + Express • ☁️ AWS Services • 🔄 GitHub Actions</text>
  
  <!-- Footer -->
  <text x="600" y="1380" text-anchor="middle" fill="#666" font-family="Arial, sans-serif" font-size="10">Built with ❤️ demonstrating modern DevOps practices with both serverless and traditional architectures</text>
</svg>

</div>
## 🚀 DevOps Pipeline Stages

### 1. Source Stage

- **Trigger**: Push to `main` branch
- **Repository**: GitHub with branch protection
- **Webhook**: Automatic trigger to GitHub Actions

### 2. Build & Test Stage

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Test Frontend
        run: |
          cd frontend
          npm ci
          npm run test:coverage
          npm run lint
          npm run type-check

      - name: Test Backend
        run: |
          cd backend/serverless
          npm ci
          npm test
          npm run integration-test
```

### 3. Infrastructure Deployment

```yaml
deploy-infrastructure:
  needs: test
  steps:
    - name: Deploy SAM Stack
      run: |
        sam build
        sam deploy --stack-name shopping-cart-prod
```

### 4. Application Deployment

```yaml
deploy-application:
  needs: deploy-infrastructure
  steps:
    - name: Deploy Frontend
      run: |
        cd frontend
        npm run build
        aws s3 sync build/ s3://$BUCKET_NAME
```

### 5. Post-Deployment Validation

- Health check endpoints
- Integration tests
- Performance validation
- Security scanning

## 📦 Project Structure

```
shopping-cart-fullstack/
├── 📁 .github/workflows/           # GitHub Actions CI/CD
│   ├── deploy-serverless.yml       # Serverless deployment pipeline
│   └── deploy-ecs.yml              # Container deployment pipeline
├── 📁 frontend/                    # React Application
│   ├── 📁 src/
│   │   ├── 📁 components/          # Reusable UI components
│   │   ├── 📁 pages/               # Route components
│   │   ├── 📁 store/               # Redux state management
│   │   ├── 📁 services/            # API integration layer
│   │   └── 📁 types/               # TypeScript definitions
│   ├── package.json
│   └── tsconfig.json
├── 📁 backend/
│   ├── 📁 serverless/              # AWS Lambda Functions
│   │   ├── 📄 template.yaml        # SAM Infrastructure as Code
│   │   └── 📁 src/
│   │       ├── 📁 categories/      # Categories API Lambda
│   │       ├── 📁 products/        # Products API Lambda
│   │       ├── 📁 orders/          # Orders API Lambda
│   │       ├── 📁 health/          # Health Check Lambda
│   │       └── 📁 seed/            # Database Seeding Lambda
│   ├── 📁 dotnet-api/              # .NET Web API (Alternative)
│   └── 📁 nodejs-search/           # Node.js Search Service
├── 📁 infrastructure/              # Infrastructure as Code
│   ├── ecs-infrastructure.yaml     # ECS CloudFormation
│   └── ecs-services.yaml           # ECS Services Configuration
├── 📁 scripts/                     # Utility scripts
│   ├── verify-setup.sh             # Environment verification
│   ├── setup-local-dev.sh          # Local development setup
│   └── deploy-everything.sh        # Manual deployment script
├── 📄 README.md                    # This file
├── 📄 package.json                 # Project configuration
└── 📄 .gitignore                   # Git ignore rules
```

## 🛠️ Local Development Setup

### Prerequisites

- Node.js 18+
- .NET 8 SDK
- AWS CLI configured
- SAM CLI (for serverless development)
- Git

### Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/tsahirosenbaom/shopping-cart-fullstack.git
cd shopping-cart-fullstack

# 2. Verify your setup
npm run verify

# 3. Install all dependencies
npm run setup-local

# 4. Start development servers (separate terminals)
npm run dev:frontend    # React app on :3000
npm run dev:backend     # .NET API on :5002
npm run dev:search      # Node.js API on :3001
npm run dev:serverless  # Lambda local on :3000
```

### Available Scripts

```bash
# Development
npm run dev:frontend     # Start React development server
npm run dev:backend      # Start .NET API server
npm run dev:search       # Start Node.js search API
npm run dev:serverless   # Start SAM local API

# Testing
npm run test:all         # Run all tests
npm run test:frontend    # Test React components
npm run test:backend     # Test .NET API
npm run test:integration # End-to-end tests

# Building
npm run build:frontend   # Build React for production
npm run build:backend    # Build .NET API

# Deployment
npm run deploy:serverless # Deploy serverless stack
npm run deploy:ecs       # Deploy ECS stack

# Utilities
npm run verify           # Verify local setup
npm run setup-local      # Install all dependencies
```

## 🌐 API Documentation

### Base URLs

- **Production**: `https://api.shopping-cart.example.com`
- **Staging**: `https://staging-api.shopping-cart.example.com`
- **Local**: `http://localhost:3000` (SAM Local)

### Endpoints

#### Categories API

```http
GET    /api/categories           # List all categories
POST   /api/categories           # Create new category
PUT    /api/categories/{id}      # Update category
DELETE /api/categories/{id}      # Delete category
```

#### Products API

```http
GET    /api/products             # List all products
GET    /api/products/{id}        # Get product by ID
GET    /api/products/search      # Search products (?query=term)
POST   /api/products             # Create new product
PUT    /api/products/{id}        # Update product
DELETE /api/products/{id}        # Delete product
```

#### Orders API

```http
GET    /api/orders               # List orders
GET    /api/orders/{id}          # Get order by ID
POST   /api/orders               # Create new order
PUT    /api/orders/{id}          # Update order status
```

#### Health Check

```http
GET    /health                   # System health status
```

### Sample API Response

```json
{
  "status": "success",
  "data": {
    "id": 1,
    "name": "Gaming Laptop",
    "description": "High-performance gaming laptop",
    "price": 1299.99,
    "categoryId": 1,
    "stock": 50,
    "createdAt": "2025-01-20T10:30:00Z"
  }
}
```

## 🧪 Testing Strategy

### Frontend Testing

- **Unit Tests**: Jest + React Testing Library
- **Component Tests**: Isolated component testing
- **Integration Tests**: API integration testing
- **E2E Tests**: Cypress for user workflow testing

### Backend Testing

- **Unit Tests**: Jest for Lambda functions
- **Integration Tests**: API Gateway + Lambda integration
- **Contract Tests**: API contract validation
- **Performance Tests**: Load testing with Artillery

### Test Coverage Targets

- **Frontend**: > 80% code coverage
- **Backend**: > 85% code coverage
- **Integration**: All critical user paths

## 🔒 Security & Best Practices

### Security Measures

- **Authentication**: JWT-based authentication
- **Authorization**: Role-based access control
- **Input Validation**: Comprehensive input sanitization
- **CORS**: Properly configured CORS policies
- **Rate Limiting**: API rate limiting to prevent abuse
- **HTTPS**: All traffic encrypted in transit
- **Secrets Management**: AWS Secrets Manager for sensitive data

### Code Quality

- **TypeScript**: Type safety across the application
- **ESLint**: Code linting with strict rules
- **Prettier**: Consistent code formatting
- **Husky**: Pre-commit hooks for quality gates
- **SonarQube**: Static code analysis (optional)

### Infrastructure Security

- **IAM**: Least privilege access policies
- **VPC**: Network isolation (when applicable)
- **Encryption**: At-rest and in-transit encryption
- **Monitoring**: Comprehensive logging and alerting

## 📊 Performance & Monitoring

### Key Metrics

- **Response Time**: < 200ms average API response
- **Availability**: 99.9% uptime target
- **Error Rate**: < 0.1% error rate
- **Throughput**: 1000+ requests per second capacity

### Monitoring Stack

- **CloudWatch**: AWS native monitoring
- **X-Ray**: Distributed tracing
- **Custom Metrics**: Business metrics tracking
- **Alerting**: PagerDuty/Slack integration

### Performance Optimizations

- **CDN**: Global content distribution
- **Caching**: Multi-layer caching strategy
- **Database**: Optimized queries and indexes
- **Lambda**: Right-sized memory allocation
- **API Gateway**: Response caching enabled

## 💰 Cost Analysis

### Monthly Cost Breakdown (Estimated)

```
🏗️ Infrastructure Costs:
├── AWS Lambda (1M requests)      $0.20
├── API Gateway (1M requests)     $3.50
├── DynamoDB (1M RW requests)     $1.25
├── Amplify Hosting (5GB)         $0.50
├── CloudFront (100GB transfer)   $8.50
├── CloudWatch Logs (10GB)        $2.50
└── Miscellaneous                 $3.55
                                --------
💰 Total Estimated Cost          ~$20/month
```

### Cost Optimization Strategies

- **Pay-per-use**: Serverless architecture scales to zero
- **Reserved Capacity**: For predictable workloads
- **Caching**: Reduce API calls and database requests
- **Monitoring**: Track and optimize high-cost operations
- **Right-sizing**: Optimal Lambda memory allocation

## 🚀 Deployment Options

### Option 1: Serverless (Recommended)

- **Cost**: $5-20/month
- **Scaling**: Automatic (0 to millions)
- **Maintenance**: Minimal
- **Best for**: Variable traffic, cost optimization

### Option 2: Container (ECS)

- **Cost**: $30-50/month
- **Scaling**: Manual/Auto-scaling
- **Maintenance**: Moderate
- **Best for**: Consistent traffic, enterprise requirements

## 🌍 Environment Strategy

### Development Environment

- **Local**: Full stack running locally
- **Services**: Mock services and local databases
- **Testing**: Unit and integration tests

### Staging Environment

- **Purpose**: Pre-production validation
- **Data**: Synthetic test data
- **Testing**: Full regression testing

### Production Environment

- **High Availability**: Multi-AZ deployment
- **Monitoring**: Full observability stack
- **Backup**: Automated backup and recovery

## 📈 Scalability & Performance

### Auto Scaling Configuration

```yaml
# Lambda Auto Scaling
ReservedConcurrency: 100
ProvisionedConcurrency: 10

# API Gateway Throttling
ThrottleSettings:
  BurstLimit: 2000
  RateLimit: 1000

# DynamoDB Auto Scaling
BillingMode: PAY_PER_REQUEST
```

### Performance Benchmarks

- **Cold Start**: < 500ms
- **Warm Requests**: < 100ms
- **Database Queries**: < 50ms
- **Page Load**: < 2 seconds

## 🤝 Contributing

### Development Workflow

1. **Fork** the repository
2. **Create** feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** changes (`git commit -m 'Add amazing feature'`)
4. **Push** branch (`git push origin feature/amazing-feature`)
5. **Open** Pull Request

### Code Standards

- Follow TypeScript/JavaScript style guide
- Write meaningful commit messages
- Include tests for new features
- Update documentation as needed

### Pull Request Process

1. Ensure all tests pass
2. Update README if needed
3. Request review from maintainers
4. Address review feedback
5. Squash commits before merge

## 📚 Additional Resources

### Documentation

- [AWS SAM Developer Guide](https://docs.aws.amazon.com/serverless-application-model/)
- [React Documentation](https://reactjs.org/docs/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)

### Useful Links

- **Live Application**: [Production URL]
- **Staging Environment**: [Staging URL]
- **API Documentation**: [API Docs URL]
- **Monitoring Dashboard**: [CloudWatch URL]
- **CI/CD Pipeline**: [GitHub Actions URL]

## 🐛 Troubleshooting

### Common Issues

#### Local Development

```bash
# Port already in use
npm run verify                    # Check port availability
lsof -ti:3000 | xargs kill -9    # Kill process on port 3000

# Dependencies issues
npm run setup-local               # Reinstall all dependencies
npm cache clean --force           # Clear npm cache
```

#### Deployment Issues

```bash
# AWS credentials
aws sts get-caller-identity       # Verify AWS access
aws configure list                # Check configuration

# SAM deployment
sam build                         # Build SAM application
sam deploy --debug               # Deploy with debug info
```

#### API Issues

```bash
# Test API endpoints
curl https://api-url/health       # Health check
npm run test:integration         # Run integration tests
```

## 📞 Support & Contact

### Getting Help

- **Issues**: Create GitHub issue for bugs
- **Questions**: Use GitHub discussions
- **Security**: Email security@example.com
- **General**: Contact team@example.com

### Maintainers

- **Tsahi Rosenbaum** - [@tsahirosenbaom](https://github.com/tsahirosenbaom)

---

## 🎉 Acknowledgments

Built with ❤️ using modern DevOps practices and cloud-native technologies.

**⭐ If this project helped you, please give it a star!**

---

_Last updated: January 2025_
