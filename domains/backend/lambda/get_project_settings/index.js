const AWS = require("aws-sdk");
const dynamoDB = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  const TableName = process.env.PROJECTS_TABLE_NAME;

  const params = {
    TableName,
    Limit: 1,
  };

  try {
    const data = await dynamoDB.scan(params).promise();
    const project = data.Items[0] || {};

    return {
      statusCode: 200,
      body: JSON.stringify(project),
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
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
          "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
        "Access-Control-Allow-Methods": "*",
      },
      body: JSON.stringify({
        error: "Failed to fetch project data",
        message: error.message,
      }),
    };
  }
};
