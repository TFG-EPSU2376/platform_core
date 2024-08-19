const AWS = require("aws-sdk");
const dynamoDB = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  const TableName = process.env.RECOMMENDATIONS_TABLE_NAME;
  const limit = event.queryStringParameters?.limit || 20;
  const lastEvaluatedKey = event.queryStringParameters?.lastEvaluatedKey;
  const startDate = event.queryStringParameters?.startDate;
  const endDate = event.queryStringParameters?.endDate;

  // Verificar que las fechas sean válidas y que startDate sea anterior a endDate
  if (startDate && endDate && new Date(startDate) > new Date(endDate)) {
    return {
      statusCode: 400,
      body: JSON.stringify({
        error: "Invalid date range",
        message: "startDate must be before endDate",
      }),
    };
  }

  let params = {
    TableName,
    Limit: limit,
    ExclusiveStartKey: lastEvaluatedKey
      ? JSON.parse(lastEvaluatedKey)
      : undefined,
  };

  // Agregar filtro de rango de fechas si se proporcionan startDate y endDate
  if (startDate && endDate) {
    params.FilterExpression = "#ts BETWEEN :start_date AND :end_date";
    params.ExpressionAttributeNames = {
      "#ts": "createdAt",
    };
    params.ExpressionAttributeValues = {
      ":start_date": new Date(startDate).toISOString(),
      ":end_date": new Date(endDate).toISOString(),
    };
  }

  try {
    const data = await dynamoDB.scan(params).promise();
    const items = data.Items.map((item) => ({
      date: item.createdAt,
      title: item.Title,
      description: item.Description,
      type: item.Type,
    }));

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
          "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
        "Access-Control-Allow-Methods": "*",
      },
      body: JSON.stringify({
        items,
        lastEvaluatedKey:
          items.length > 0 && data.LastEvaluatedKey
            ? JSON.stringify(data.LastEvaluatedKey)
            : null,
      }),
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({
        error: "Failed to fetch recommendations",
        message: error.message,
      }),
    };
  }
};
