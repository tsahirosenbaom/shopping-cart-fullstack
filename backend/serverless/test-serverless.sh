#!/bin/bash

echo "🧪 Testing Serverless Shopping Cart..."

# Load deployment info
if [ ! -f "serverless-deployment.txt" ]; then
    echo "❌ Deployment info not found. Please deploy first."
    exit 1
fi

source serverless-deployment.txt

echo "🌐 Testing API: $API_URL"
echo ""

# Test health endpoint
echo "1️⃣ Testing Health Check..."
curl -s "$API_URL/health" | jq . || echo "Failed"
echo ""

# Test categories
echo "2️⃣ Testing Categories..."
curl -s "$API_URL/api/categories" | jq . || echo "Failed"
echo ""

# Test products
echo "3️⃣ Testing Products..."
curl -s "$API_URL/api/products" | jq . || echo "Failed"
echo ""

# Test product search
echo "4️⃣ Testing Product Search..."
curl -s "$API_URL/api/products/search?query=לפטופ" | jq . || echo "Failed"
echo ""

# Test create order
echo "5️⃣ Testing Order Creation..."
curl -s -X POST "$API_URL/api/orders" \
  -H "Content-Type: application/json" \
  -d '{
    "customer": {
      "firstName": "יוסי",
      "lastName": "כהן",
      "address": "רחוב הרצל 123, תל אביב",
      "email": "yossi@example.com"
    },
    "items": [
      {
        "id": "1",
        "productName": "לפטופ גיימינג",
        "categoryId": 1,
        "categoryName": "אלקטרוניקה",
        "quantity": 1,
        "addedAt": "2025-07-20T16:00:00.000Z"
      }
    ],
    "totalItems": 1
  }' | jq . || echo "Failed"
echo ""

# Test get orders
echo "6️⃣ Testing Get Orders..."
curl -s "$API_URL/api/orders" | jq . || echo "Failed"
echo ""

echo "✅ Testing completed!"
