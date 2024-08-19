const AWS = require("aws-sdk");
const dynamo = new AWS.DynamoDB.DocumentClient();

const TableName = process.env.DEVICE_STATUS_TABLE_NAME;

exports.handler = async (event) => {
  console.log("Received event:", JSON.stringify(event, null, 2));

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

  // Verificar si el evento tiene la estructura esperada
  if (!parsedEvent || typeof parsedEvent !== "object" || !parsedEvent.info) {
    console.error("Invalid event structure:", parsedEvent);
    throw new Error("Invalid event structure");
  }

  const { gateway_id, status, timestamp } = parsedEvent.info;

  // Verificar si todos los campos necesarios están presentes
  if (!gateway_id || !status || !timestamp) {
    console.error("Missing required fields in event.info:", parsedEvent.info);
    throw new Error("Missing required fields");
  }

  const params = {
    TableName,
    Item: {
      DeviceId: gateway_id,
      Status: status,
      Timestamp: timestamp,
    },
  };

  try {
    await dynamo.put(params).promise();
    console.log(`Inserted data: ${JSON.stringify(params.Item)}`);
  } catch (error) {
    console.error(`Error inserting data: ${error}`);
    throw error;
  }
};
