const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB.DocumentClient();

const headers = {
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
};

exports.handler = async (event) => {
  console.log("Event:", JSON.stringify(event, null, 2));

  try {
    if (event.httpMethod === "OPTIONS") {
      return {
        statusCode: 200,
        headers,
        body: "",
      };
    }

    if (event.httpMethod === "GET") {
      // Check if it's a specific order request
      if (event.pathParameters && event.pathParameters.id) {
        return await getOrderById(event.pathParameters.id);
      }

      // Get all orders
      const params = {
        TableName: process.env.ORDERS_TABLE,
      };

      const result = await dynamodb.scan(params).promise();

      // Sort by orderDate (newest first)
      const orders = result.Items.sort(
        (a, b) => new Date(b.orderDate) - new Date(a.orderDate)
      );

      return {
        statusCode: 200,
        headers,
        body: JSON.stringify(orders),
      };
    }

    if (event.httpMethod === "POST") {
      const body = JSON.parse(event.body);

      // Validate required fields
      if (
        !body.customer ||
        !body.customer.firstName ||
        !body.customer.lastName ||
        !body.customer.address ||
        !body.customer.email
      ) {
        return {
          statusCode: 400,
          headers,
          body: JSON.stringify({
            error: "Missing required customer information",
          }),
        };
      }

      if (
        !body.items ||
        !Array.isArray(body.items) ||
        body.items.length === 0
      ) {
        return {
          statusCode: 400,
          headers,
          body: JSON.stringify({
            error: "Order must contain at least one item",
          }),
        };
      }

      // Generate order ID
      const timestamp = Date.now();
      const orderId = `ORDER-${timestamp}`;

      const order = {
        id: orderId,
        customer: {
          firstName: body.customer.firstName,
          lastName: body.customer.lastName,
          address: body.customer.address,
          email: body.customer.email,
        },
        items: body.items,
        totalItems:
          body.totalItems ||
          body.items.reduce((sum, item) => sum + item.quantity, 0),
        orderDate: new Date().toISOString(),
        status: "pending",
      };

      const params = {
        TableName: process.env.ORDERS_TABLE,
        Item: order,
      };

      await dynamodb.put(params).promise();

      console.log(
        `✅ Order created: ${orderId} for ${order.customer.firstName} ${order.customer.lastName}`
      );

      return {
        statusCode: 201,
        headers,
        body: JSON.stringify(order),
      };
    }

    return {
      statusCode: 405,
      headers,
      body: JSON.stringify({ error: "Method not allowed" }),
    };
  } catch (error) {
    console.error("Error:", error);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({
        error: "Internal server error",
        details: error.message,
      }),
    };
  }
};

async function getOrderById(orderId) {
  try {
    const params = {
      TableName: process.env.ORDERS_TABLE,
      Key: { id: orderId },
    };

    const result = await dynamodb.get(params).promise();

    if (!result.Item) {
      return {
        statusCode: 404,
        headers,
        body: JSON.stringify({ error: "Order not found" }),
      };
    }

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify(result.Item),
    };
  } catch (error) {
    console.error("Error getting order:", error);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: "Failed to get order" }),
    };
  }
}
