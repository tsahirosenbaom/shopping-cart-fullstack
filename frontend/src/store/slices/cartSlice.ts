import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { CartItem } from '../../types';

interface CartState {
  items: CartItem[];
  totalItems: number;
}

interface AddToCartPayload {
  productName: string;
  categoryId: number;
  categoryName: string;
  quantity: number;
}

const initialState: CartState = {
  items: [],
  totalItems: 0,
};

const cartSlice = createSlice({
  name: 'cart',
  initialState,
  reducers: {
    addToCart: (state, action: PayloadAction<AddToCartPayload>) => {
      const { productName, categoryId, categoryName, quantity } = action.payload;
      
      // Check if item already exists
      const existingItem = state.items.find(
        item => item.productName === productName && item.categoryId === categoryId
      );

      if (existingItem) {
        existingItem.quantity += quantity;
      } else {
        const newItem: CartItem = {
          id: Date.now().toString(),
          productName,
          categoryId,
          categoryName,
          quantity,
          addedAt: new Date(),
        };
        state.items.push(newItem);
      }

      // Update total
      state.totalItems = state.items.reduce((total, item) => total + item.quantity, 0);
    },

    updateQuantity: (state, action: PayloadAction<{ id: string; quantity: number }>) => {
      const { id, quantity } = action.payload;
      const item = state.items.find(item => item.id === id);
      
      if (item && quantity > 0) {
        item.quantity = quantity;
        state.totalItems = state.items.reduce((total, item) => total + item.quantity, 0);
      }
    },

    removeFromCart: (state, action: PayloadAction<string>) => {
      state.items = state.items.filter(item => item.id !== action.payload);
      state.totalItems = state.items.reduce((total, item) => total + item.quantity, 0);
    },

    clearCart: (state) => {
      state.items = [];
      state.totalItems = 0;
    },
  },
});

export const { addToCart, updateQuantity, removeFromCart, clearCart } = cartSlice.actions;
export default cartSlice.reducer;
