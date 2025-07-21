#!/bin/bash

echo "🔍 VERIFYING SHOPPING CART SETUP"
echo "================================="

PROJECT_DIR="/mnt/c/Users/tsahi/VC/shopping-cart-fullstack"
cd "$PROJECT_DIR"

# Check directory structure
echo ""
echo "📁 Directory Structure:"
echo "======================"

components_found=0
total_components=4

# Check frontend
if [ -d "frontend" ]; then
    echo "✅ frontend/"
    if [ -f "frontend/package.json" ]; then
        echo "  ✅ package.json found"
        if [ -f "frontend/src/App.js" ] || [ -f "frontend/src/App.tsx" ]; then
            echo "  ✅ App component found"
        fi
        components_found=$((components_found + 1))
        
        # Show React project details
        cd frontend
        PROJECT_NAME=$(node -p "require('./package.json').name" 2>/dev/null || echo "Unknown")
        echo "  📦 Project: $PROJECT_NAME"
        cd ..
    else
        echo "  ❌ package.json missing"
    fi
    
    # Check if dependencies are installed
    if [ -d "frontend/node_modules" ]; then
        echo "  ✅ Dependencies installed"
    else
        echo "  ⚠️ Dependencies not installed (run: npm install)"
    fi
else
    echo "❌ frontend/ missing"
fi

# Check .NET API
if [ -d "backend/dotnet-api" ]; then
    echo "✅ backend/dotnet-api/"
    if ls backend/dotnet-api/*.csproj 1> /dev/null 2>&1; then
        echo "  ✅ .csproj found"
        PROJECT_NAME=$(ls backend/dotnet-api/*.csproj | head -1 | xargs basename -s .csproj)
        echo "  🔧 Project: $PROJECT_NAME"
        components_found=$((components_found + 1))
        
        # Check if project builds
        cd backend/dotnet-api
        if dotnet build --verbosity quiet >/dev/null 2>&1; then
            echo "  ✅ Project builds successfully"
        else
            echo "  ⚠️ Build issues (run: dotnet restore)"
        fi
        cd ../..
    else
        echo "  ❌ .csproj missing"
    fi
else
    echo "❌ backend/dotnet-api/ missing"
fi

# Check Node.js Search API
if [ -d "backend/nodejs-search" ]; then
    echo "✅ backend/nodejs-search/"
    if [ -f "backend/nodejs-search/package.json" ]; then
        echo "  ✅ package.json found"
        if [ -f "backend/nodejs-search/server.js" ] || [ -f "backend/nodejs-search/index.js" ]; then
            echo "  ✅ Main server file found"
        fi
        components_found=$((components_found + 1))
        
        # Check dependencies
        if [ -d "backend/nodejs-search/node_modules" ]; then
            echo "  ✅ Dependencies installed"
        else
            echo "  ⚠️ Dependencies not installed"
        fi
    else
        echo "  ❌ package.json missing"
    fi
else
    echo "❌ backend/nodejs-search/ missing"
fi

# Check Serverless Functions
if [ -d "backend/serverless" ]; then
    echo "✅ backend/serverless/"
    if [ -f "backend/serverless/template.yaml" ]; then
        echo "  ✅ template.yaml found"
        components_found=$((components_found + 1))
    else
        echo "  ❌ template.yaml missing"
    fi
    
    if [ -d "backend/serverless/src" ]; then
        LAMBDA_COUNT=$(find backend/serverless/src -name "index.js" 2>/dev/null | wc -l)
        echo "  ⚡ $LAMBDA_COUNT Lambda functions found"
        
        # List Lambda functions
        if [ $LAMBDA_COUNT -gt 0 ]; then
            echo "    Functions:"
            find backend/serverless/src -name "index.js" | while read func; do
                func_name=$(dirname "$func" | xargs basename)
                echo "    - $func_name"
            done
        fi
    else
        echo "  ❌ src/ directory missing"
    fi
else
    echo "❌ backend/serverless/ missing"
fi

# Check prerequisites
echo ""
echo "🛠️ Prerequisites Check:"
echo "======================="

prereq_count=0
total_prereq=6

if command -v node &> /dev/null; then
    echo "✅ Node.js: $(node --version)"
    prereq_count=$((prereq_count + 1))
else
    echo "❌ Node.js not found - Download from https://nodejs.org/"
fi

if command -v npm &> /dev/null; then
    echo "✅ npm: $(npm --version)"
    prereq_count=$((prereq_count + 1))
else
    echo "❌ npm not found"
fi

if command -v dotnet &> /dev/null; then
    echo "✅ .NET: $(dotnet --version)"
    prereq_count=$((prereq_count + 1))
else
    echo "❌ .NET SDK not found - Download from https://dotnet.microsoft.com/download"
fi

if command -v git &> /dev/null; then
    echo "✅ Git: $(git --version)"
    prereq_count=$((prereq_count + 1))
else
    echo "❌ Git not found"
fi

if command -v aws &> /dev/null; then
    echo "✅ AWS CLI: $(aws --version | head -1)"
    prereq_count=$((prereq_count + 1))
else
    echo "⚠️ AWS CLI not found (needed for deployment)"
    echo "   Install: pip install awscli"
fi

if command -v sam &> /dev/null; then
    echo "✅ SAM CLI: $(sam --version)"
    prereq_count=$((prereq_count + 1))
else
    echo "⚠️ SAM CLI not found (needed for serverless)"
    echo "   Install: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html"
fi

# Port availability check
echo ""
echo "🌐 Port Availability:"
echo "===================="

check_port() {
    local port=$1
    local service=$2
    
    if command -v netstat >/dev/null 2>&1; then
        if netstat -tln | grep -q ":$port "; then
            echo "⚠️ Port $port is in use ($service)"
        else
            echo "✅ Port $port available ($service)"
        fi
    elif command -v ss >/dev/null 2>&1; then
        if ss -tln | grep -q ":$port "; then
            echo "⚠️ Port $port is in use ($service)"
        else
            echo "✅ Port $port available ($service)"
        fi
    else
        echo "? Port $port ($service) - cannot check"
    fi
}

check_port 3000 "React Frontend"
check_port 5002 ".NET API"
check_port 3001 "Node.js Search"

# Summary
echo ""
echo "📊 SUMMARY"
echo "=========="

echo "Components: $components_found/$total_components found"
echo "Prerequisites: $prereq_count/$total_prereq installed"

if [ $components_found -eq $total_components ] && [ $prereq_count -ge 4 ]; then
    echo ""
    echo "🎉 Setup looks great! You can proceed with:"
    echo "   npm run setup-local  # Install dependencies"
    echo "   npm run dev:frontend # Start React app"
    echo "   npm run dev:backend  # Start .NET API"
    echo ""
elif [ $components_found -lt $total_components ]; then
    echo ""
    echo "⚠️ Missing components detected"
    echo "📝 Action needed:"
    echo "1. Copy missing components to their directories"
    echo "2. Run this verification again: npm run verify"
    echo ""
else
    echo ""
    echo "⚠️ Some prerequisites missing"
    echo "📝 Install missing tools and run again"
    echo ""
fi

# Quick start guide
echo "🚀 Quick Commands:"
echo "=================="
echo "npm run setup-local  # Install all dependencies"
echo "npm run dev:frontend # Start React (port 3000)"
echo "npm run dev:backend  # Start .NET API (port 5002)"
echo "npm run dev:search   # Start Node.js (port 3001)"
echo "npm run test:all     # Run all tests"
