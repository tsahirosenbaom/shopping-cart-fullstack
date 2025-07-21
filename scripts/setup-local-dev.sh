#!/bin/bash

echo "🛠️ SETTING UP LOCAL DEVELOPMENT"
echo "==============================="

PROJECT_DIR="/mnt/c/Users/tsahi/VC/shopping-cart-fullstack"
cd "$PROJECT_DIR"

installation_success=0

# Install frontend dependencies
echo ""
echo "1️⃣ Frontend Dependencies"
echo "========================"
if [ -d "frontend" ] && [ -f "frontend/package.json" ]; then
    echo "📱 Installing React app dependencies..."
    cd frontend
    
    if npm install; then
        echo "✅ Frontend dependencies installed successfully"
        installation_success=$((installation_success + 1))
        
        # Show installed packages count
        PACKAGE_COUNT=$(npm list --depth=0 2>/dev/null | grep -c "├\|└" || echo "0")
        echo "   📦 $PACKAGE_COUNT packages installed"
    else
        echo "❌ Frontend dependency installation failed"
        echo "   Try: cd frontend && npm cache clean --force && npm install"
    fi
    cd ..
else
    echo "⚠️ Frontend directory or package.json not found"
    echo "   Expected: frontend/package.json"
fi

# Install Node.js backend dependencies
echo ""
echo "2️⃣ Node.js Search API Dependencies"  
echo "=================================="
if [ -d "backend/nodejs-search" ] && [ -f "backend/nodejs-search/package.json" ]; then
    echo "🔍 Installing Node.js search API dependencies..."
    cd backend/nodejs-search
    
    if npm install; then
        echo "✅ Node.js search API dependencies installed"
        installation_success=$((installation_success + 1))
    else
        echo "❌ Node.js search API dependency installation failed"
    fi
    cd ../..
else
    echo "⚠️ Node.js search API directory or package.json not found"
    echo "   Expected: backend/nodejs-search/package.json"
fi

# Restore .NET dependencies
echo ""
echo "3️⃣ .NET API Dependencies"
echo "========================"
if [ -d "backend/dotnet-api" ] && ls backend/dotnet-api/*.csproj 1> /dev/null 2>&1; then
    echo "🔧 Restoring .NET API dependencies..."
    cd backend/dotnet-api
    
    if dotnet restore; then
        echo "✅ .NET API dependencies restored"
        installation_success=$((installation_success + 1))
        
        # Try to build the project
        echo "   🏗️ Testing build..."
        if dotnet build --verbosity quiet; then
            echo "   ✅ Project builds successfully"
        else
            echo "   ⚠️ Build has warnings/errors"
        fi
    else
        echo "❌ .NET dependency restoration failed"
        echo "   Check that you have .NET 8 SDK installed"
    fi
    cd ../..
else
    echo "⚠️ .NET API directory or project file not found"
    echo "   Expected: backend/dotnet-api/*.csproj"
fi

# Install serverless dependencies
echo ""
echo "4️⃣ Serverless Functions Dependencies"
echo "===================================="
if [ -d "backend/serverless/src" ]; then
    echo "⚡ Installing Lambda function dependencies..."
    cd backend/serverless
    
    lambda_success=0
    lambda_total=0
    
    for func in src/*/; do
        if [ -f "$func/package.json" ]; then
            lambda_total=$((lambda_total + 1))
            func_name=$(basename "$func")
            echo "   Installing dependencies for $func_name..."
            
            cd "$func"
            if npm install --production; then
                echo "   ✅ $func_name dependencies installed"
                lambda_success=$((lambda_success + 1))
            else
                echo "   ❌ $func_name dependency installation failed"
            fi
            cd ../..
        fi
    done
    
    if [ $lambda_success -eq $lambda_total ] && [ $lambda_total -gt 0 ]; then
        echo "✅ All Lambda function dependencies installed ($lambda_success/$lambda_total)"
        installation_success=$((installation_success + 1))
    elif [ $lambda_total -eq 0 ]; then
        echo "⚠️ No Lambda functions with package.json found"
    else
        echo "⚠️ Some Lambda function dependencies failed ($lambda_success/$lambda_total)"
    fi
    
    cd ../..
else
    echo "⚠️ Serverless functions directory not found"
    echo "   Expected: backend/serverless/src/"
fi

# Summary and next steps
echo ""
echo "📊 INSTALLATION SUMMARY"
echo "======================="

total_components=4
echo "Successfully set up: $installation_success/$total_components components"

if [ $installation_success -eq $total_components ]; then
    echo ""
    echo "🎉 All dependencies installed successfully!"
    echo ""
    echo "🚀 You can now start development:"
    echo "================================="
    echo "npm run dev:frontend    # React app (http://localhost:3000)"
    echo "npm run dev:backend     # .NET API (http://localhost:5002)"
    echo "npm run dev:search      # Node.js API (http://localhost:3001)"
    echo "npm run dev:serverless  # Lambda local (http://localhost:3000)"
    echo ""
    echo "🧪 Test everything works:"
    echo "========================="
    echo "npm run test:frontend   # Run React tests"
    echo "npm run test:backend    # Run .NET tests"
    echo ""
elif [ $installation_success -gt 0 ]; then
    echo ""
    echo "⚠️ Partial setup completed"
    echo "Some components may have issues - check error messages above"
    echo ""
    echo "🔧 Try these troubleshooting steps:"
    echo "- Ensure all prerequisites are installed"
    echo "- Clear npm cache: npm cache clean --force"
    echo "- For .NET issues: dotnet --list-sdks"
    echo ""
else
    echo ""
    echo "❌ Setup encountered issues"
    echo "Please check error messages above and:"
    echo "1. Verify all components are copied correctly"
    echo "2. Install missing prerequisites" 
    echo "3. Run npm run verify to check setup"
    echo ""
fi

# Development tips
echo "💡 Development Tips:"
echo "==================="
echo "• Use separate terminals for each service"
echo "• Frontend auto-reloads on changes"
echo "• Check browser console for React errors"
echo "• Use Swagger UI for API testing"
echo "• Monitor server logs for debugging"
