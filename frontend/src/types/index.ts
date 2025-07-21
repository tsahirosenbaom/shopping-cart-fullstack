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
