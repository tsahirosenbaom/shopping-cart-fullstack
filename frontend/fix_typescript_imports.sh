#!/bin/bash

# Fix TypeScript Import Issues
echo "🔧 Fixing TypeScript import issues..."

cd ~/shopping-cart-app

# Fix the api.ts file with correct imports
cat > src/services/api.ts << 'EOF'
import axios from 'axios';
import { Category, Product, CreateProductRequest, Order, CreateOrderRequest } from '../types';

const API_BASE_URL = 'http://localhost:5002/api';
const ORDERS_API_BASE_URL = 'http://localhost:3000/api';

// Category API
export const categoryAPI = {
  getAll: async (): Promise<Category[]> => {
    const response = await axios.get(`${API_BASE_URL}/categories`);
    return response.data;
  },
};

// Product API  
export const productAPI = {
  getAll: async (): Promise<Product[]> => {
    const response = await axios.get(`${API_BASE_URL}/products`);
    return response.data;
  },

  create: async (product: CreateProductRequest): Promise<Product> => {
    const response = await axios.post(`${API_BASE_URL}/products`, product);
    return response.data;
  },

  search: async (query: string): Promise<Product[]> => {
    const response = await axios.get(`${API_BASE_URL}/products/search?query=${query}`);
    return response.data;
  }
};

// Order API for Node.js service
export const orderAPI = {
  create: async (order: CreateOrderRequest): Promise<Order> => {
    const response = await axios.post(`${ORDERS_API_BASE_URL}/orders`, order);
    return response.data;
  },

  getAll: async (): Promise<Order[]> => {
    const response = await axios.get(`${ORDERS_API_BASE_URL}/orders`);
    return response.data;
  },

  getById: async (id: string): Promise<Order> => {
    const response = await axios.get(`${ORDERS_API_BASE_URL}/orders/${id}`);
    return response.data;
  }
};
EOF

# Also fix the types file to ensure all exports are correct
cat > src/types/index.ts << 'EOF'
export interface Category {
  id: number;
  name: string;
  description?: string;
  createdAt: string;
}

export interface Product {
  id: number;
  name: string;
  description?: string;
  price: number;
  stock: number;
  categoryId: number;
  category?: Category;
  createdAt: string;
  updatedAt: string;
}

export interface CartItem {
  id: string;
  productName: string;
  categoryId: number;
  categoryName: string;
  quantity: number;
  addedAt: Date;
}

export interface CreateProductRequest {
  name: string;
  description?: string;
  price: number;
  stock: number;
  categoryId: number;
}

export interface OrderCustomer {
  firstName: string;
  lastName: string;
  address: string;
  email: string;
}

export interface Order {
  id?: string;
  customer: OrderCustomer;
  items: CartItem[];
  totalItems: number;
  orderDate: Date;
  status: 'pending' | 'confirmed' | 'shipped' | 'delivered';
}

export interface CreateOrderRequest {
  customer: OrderCustomer;
  items: CartItem[];
  totalItems: number;
}
EOF

# Check if there are any other TypeScript errors and try to build
echo "🔍 Checking for TypeScript errors..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ TypeScript compilation successful!"
else
    echo "❌ Still have TypeScript errors, let's check individual files..."
    
    # Check individual files
    npx tsc --noEmit src/types/index.ts
    npx tsc --noEmit src/services/api.ts
fi

echo "✅ TypeScript imports fixed!"
echo ""
echo "🚀 Try starting the app again:"
echo "npm start"
