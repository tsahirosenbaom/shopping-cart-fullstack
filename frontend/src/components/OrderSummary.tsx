import React, { useState } from 'react';
import { ArrowRight, User, Mail, MapPin, CheckCircle, AlertCircle } from 'lucide-react';
import { useAppDispatch, useAppSelector } from '../store';
import { createOrder, clearOrder } from '../store/slices/orderSlice';
import { clearCart } from '../store/slices/cartSlice';
import { OrderCustomer } from '../types';

interface OrderSummaryProps {
  onBack: () => void;
}

const OrderSummary: React.FC<OrderSummaryProps> = ({ onBack }) => {
  const dispatch = useAppDispatch();
  const { items, totalItems } = useAppSelector(state => state.cart);
  const { loading, error, orderSubmitted, currentOrder } = useAppSelector(state => state.order);

  const [customer, setCustomer] = useState<OrderCustomer>({
    firstName: '',
    lastName: '',
    address: '',
    email: '',
  });

  const [errors, setErrors] = useState<Partial<OrderCustomer>>({});

  const validateForm = (): boolean => {
    const newErrors: Partial<OrderCustomer> = {};

    if (!customer.firstName.trim()) {
      newErrors.firstName = 'שם פרטי הוא שדה חובה';
    }
    if (!customer.lastName.trim()) {
      newErrors.lastName = 'שם משפחה הוא שדה חובה';
    }
    if (!customer.address.trim()) {
      newErrors.address = 'כתובת מלאה היא שדה חובה';
    }
    if (!customer.email.trim()) {
      newErrors.email = 'אימייל הוא שדה חובה';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(customer.email)) {
      newErrors.email = 'פורמט אימייל לא תקין';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleInputChange = (field: keyof OrderCustomer, value: string) => {
    setCustomer(prev => ({ ...prev, [field]: value }));
    if (errors[field]) {
      setErrors(prev => ({ ...prev, [field]: undefined }));
    }
  };

  const handleSubmitOrder = async () => {
    if (!validateForm()) return;

    try {
      await dispatch(createOrder({
        customer,
        items,
        totalItems,
      })).unwrap();

      // Clear cart after successful order
      dispatch(clearCart());
    } catch (error) {
      console.error('Failed to create order:', error);
    }
  };

  const handleStartNewOrder = () => {
    dispatch(clearOrder());
    onBack();
  };

  if (orderSubmitted && currentOrder) {
    return (
      <div className="order-success">
        <div className="success-icon">
          <CheckCircle size={64} color="#16a34a" />
        </div>
        <h2>הזמנה נשלחה בהצלחה!</h2>
        <div className="order-details">
          <p><strong>מספר הזמנה:</strong> {currentOrder.id}</p>
          <p><strong>שם:</strong> {currentOrder.customer.firstName} {currentOrder.customer.lastName}</p>
          <p><strong>אימייל:</strong> {currentOrder.customer.email}</p>
          <p><strong>כמות פריטים:</strong> {currentOrder.totalItems}</p>
        </div>
        <button className="new-order-btn" onClick={handleStartNewOrder}>
          התחל הזמנה חדשה
        </button>
      </div>
    );
  }

  return (
    <div className="order-summary">
      <div className="order-header">
        <button className="back-btn" onClick={onBack}>
          <ArrowRight size={20} />
          חזור לעגלה
        </button>
        <h2>סיכום ההזמנה</h2>
      </div>

      {error && (
        <div className="error-message">
          <AlertCircle size={20} />
          {error}
        </div>
      )}

      <div className="order-content">
        {/* Customer Form */}
        <div className="customer-form">
          <h3>פרטי הזמנה</h3>
          
          <div className="form-row">
            <div className="form-group">
              <label className="form-label">
                <User size={16} />
                שם פרטי *
              </label>
              <input
                type="text"
                className={`form-input ${errors.firstName ? 'error' : ''}`}
                value={customer.firstName}
                onChange={(e) => handleInputChange('firstName', e.target.value)}
                placeholder="הכנס שם פרטי..."
              />
              {errors.firstName && <span className="error-text">{errors.firstName}</span>}
            </div>

            <div className="form-group">
              <label className="form-label">
                <User size={16} />
                שם משפחה *
              </label>
              <input
                type="text"
                className={`form-input ${errors.lastName ? 'error' : ''}`}
                value={customer.lastName}
                onChange={(e) => handleInputChange('lastName', e.target.value)}
                placeholder="הכנס שם משפחה..."
              />
              {errors.lastName && <span className="error-text">{errors.lastName}</span>}
            </div>
          </div>

          <div className="form-group">
            <label className="form-label">
              <MapPin size={16} />
              כתובת מלאה *
            </label>
            <input
              type="text"
              className={`form-input ${errors.address ? 'error' : ''}`}
              value={customer.address}
              onChange={(e) => handleInputChange('address', e.target.value)}
              placeholder="הכנס כתובת מלאה..."
            />
            {errors.address && <span className="error-text">{errors.address}</span>}
          </div>

          <div className="form-group">
            <label className="form-label">
              <Mail size={16} />
              אימייל *
            </label>
            <input
              type="email"
              className={`form-input ${errors.email ? 'error' : ''}`}
              value={customer.email}
              onChange={(e) => handleInputChange('email', e.target.value)}
              placeholder="הכנס כתובת אימייל..."
            />
            {errors.email && <span className="error-text">{errors.email}</span>}
          </div>
        </div>

        {/* Order Items */}
        <div className="order-items">
          <h3>פריטים בהזמנה ({totalItems})</h3>
          <div className="items-list">
            {items.map(item => (
              <div key={item.id} className="order-item">
                <div className="item-details">
                  <span className="item-name">{item.productName}</span>
                  <span className="item-category">{item.categoryName}</span>
                </div>
                <div className="item-quantity">
                  כמות: {item.quantity}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="order-actions">
        <button
          className="confirm-order-btn"
          onClick={handleSubmitOrder}
          disabled={loading || items.length === 0}
        >
          {loading ? 'שולח הזמנה...' : 'אשר הזמנה'}
        </button>
      </div>
    </div>
  );
};

export default OrderSummary;
