import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { orderAPI } from '../../services/api';
import { Order, CreateOrderRequest } from '../../types';

interface OrderState {
  currentOrder: Order | null;
  orders: Order[];
  loading: boolean;
  error: string | null;
  orderSubmitted: boolean;
}

export const createOrder = createAsyncThunk(
  'order/createOrder',
  async (orderData: CreateOrderRequest) => {
    const response = await orderAPI.create(orderData);
    return response;
  }
);

export const fetchOrders = createAsyncThunk(
  'order/fetchOrders',
  async () => {
    const response = await orderAPI.getAll();
    return response;
  }
);

const initialState: OrderState = {
  currentOrder: null,
  orders: [],
  loading: false,
  error: null,
  orderSubmitted: false,
};

const orderSlice = createSlice({
  name: 'order',
  initialState,
  reducers: {
    clearOrder: (state) => {
      state.currentOrder = null;
      state.orderSubmitted = false;
      state.error = null;
    },
    resetOrderState: (state) => {
      state.loading = false;
      state.error = null;
      state.orderSubmitted = false;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(createOrder.pending, (state) => {
        state.loading = true;
        state.error = null;
        state.orderSubmitted = false;
      })
      .addCase(createOrder.fulfilled, (state, action) => {
        state.loading = false;
        state.currentOrder = action.payload;
        state.orderSubmitted = true;
      })
      .addCase(createOrder.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message || 'Failed to create order';
        state.orderSubmitted = false;
      })
      .addCase(fetchOrders.fulfilled, (state, action) => {
        state.orders = action.payload;
      });
  },
});

export const { clearOrder, resetOrderState } = orderSlice.actions;
export default orderSlice.reducer;
