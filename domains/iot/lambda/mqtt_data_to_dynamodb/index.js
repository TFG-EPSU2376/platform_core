const AWS = require("aws-sdk");
const dynamo = new AWS.DynamoDB.DocumentClient();

const TableName = process.env.SENSOR_DATA_TABLE_NAME;

exports.handler = async (event, context) => {
  console.log("Received event:", context, JSON.stringify(event, null, 2));

  let parsedEvent;

  if (typeof event === "string") {
    try {
      parsedEvent = JSON.parse(event);
    } catch (error) {
      console.error("Failed to parse event string:", error);
      throw new Error("Invalid event format");
    }
  } else {
    parsedEvent = event;
  }

  console.log("Parsed event:", JSON.stringify(parsedEvent, null, 2));

  const payload = parsedEvent.measurements?.[0];
  if (!payload) {
    throw new Error("No measurements found in the event");
  }

  const timestamp = convertTimestamp(payload.date);
  const deviceName = payload.sensor;
  const deviceId = deviceName.split("_")[0];

  for (const dataPoint of payload.data) {
    await saveToDynamoDB(
      deviceName,
      timestamp,
      deviceId,
      dataPoint.unity,
      dataPoint.value,
      deviceName
    );
  }

  return { statusCode: 200, body: JSON.stringify("Data saved successfully") };
};

const saveToDynamoDB = async (
  deviceId,
  timestamp,
  category,
  attribute,
  value
) => {
  const timestampAttribute = `${timestamp}#${deviceId}#${attribute}`;
  const timestampDeviceID = `${timestamp}#${deviceId}#${category}`;

  const params = {
    TableName,
    Item: {
      DeviceID: deviceId,
      TimestampAttribute: timestampAttribute,
      Category: category,
      Attribute: attribute,
      Timestamp: timestamp,
      Value: Number(value),
      TimestampDeviceID: timestampDeviceID,
    },
  };

  console.log(
    "Preparing to insert data:",
    JSON.stringify(params.Item, null, 2)
  );

  try {
    await dynamo.put(params).promise();
    console.log(
      `Inserted data successfully:`,
      JSON.stringify(params.Item, null, 2)
    );
  } catch (error) {
    console.error(`Error inserting data:`, error);
    console.error(`Failed item:`, JSON.stringify(params.Item, null, 2));
    throw error;
  }
};

const convertTimestamp = (unixTimestamp) => {
  const date = new Date(Number(unixTimestamp) * 1000); // Convertir a milisegundos
  return date.toISOString();
};
