import React from 'react';
import { Plus, Minus, Trash2 } from 'lucide-react';
import { useAppDispatch } from '../store';
import { updateQuantity, removeFromCart } from '../store/slices/cartSlice';
import { CartItem as CartItemType } from '../types';

interface CartItemProps {
  item: CartItemType;
}

const CartItem: React.FC<CartItemProps> = ({ item }) => {
  const dispatch = useAppDispatch();

  const increaseQuantity = () => {
    dispatch(updateQuantity({ id: item.id, quantity: item.quantity + 1 }));
  };

  const decreaseQuantity = () => {
    if (item.quantity > 1) {
      dispatch(updateQuantity({ id: item.id, quantity: item.quantity - 1 }));
    }
  };

  const handleRemove = () => {
    dispatch(removeFromCart(item.id));
  };

  return (
    <div className="cart-item">
      <div className="cart-item-header">
        <div className="cart-item-info">
          <h3>{item.productName}</h3>
          <span className="cart-item-category">{item.categoryName}</span>
        </div>
        <button className="remove-btn" onClick={handleRemove}>
          <Trash2 size={16} />
        </button>
      </div>
      
      <div className="cart-item-controls">
        <div className="quantity-controls">
          <button 
            className="quantity-btn"
            onClick={decreaseQuantity}
            disabled={item.quantity <= 1}
          >
            <Minus size={16} />
          </button>
          <span className="quantity-display">{item.quantity}</span>
          <button 
            className="quantity-btn"
            onClick={increaseQuantity}
          >
            <Plus size={16} />
          </button>
        </div>
      </div>
    </div>
  );
};

export default CartItem;
