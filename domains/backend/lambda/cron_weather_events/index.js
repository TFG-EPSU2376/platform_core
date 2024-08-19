const AWS = require("aws-sdk");
const fetch = require("node-fetch");

const dynamoDB = new AWS.DynamoDB.DocumentClient();
const TABLE_NAME = process.env.WEATHER_EVENTS_TABLE_NAME;
const OPENWEATHERMAP_API_KEY = process.env.OPENWEATHERMAP_API_KEY;
const LATITUDE = process.env.LATITUDE;
const LONGITUDE = process.env.LONGITUDE;

exports.handler = async (event) => {
  try {
    const weatherData = await fetchWeatherData(LATITUDE, LONGITUDE);
    const alerts = weatherData.alerts || [];
    const date = new Date().toISOString().split("T")[0];

    for (const alert of alerts) {
      const eventId = `${alert.event}_${alert.start}_${LATITUDE}_${LONGITUDE}`;

      // Check if the event already exists
      const existingEvent = await getExistingEvent(eventId, date);

      if (!existingEvent) {
        await saveWeatherEvent(eventId, alert, LATITUDE, LONGITUDE, date);
      }
    }

    return {
      statusCode: 200,
      body: JSON.stringify({
        message: "Weather events processed successfully",
      }),
    };
  } catch (error) {
    console.error("Error processing weather events:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Failed to process weather events" }),
    };
  }
};

async function fetchWeatherData(lat, lon) {
  const url = `https://api.openweathermap.org/data/3.0/onecall?lat=${lat}&lon=${lon}&exclude=minutely,hourly,daily&appid=${OPENWEATHERMAP_API_KEY}&units=metric`;
  console.log("url", url);
  const response = await fetch(url);
  console.log("response", response);
  return response.json();
}

async function getExistingEvent(eventId, date) {
  const params = {
    TableName: TABLE_NAME,
    Key: {
      eventId: eventId,
      timestamp: Date.now(),
    },
    KeyConditionExpression: "eventId = :eventId AND #date = :date",
    ExpressionAttributeNames: {
      "#date": "date",
    },
    ExpressionAttributeValues: {
      ":eventId": eventId,
      ":date": date,
    },
  };

  const result = await dynamoDB.query(params).promise();
  return result.Items.length > 0 ? result.Items[0] : null;
}

async function saveWeatherEvent(eventId, alert, lat, lon, date) {
  const item = {
    eventId: eventId,
    timestamp: Date.now(),
    lat: parseFloat(lat),
    lon: parseFloat(lon),
    date: date,
    event: alert.event,
    description: alert.description,
    start: alert.start,
    end: alert.end,
    senderName: alert.sender_name,
  };

  const params = {
    TableName: TABLE_NAME,
    Item: item,
  };

  await dynamoDB.put(params).promise();
}
