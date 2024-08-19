const AWS = require("aws-sdk");
const dynamo = new AWS.DynamoDB.DocumentClient();

const TableName = process.env.SENSOR_DATA_TABLE_NAME;

exports.handler = async (event) => {
  console.log("Received event:", JSON.stringify(event, null, 2));

  for (const record of event.Records) {
    const payload = JSON.parse(record.body);

    for (const item of payload) {
      const sensor = item.sensor;
      const timestamp = item.timestamp;

      if (item.temperature !== undefined) {
        await saveToDynamoDB(
          sensor,
          timestamp,
          "Temperature",
          item.temperature
        );
      }

      if (item.humidity !== undefined) {
        await saveToDynamoDB(sensor, timestamp, "Humidity", item.humidity);
      }

      if (item.rain !== undefined) {
        await saveToDynamoDB(sensor, timestamp, "Rainfall", item.rain);
      }
    }
  }
};

const saveToDynamoDB = async (sensor, timestamp, category, value) => {
  const params = {
    TableName,
    Item: {
      DeviceID: sensor,
      Timestamp: String(timestamp),
      Category: category,
      Value: value,
    },
  };

  try {
    await dynamo.put(params).promise();
    console.log(`Inserted data: ${JSON.stringify(params.Item)}`);
  } catch (error) {
    console.error(`Error inserting data: ${error}`);
  }
};
