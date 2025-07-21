const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    console.log('Seeding database with initial data...');
    
    try {
        // Seed Categories
        const categories = [
            {
                id: 1,
                name: 'אלקטרוניקה',
                description: 'מוצרי אלקטרוניקה וגאדג\'טים',
                createdAt: new Date().toISOString()
            },
            {
                id: 2,
                name: 'ביגוד',
                description: 'בגדים ואביזרים',
                createdAt: new Date().toISOString()
            },
            {
                id: 3,
                name: 'ספרים',
                description: 'ספרים וחומרי לימוד',
                createdAt: new Date().toISOString()
            }
        ];

        // Insert categories
        for (const category of categories) {
            const params = {
                TableName: process.env.CATEGORIES_TABLE,
                Item: category,
                ConditionExpression: 'attribute_not_exists(id)'
            };
            
            try {
                await dynamodb.put(params).promise();
                console.log(`Category inserted: ${category.name}`);
            } catch (err) {
                if (err.code !== 'ConditionalCheckFailedException') {
                    throw err;
                }
                console.log(`Category already exists: ${category.name}`);
            }
        }

        // Seed Products
        const products = [
            {
                id: 1,
                name: 'לפטופ גיימינג',
                description: 'מחשב נייד בעל ביצועים גבוהים למשחקים',
                price: 4999.99,
                stock: 25,
                categoryId: 1,
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString()
            },
            {
                id: 2,
                name: 'עכבר אלחוטי',
                description: 'עכבר ארגונומי עם חיי סוללה ארוכים',
                price: 129.99,
                stock: 100,
                categoryId: 1,
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString()
            },
            {
                id: 3,
                name: 'חולצת כותנה',
                description: 'חולצה נוחה מכותנה באיכות גבוהה',
                price: 79.99,
                stock: 50,
                categoryId: 2,
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString()
            },
            {
                id: 4,
                name: 'ספר תכנות',
                description: 'ספר ללימוד יסודות התכנות',
                price: 149.99,
                stock: 30,
                categoryId: 3,
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString()
            }
        ];

        // Insert products
        for (const product of products) {
            const params = {
                TableName: process.env.PRODUCTS_TABLE,
                Item: product,
                ConditionExpression: 'attribute_not_exists(id)'
            };
            
            try {
                await dynamodb.put(params).promise();
                console.log(`Product inserted: ${product.name}`);
            } catch (err) {
                if (err.code !== 'ConditionalCheckFailedException') {
                    throw err;
                }
                console.log(`Product already exists: ${product.name}`);
            }
        }

        return {
            statusCode: 200,
            body: JSON.stringify({
                message: 'Database seeded successfully',
                categories: categories.length,
                products: products.length
            })
        };

    } catch (error) {
        console.error('Error seeding database:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({
                error: 'Failed to seed database',
                details: error.message
            })
        };
    }
};
