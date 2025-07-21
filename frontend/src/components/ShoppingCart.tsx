import React from 'react';
import { ShoppingCart as CartIcon, Trash2, ArrowLeft } from 'lucide-react';
import { useAppDispatch, useAppSelector } from '../store';
import { clearCart } from '../store/slices/cartSlice';
import CartItem from './CartItem';

interface ShoppingCartProps {
  onContinueOrder: () => void;
}

const ShoppingCart: React.FC<ShoppingCartProps> = ({ onContinueOrder }) => {
  const dispatch = useAppDispatch();
  const { items, totalItems } = useAppSelector(state => state.cart);

  const handleClearCart = () => {
    if (window.confirm('האם אתה בטוח שברצונך לנקות את העגלה?')) {
      dispatch(clearCart());
    }
  };

  return (
    <div className="cart-section">
      <div className="cart-header">
        <CartIcon className="cart-icon" />
        <h2 className="cart-title">עגלת קניות</h2>
        <span className="cart-count">{totalItems}</span>
      </div>

      <div className="cart-content">
        {items.length === 0 ? (
          <div className="cart-empty">
            <CartIcon size={48} style={{ margin: '0 auto 20px', display: 'block', opacity: 0.3 }} />
            <p>העגלה ריקה</p>
            <p style={{ fontSize: '0.9rem', marginTop: '10px', opacity: 0.7 }}>
              התחל בהוספת מוצרים לעגלה
            </p>
          </div>
        ) : (
          <>
            {items.map(item => (
              <CartItem key={item.id} item={item} />
            ))}
          </>
        )}
      </div>

      {items.length > 0 && (
        <div className="cart-actions">
          <button className="continue-order-btn" onClick={onContinueOrder}>
            <ArrowLeft size={16} style={{ marginLeft: '8px' }} />
            המשך הזמנה
          </button>
          <button className="clear-btn" onClick={handleClearCart}>
            <Trash2 size={16} style={{ marginLeft: '8px' }} />
            נקה עגלה
          </button>
        </div>
      )}
    </div>
  );
};

export default ShoppingCart;
