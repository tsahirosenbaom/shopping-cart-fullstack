import React from 'react';
import { Provider } from 'react-redux';
import { store } from './store';
import ShoppingList from './pages/ShoppingList';
import './App.css';

function App() {
  return (
    <Provider store={store}>
      <div className="App">
        <ShoppingList />
      </div>
    </Provider>
  );
}

export default App;
