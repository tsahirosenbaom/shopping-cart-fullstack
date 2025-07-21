const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// In-memory storage for products
let products = [];

// Load products from .NET API
async function loadProducts() {
  try {
    const response = await axios.get('http://localhost:5002/api/products');
    products = response.data;
    console.log(`✅ Loaded ${products.length} products from .NET API`);
  } catch (error) {
    console.log('⚠️  Could not load from .NET API, using mock data');
    products = [
      {
        id: 1,
        name: 'Gaming Laptop',
        description: 'High-performance gaming laptop',
        price: 1299.99,
        stock: 25,
        category: { name: 'Electronics' }
      },
      {
        id: 2,
        name: 'Wireless Mouse',
        description: 'Ergonomic wireless mouse',
        price: 29.99,
        stock: 100,
        category: { name: 'Electronics' }
      }
    ];
  }
}

// Routes
app.get('/', (req, res) => {
  res.json({
    message: 'Search API is running!',
    endpoints: {
      health: 'GET /health',
      search: 'GET /api/search/products?q=query&limit=10',
      suggestions: 'GET /api/search/suggestions?q=query&limit=5',
      sync: 'POST /api/sync/products'
    }
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'search-api',
    productsLoaded: products.length
  });
});

// Search products
app.get('/api/search/products', (req, res) => {
  const { q: query, limit = 10 } = req.query;
  
  if (!query) {
    return res.json([]);
  }

  const searchResults = products
    .filter(product => 
      product.name.toLowerCase().includes(query.toLowerCase()) ||
      (product.description && product.description.toLowerCase().includes(query.toLowerCase())) ||
      (product.category && product.category.name.toLowerCase().includes(query.toLowerCase()))
    )
    .slice(0, parseInt(limit))
    .map(product => ({
      id: product.id.toString(),
      name: product.name,
      description: product.description || '',
      price: product.price,
      stock: product.stock,
      category: product.category?.name || 'Uncategorized',
      score: Math.random() * 100 // Mock relevance score
    }));

  res.json(searchResults);
});

// Get suggestions
app.get('/api/search/suggestions', (req, res) => {
  const { q: query, limit = 5 } = req.query;
  
  if (!query) {
    return res.json({ suggestions: [] });
  }

  const suggestions = products
    .filter(product => 
      product.name.toLowerCase().startsWith(query.toLowerCase())
    )
    .slice(0, parseInt(limit))
    .map(product => product.name);

  res.json({ suggestions });
});

// Sync products
app.post('/api/sync/products', async (req, res) => {
  try {
    await loadProducts();
    res.json({ 
      message: 'Products synced successfully',
      count: products.length 
    });
  } catch (error) {
    res.status(500).json({ 
      error: 'Failed to sync products',
      message: error.message 
    });
  }
});

// Start server
app.listen(PORT, async () => {
  console.log(`🟢 Search API running on http://localhost:${PORT}`);
  console.log(`📚 API documentation available at http://localhost:${PORT}`);
  
  // Load initial data
  await loadProducts();
});

// In-memory storage for orders
let orders = [];
let orderCounter = 1;

// Orders routes
app.get('/api/orders', (req, res) => {
  res.json(orders);
});

app.get('/api/orders/:id', (req, res) => {
  const { id } = req.params;
  const order = orders.find(o => o.id === id);
  
  if (!order) {
    return res.status(404).json({ error: 'Order not found' });
  }
  
  res.json(order);
});

app.post('/api/orders', (req, res) => {
  const { customer, items, totalItems } = req.body;
  
  // Validate required fields
  if (!customer || !customer.firstName || !customer.lastName || !customer.address || !customer.email) {
    return res.status(400).json({ error: 'Missing required customer information' });
  }
  
  if (!items || !Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ error: 'Order must contain at least one item' });
  }
  
  // Create new order
  const newOrder = {
    id: `ORDER-${orderCounter.toString().padStart(4, '0')}`,
    customer,
    items,
    totalItems: totalItems || items.reduce((sum, item) => sum + item.quantity, 0),
    orderDate: new Date().toISOString(),
    status: 'pending'
  };
  
  orders.push(newOrder);
  orderCounter++;
  
  console.log(`✅ New order created: ${newOrder.id} for ${customer.firstName} ${customer.lastName}`);
  console.log(`📦 Items: ${totalItems}, Customer: ${customer.email}`);
  
  res.status(201).json(newOrder);
});

// Search orders
app.get('/api/search/orders', (req, res) => {
  const { q: query, limit = 10 } = req.query;
  
  if (!query) {
    return res.json([]);
  }
  
  const searchResults = orders
    .filter(order => 
      order.customer.firstName.toLowerCase().includes(query.toLowerCase()) ||
      order.customer.lastName.toLowerCase().includes(query.toLowerCase()) ||
      order.customer.email.toLowerCase().includes(query.toLowerCase()) ||
      order.id.toLowerCase().includes(query.toLowerCase()) ||
      order.items.some(item => 
        item.productName.toLowerCase().includes(query.toLowerCase()) ||
        item.categoryName.toLowerCase().includes(query.toLowerCase())
      )
    )
    .slice(0, parseInt(limit))
    .map(order => ({
      ...order,
      score: Math.random() * 100 // Mock relevance score
    }));
    
  res.json(searchResults);
});

// Update order status
app.put('/api/orders/:id/status', (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  
  const orderIndex = orders.findIndex(o => o.id === id);
  if (orderIndex === -1) {
    return res.status(404).json({ error: 'Order not found' });
  }
  
  const validStatuses = ['pending', 'confirmed', 'shipped', 'delivered'];
  if (!validStatuses.includes(status)) {
    return res.status(400).json({ error: 'Invalid status' });
  }
  
  orders[orderIndex].status = status;
  res.json(orders[orderIndex]);
});

console.log('📋 Order management endpoints added:');
console.log('   GET /api/orders - Get all orders');
console.log('   POST /api/orders - Create new order');
console.log('   GET /api/orders/:id - Get order by ID');
console.log('   GET /api/search/orders - Search orders');
console.log('   PUT /api/orders/:id/status - Update order status');
