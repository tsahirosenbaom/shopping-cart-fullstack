import axios from 'axios';
import { Category, Product, CreateProductRequest, Order, CreateOrderRequest } from '../types';

const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || 'http://localhost:5002/api';
const ORDERS_API_BASE_URL = process.env.REACT_APP_ORDERS_API_BASE_URL || 'http://localhost:3000/api';

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
    const response = await axios.post(`${ORDERS_API_BASE_URL}/api/orders`, order);
    return response.data;
  },

  getAll: async (): Promise<Order[]> => {
    const response = await axios.get(`${ORDERS_API_BASE_URL}/api/orders`);
    return response.data;
  },

  getById: async (id: string): Promise<Order> => {
    const response = await axios.get(`${ORDERS_API_BASE_URL}/api/orders/${id}`);
    return response.data;
  }
};
