import React from 'react';
import { useAppSelector } from '../store';

interface CategorySelectProps {
  selectedCategoryId: number | null;
  onCategoryChange: (categoryId: number) => void;
}

const CategorySelect: React.FC<CategorySelectProps> = ({
  selectedCategoryId,
  onCategoryChange,
}) => {
  const { categories, loading, error } = useAppSelector(state => state.categories);

  if (loading) {
    return (
      <div className="form-group">
        <label className="form-label">קטגוריה</label>
        <div className="loading">טוען קטגוריות...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="form-group">
        <label className="form-label">קטגוריה</label>
        <div className="error">שגיאה בטעינת קטגוריות: {error}</div>
      </div>
    );
  }

  return (
    <div className="form-group">
      <label className="form-label">בחר קטגוריה</label>
      <select
        className="form-select"
        value={selectedCategoryId || ''}
        onChange={(e) => onCategoryChange(Number(e.target.value))}
      >
        <option value="">-- בחר קטגוריה --</option>
        {categories.map(category => (
          <option key={category.id} value={category.id}>
            {category.name}
          </option>
        ))}
      </select>
    </div>
  );
};

export default CategorySelect;
