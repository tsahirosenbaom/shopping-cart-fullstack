const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization'
};

exports.handler = async (event) => {
    console.log('Event:', JSON.stringify(event, null, 2));
    
    try {
        if (event.httpMethod === 'OPTIONS') {
            return {
                statusCode: 200,
                headers,
                body: ''
            };
        }

        if (event.httpMethod === 'GET') {
            // Check if it's a search request
            if (event.pathParameters === null && event.queryStringParameters && event.queryStringParameters.query) {
                return await searchProducts(event.queryStringParameters.query);
            }
            
            // Get all products
            const params = {
                TableName: process.env.PRODUCTS_TABLE
            };

            const result = await dynamodb.scan(params).promise();
            
            // Get categories for each product
            const products = await Promise.all(result.Items.map(async (product) => {
                if (product.categoryId) {
                    try {
                        const categoryParams = {
                            TableName: process.env.CATEGORIES_TABLE,
                            Key: { id: product.categoryId }
                        };
                        const categoryResult = await dynamodb.get(categoryParams).promise();
                        if (categoryResult.Item) {
                            product.category = categoryResult.Item;
                        }
                    } catch (err) {
                        console.log('Error fetching category:', err);
                    }
                }
                return product;
            }));
            
            // Sort by id
            products.sort((a, b) => a.id - b.id);
            
            return {
                statusCode: 200,
                headers,
                body: JSON.stringify(products)
            };
        }

        if (event.httpMethod === 'POST') {
            const body = JSON.parse(event.body);
            
            // Get next ID
            const scanParams = {
                TableName: process.env.PRODUCTS_TABLE,
                Select: 'COUNT'
            };
            const countResult = await dynamodb.scan(scanParams).promise();
            const nextId = countResult.Count + 1;
            
            const product = {
                id: nextId,
                name: body.name,
                description: body.description || '',
                price: parseFloat(body.price),
                stock: parseInt(body.stock),
                categoryId: body.categoryId ? parseInt(body.categoryId) : null,
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString()
            };

            const params = {
                TableName: process.env.PRODUCTS_TABLE,
                Item: product
            };

            await dynamodb.put(params).promise();
            
            return {
                statusCode: 201,
                headers,
                body: JSON.stringify(product)
            };
        }

        return {
            statusCode: 405,
            headers,
            body: JSON.stringify({ error: 'Method not allowed' })
        };

    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            headers,
            body: JSON.stringify({ 
                error: 'Internal server error',
                details: error.message 
            })
        };
    }
};

async function searchProducts(query) {
    try {
        const params = {
            TableName: process.env.PRODUCTS_TABLE
        };

        const result = await dynamodb.scan(params).promise();
        
        // Filter products based on search query
        const filteredProducts = result.Items.filter(product => 
            product.name.toLowerCase().includes(query.toLowerCase()) ||
            (product.description && product.description.toLowerCase().includes(query.toLowerCase()))
        );
        
        return {
            statusCode: 200,
            headers,
            body: JSON.stringify(filteredProducts)
        };
    } catch (error) {
        console.error('Search error:', error);
        return {
            statusCode: 500,
            headers,
            body: JSON.stringify({ error: 'Search failed' })
        };
    }
}
