#!/bin/bash

echo "🚀 Starting Node.js Search API"
echo "=============================="

cd /mnt/c/Users/tsahi/VC/shopping-cart-fullstack

if [ -f "backend/nodejs-search/package.json" ]; then
    cd backend/nodejs-search
    echo "🔍 Starting Node.js search server..."
    echo "🌐 Will run at: http://localhost:3001"
    echo ""
    npm start
else
    echo "❌ Node.js Search API not found at backend/nodejs-search/package.json"
    echo "Please copy your Node.js API to the backend/nodejs-search/ directory"
fi
