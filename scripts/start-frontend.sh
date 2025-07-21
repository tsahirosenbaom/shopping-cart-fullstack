#!/bin/bash

echo "🚀 Starting React Frontend"
echo "=========================="

cd /mnt/c/Users/tsahi/VC/shopping-cart-fullstack

if [ -f "frontend/package.json" ]; then
    cd frontend
    echo "📱 Starting React development server..."
    echo "🌐 Will open at: http://localhost:3000"
    echo ""
    npm start
else
    echo "❌ Frontend not found at frontend/package.json"
    echo "Please copy your React app to the frontend/ directory"
fi
