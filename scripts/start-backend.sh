#!/bin/bash

echo "🚀 Starting .NET API"
echo "==================="

cd /mnt/c/Users/tsahi/VC/shopping-cart-fullstack

if ls backend/dotnet-api/ProductApi/*.csproj 1> /dev/null 2>&1; then
    cd backend/dotnet-api/ProductApi
    echo "🔧 Starting .NET development server..."
    echo "🌐 Will open at: http://localhost:5002"
    echo "📊 Swagger UI at: http://localhost:5002/swagger"
    echo ""
    dotnet run --urls "http://localhost:5002"
else
    echo "❌ .NET API not found at backend/dotnet-api/*.csproj"
    echo "Please copy your .NET API to the backend/dotnet-api/ directory"
fi
