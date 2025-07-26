import React, { useEffect, useState } from 'react';
import { useAppDispatch, useAppSelector } from '../store';
import { fetchCategories } from '../store/slices/categoriesSlice';
import { resetOrderState } from '../store/slices/orderSlice';
import ProductForm from '../components/ProductForm';
import ShoppingCart from '../components/ShoppingCart';
import OrderSummary from '../components/OrderSummary';

type Screen = 'shopping' | 'order-summary';

const ShoppingList: React.FC = () => {
  const dispatch = useAppDispatch();
  const { loading, error } = useAppSelector(state => state.categories);
  const [currentScreen, setCurrentScreen] = useState<Screen>('shopping');

  useEffect(() => {
    dispatch(fetchCategories());
    dispatch(resetOrderState());
  }, [dispatch]);

  const handleContinueOrder = () => {
    setCurrentScreen('order-summary');
  };

  const handleBackToShopping = () => {
    setCurrentScreen('shopping');
    dispatch(resetOrderState());
  };

  if (loading) {
    return (
      <div className="app-container">
        <div className="loading">
          <div className="animate-spin" style={{ 
            width: '40px', 
            height: '40px', 
            border: '4px solid #e2e8f0', 
            borderTop: '4px solid #667eea', 
            borderRadius: '50%',
            margin: '0 auto 20px'
          }}></div>
          טוען נתונים...
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="app-container">
        <div className="error">
          שגיאה בטעינת הנתונים: {error}
        </div>
      </div>
    );
  }

  return (
    <div className="app-container">
      {currentScreen === 'shopping' && (
        <>
          <header className="header">
            <h1>רשימת קניות</h1>
            <p>נהל את רשימת הקניות שלך בקלות ובנוחות</p>
          </header>

          <main className="main-content">
            <ProductForm />
            <ShoppingCart onContinueOrder={handleContinueOrder} />
          </main>
        </>
      )}

      {currentScreen === 'order-summary' && (
        <>
          <header className="header">
            <h1>סיכום הזמנה</h1>
            <p>מלא את פרטיך ואשר את ההזמנה</p>
          </header>

          <main style={{ padding: '0 20px' }}>
            <OrderSummary onBack={handleBackToShopping} />
          </main>
        </>
      )}
    </div>
  );
};

export default ShoppingList;
