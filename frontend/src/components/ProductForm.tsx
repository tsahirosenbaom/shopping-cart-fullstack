import React, { useState } from 'react';
import { Plus, Minus } from 'lucide-react';
import { useAppDispatch, useAppSelector } from '../store';
import { addToCart } from '../store/slices/cartSlice';
import CategorySelect from './CategorySelect';

const ProductForm: React.FC = () => {
  const dispatch = useAppDispatch();
  const { categories } = useAppSelector(state => state.categories);
  
  const [selectedCategoryId, setSelectedCategoryId] = useState<number | null>(null);
  const [productName, setProductName] = useState('');
  const [quantity, setQuantity] = useState(1);

  const selectedCategory = categories.find(cat => cat.id === selectedCategoryId);

  const handleAddToCart = () => {
    if (!selectedCategoryId || !productName.trim()) {
      alert('אנא בחר קטגוריה והכנס שם מוצר');
      return;
    }

    dispatch(addToCart({
      productName: productName.trim(),
      categoryId: selectedCategoryId,
      categoryName: selectedCategory?.name || '',
      quantity,
    }));

    // Reset form
    setProductName('');
    setQuantity(1);
  };

  const increaseQuantity = () => setQuantity(prev => prev + 1);
  const decreaseQuantity = () => setQuantity(prev => Math.max(1, prev - 1));

  return (
    <div className="product-form">
      <h2 className="form-title">הוסף מוצר לעגלה</h2>
      
      <CategorySelect
        selectedCategoryId={selectedCategoryId}
        onCategoryChange={setSelectedCategoryId}
      />

      <div className="form-group">
        <label className="form-label">שם המוצר</label>
        <input
          type="text"
          className="form-input"
          value={productName}
          onChange={(e) => setProductName(e.target.value)}
          placeholder="הכנס שם מוצר..."
          disabled={!selectedCategoryId}
        />
      </div>

      <div className="form-group">
        <label className="form-label">כמות</label>
        <div className="quantity-controls">
          <button 
            type="button" 
            className="quantity-btn"
            onClick={decreaseQuantity}
            disabled={quantity <= 1}
          >
            <Minus size={16} />
          </button>
          <span className="quantity-display">{quantity}</span>
          <button 
            type="button" 
            className="quantity-btn"
            onClick={increaseQuantity}
          >
            <Plus size={16} />
          </button>
        </div>
      </div>

      <button
        className="add-btn"
        onClick={handleAddToCart}
        disabled={!selectedCategoryId || !productName.trim()}
      >
        הוסף מוצר לסל
      </button>
    </div>
  );
};

export default ProductForm;
