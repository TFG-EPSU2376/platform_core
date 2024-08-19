const AWS = require("aws-sdk");

export const returnLambdaEndpoint = (event, { statusCode, headers, body }) => {
  return {
    statusCode: statusCode ?? 200,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers":
        "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
      "Access-Control-Allow-Methods": "*",
      ...headers,
    },
    body,
  };
};

export const handleLambdaFunction = async (event, execute) => {
  try {
    const response = await execute(event);
    return returnLambdaEndpoint(event, response);
  } catch (error) {
    return returnLambdaEndpoint(event, {
      statusCode: 500,
      body: JSON.stringify({
        error: "Failed to fetch sensors data",
        message: error.message,
      }),
    });
  }
};
//   try {
//     const data = await dynamoDB.scan(params).promise();
//     const items = data.Items.map((item) => ({
//       date: item.Timestamp,
//       title: item.Title,
//       description: item.Description,
//       severity: 0,
//       metadata: item.metadata || {},
//     }));

//     return returnLambdaEndpoint(event, {
//       statusCode: 200,
//       body: JSON.stringify({
//         items,
//         lastEvaluatedKey:
//           items.length > 0 && data.LastEvaluatedKey
//             ? JSON.stringify(data.LastEvaluatedKey)
//             : null,
//       }),
//     });
//   } catch (error) {
//     return returnLambdaEndpoint(event, {
//       statusCode: 500,
//       body: JSON.stringify({
//         error: "Failed to fetch sensors data",
//         message: error.message,
//       }),
//     });
//   }
// };
