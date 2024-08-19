const AWS = require("aws-sdk");
const lambda = new AWS.Lambda();

exports.handler = async (event) => {
  console.log(
    "Received event: send_alert_notification",
    JSON.stringify(event, null, 2)
  );

  const { alert_type, severity_level, data } = event;

  if (!alert_type || severity_level === undefined) {
    return {
      statusCode: 400,
      body: JSON.stringify(
        "Missing 'alert_type', 'severity_level', or 'data' parameter"
      ),
    };
  }

  let template;
  switch (alert_type) {
    case "type1":
      template = `Alert Type: ${alert_type}\nData: ${data}`;
      break;
    case "type2":
      template = `Alert Type: ${alert_type}\nDetails: ${data}`;
      break;
    // Add more cases as needed
    default:
      template = `Alert Type: ${alert_type}\nData: ${JSON.stringify(data)}`;
  }

  const action = severity_level === 10 ? "sms" : "email";
  const FunctionName = `send_alert_${action}`;
  const to = action === "sms" ? event.phone : event.email;
  const subject = `Alert: ${alert_type}`;
  const message = template;
  const Payload = JSON.stringify({
    to,
    subject,
    message,
  });

  console.log("Invoking Lambda function:", FunctionName, Payload);
  const params = {
    FunctionName,
    InvocationType: "Event",
    Payload,
  };

  try {
    await lambda.invoke(params).promise();
    return {
      statusCode: 200,
      body: JSON.stringify("Notification sent successfully"),
    };
  } catch (error) {
    console.error("Error invoking Lambda", error);
    return {
      statusCode: 500,
      body: JSON.stringify("Failed to send notification"),
    };
  }
};
