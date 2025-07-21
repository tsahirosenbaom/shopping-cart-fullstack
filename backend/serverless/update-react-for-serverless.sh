#!/bin/bash

echo "⚛️ Updating React app for serverless backend..."

# Load deployment info
if [ ! -f "serverless-deployment.txt" ]; then
    echo "❌ Deployment info not found. Please deploy serverless stack first."
    exit 1
fi

source serverless-deployment.txt

# Update React app API configuration
cd ~/shopping-cart-app

# Create production environment file
cat > .env.production << ENVEOF
REACT_APP_API_BASE_URL=$API_URL
REACT_APP_ORDERS_API_BASE_URL=$API_URL
ENVEOF

# Update API services to use serverless endpoints
cat > src/services/api.ts << 'APIEOF'
import axios from 'axios';
import { Category, Product, CreateProductRequest, Order, CreateOrderRequest } from '../types';

const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || 'http://localhost:3000';

// Category API
export const categoryAPI = {
  getAll: async (): Promise<Category[]> => {
    const response = await axios.get(`${API_BASE_URL}/api/categories`);
    return response.data;
  },
};

// Product API  
export const productAPI = {
  getAll: async (): Promise<Product[]> => {
    const response = await axios.get(`${API_BASE_URL}/api/products`);
    return response.data;
  },

  create: async (product: CreateProductRequest): Promise<Product> => {
    const response = await axios.post(`${API_BASE_URL}/api/products`, product);
    return response.data;
  },

  search: async (query: string): Promise<Product[]> => {
    const response = await axios.get(`${API_BASE_URL}/api/products/search?query=${query}`);
    return response.data;
  }
};

// Order API
export const orderAPI = {
  create: async (order: CreateOrderRequest): Promise<Order> => {
    const response = await axios.post(`${API_BASE_URL}/api/orders`, order);
    return response.data;
  },

  getAll: async (): Promise<Order[]> => {
    const response = await axios.get(`${API_BASE_URL}/api/orders`);
    return response.data;
  },

  getById: async (id: string): Promise<Order> => {
    const response = await axios.get(`${API_BASE_URL}/api/orders/${id}`);
    return response.data;
  }
};
APIEOF

echo "✅ React app updated for serverless backend!"
echo "🌐 API URL: $API_URL"
echo ""
echo "🚀 To deploy React app:"
echo "npm run build"
echo ""
echo "📝 Or update your existing React deployment:"
echo "cd ~/aws-deployment && ./deploy-react.sh"
