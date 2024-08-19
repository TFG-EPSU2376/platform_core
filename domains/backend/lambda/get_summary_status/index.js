const AWS = require("aws-sdk");

exports.handler = async (event) => {
  try {
    const generalStatusData = {
      health: "Buena",
      healthColor: "#66bb6a",
      growth: "Óptimo",
      growthColor: "#76c7c0",
      pests: "Bajo Control",
      pestColor: "#ffcc00",
    };

    const data = {
      general: generalStatusData,
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
        error: "Failed to fetch project data",
        message: error.message,
      }),
    };
  }
};
