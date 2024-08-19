const AWS = require("aws-sdk");
const dynamoDB = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  try {
    const TableName = process.env.SENSOR_DATA_TABLE_NAME;
    const endDate = new Date();
    const startDate = new Date(endDate.getTime() - 15 * 24 * 60 * 60 * 1000); // 15 días atrás

    const summaryData = await getSensorSummary(TableName, startDate, endDate);

    const data = {
      summary: summaryData,
      startDate: startDate.toISOString(),
      endDate: endDate.toISOString(),
    };

    return {
      statusCode: 200,
      body: JSON.stringify(data),
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
          "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
        "Access-Control-Allow-Methods": "*",
      },
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({
        error: "Failed to fetch sensor summary data",
        message: error.message,
      }),
    };
  }
};

async function getSensorSummary(TableName, startDate, endDate) {
  const hourlyData = {};

  let lastEvaluatedKey = null;
  do {
    const params = {
      TableName,
      FilterExpression: "#ts BETWEEN :start_date AND :end_date",
      ExpressionAttributeNames: {
        "#ts": "Timestamp",
      },
      ExpressionAttributeValues: {
        ":start_date": startDate.toISOString(),
        ":end_date": endDate.toISOString(),
      },
      Limit: 1000, // Ajusta este valor según sea necesario
      ExclusiveStartKey: lastEvaluatedKey,
    };

    const result = await dynamoDB.scan(params).promise();

    for (const item of result.Items) {
      const date = new Date(item.Timestamp);
      const hourKey = date.toISOString().slice(0, 13) + ":00:00.000Z";

      if (!hourlyData[hourKey]) {
        hourlyData[hourKey] = {
          temperature: [],
          humidity: [],
          rainfall: [],
        };
      }

      switch (item.Category) {
        case "Temperature":
          hourlyData[hourKey].temperature.push(item.Value);
          break;
        case "Humidity":
          hourlyData[hourKey].humidity.push(item.Value);
          break;
        case "Rainfall":
          hourlyData[hourKey].rainfall.push(item.Value);
          break;
      }
    }

    lastEvaluatedKey = result.LastEvaluatedKey;
  } while (lastEvaluatedKey);

  return Object.entries(hourlyData).map(([date, data]) => ({
    date,
    temperature: calculateStats(data.temperature),
    humidity: calculateStats(data.humidity),
    rainfall: calculateStats(data.rainfall),
  }));
}

function calculateStats(values) {
  if (values.length === 0) return null;

  const sortedValues = values.sort((a, b) => a - b);
  return {
    min: sortedValues[0],
    max: sortedValues[sortedValues.length - 1],
    median: sortedValues[Math.floor(sortedValues.length / 2)],
    avg: values.reduce((sum, val) => sum + val, 0) / values.length,
  };
}
