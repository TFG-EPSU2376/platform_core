const AWS = require("aws-sdk");
const ses = new AWS.SES();

exports.handler = async (event) => {
  console.log(
    "Received event: send_alert_notification",
    JSON.stringify(event, null, 2)
  );

  const { to, subject, message } = event;

  if (!to || !subject || !message) {
    return {
      statusCode: 400,
      body: JSON.stringify("Missing 'to', 'subject', or 'message' parameter"),
    };
  }

  const params = {
    Destination: {
      ToAddresses: [to],
    },
    Message: {
      Body: {
        Text: {
          Data: message,
        },
      },
      Subject: {
        Data: subject,
      },
    },
    Source: "contact@EPSU2376.es",
  };

  try {
    await ses.sendEmail(params).promise();
    return {
      statusCode: 200,
      body: JSON.stringify("Email sent successfully"),
    };
  } catch (error) {
    console.error("Error sending email", error);
    return {
      statusCode: 500,
      body: JSON.stringify("Failed to send email"),
    };
  }
};
