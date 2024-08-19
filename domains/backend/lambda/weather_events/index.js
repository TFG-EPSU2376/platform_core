exports.handler = async (event) => {
  try {
    const data = [
      { reason: "Posibilidad de lluvia", date: "2024-05-25", color: "#00bcd4" },
      { reason: "Riesgo de heladas", date: "2024-05-26", color: "#ff0000" },
      { reason: "Alta temperatura", date: "2024-05-27", color: "#ff7300" },
    ];

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
          "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
        "Access-Control-Allow-Methods": "*",
      },
      body: JSON.stringify(data),
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({
        error: "Failed to fetch weather data",
        message: error,
      }),
    };
  }
};
