const AWS = require("aws-sdk");
const sns = new AWS.SNS();

exports.handler = async (event) => {
  console.log("Received event: send_alert_sms", JSON.stringify(event, null, 2));

  const { to, subject, message } = event;

  if (!to || !message) {
    return {
      statusCode: 400,
      body: JSON.stringify("Missing 'to' or 'message' parameter"),
    };
  }

  const params = {
    Message: `${subject ? subject + ": " : ""}${message}`,
    PhoneNumber: to,
  };

  try {
    await sns.publish(params).promise();
    return {
      statusCode: 200,
      body: JSON.stringify("SMS sent successfully"),
    };
  } catch (error) {
    console.error("Error sending SMS", error);
    return {
      statusCode: 500,
      body: JSON.stringify("Failed to send SMS"),
    };
  }
};
