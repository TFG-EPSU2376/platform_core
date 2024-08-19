const fetch = require("node-fetch");

exports.handler = async (event) => {
  const apiId = process.env.AGROMONITORING_API_ID;
  const polyid = process.env.VINEYARD_POLYGON_ID;

  const startDate = event.queryStringParameters?.startDate
    ? Math.floor(
        new Date(event.queryStringParameters.startDate).getTime() / 1000
      )
    : undefined;
  const endDate = event.queryStringParameters?.endDate
    ? Math.floor(new Date(event.queryStringParameters.endDate).getTime() / 1000)
    : undefined;
  console.log("startDate", startDate);
  console.log("endDate", endDate);
  try {
    const ndviHistory = await fetchNDVIHistory(
      apiId,
      polyid,
      startDate,
      endDate
    );

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
          "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
        "Access-Control-Allow-Methods": "*",
      },
      body: JSON.stringify({
        sampleDates: ndviHistory.map((item) => item.dt),
        chartData: ndviHistory.map((item) => ({
          date: new Date(item.dt * 1000).toISOString().split("T")[0],
          max: item.data.max,
          min: item.data.min,
          mean: item.data.mean,
        })),
      }),
    };
  } catch (error) {
    console.error(error);
    return {
      statusCode: 500,
      body: JSON.stringify({
        error: "Failed to process vineyard data",
        message: error.message,
      }),
    };
  }
};

async function fetchNDVIHistory(apiId, polyid, startDate, endDate) {
  const url = `http://api.agromonitoring.com/agro/1.0/ndvi/history?start=${startDate}&end=${endDate}&polyid=${polyid}&appid=${apiId}`;
  console.log("fetchNDVIHistory", url);
  const response = await fetch(url);
  const data = await response.json();
  console.log("data", data);

  return data.sort((a, b) => b.dt - a.dt); // Ordenar por fecha, más reciente primero
}
