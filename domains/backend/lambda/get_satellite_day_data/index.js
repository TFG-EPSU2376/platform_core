const fetch = require("node-fetch");

exports.handler = async (event) => {
  const apiId = process.env.AGROMONITORING_API_ID;
  const polyid = process.env.VINEYARD_POLYGON_ID;

  try {
    const selectedDate = event.queryStringParameters?.date
      ? Math.floor(new Date(event.queryStringParameters.date).getTime() / 1000)
      : undefined;

    const ndviImage = await fetchNDVIImageData(apiId, polyid, selectedDate);
    const ndviStats = await fetchNDVIStats(ndviImage.statsUrl);

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
          "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
        "Access-Control-Allow-Methods": "*",
      },
      body: JSON.stringify({
        ndviImageUrl: ndviImage?.image,
        ndviStats: ndviStats,
        dt: ndviImage?.dt,
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

async function fetchNDVIImageData(apiId, polyid, date) {
  const endDate = date;
  const startDate = date - 17 * 86400;
  const url = `https://api.agromonitoring.com/agro/1.0/image/search?start=${startDate}&end=${endDate}&polyid=${polyid}&appid=${apiId}`;
  console.log("fetchNDVIImageUrl", url);
  const response = await fetch(url);
  const data = await response.json();
  console.log("data", data);

  const item = data?.[0];
  if (!item) {
    return null;
  }
  return { dt: item.dt, image: item.image?.ndvi, statsUrl: item.stats.ndvi };
}

async function fetchNDVIStats(ndviStatsUrl) {
  const response = await fetch(ndviStatsUrl);
  return await response.json();
}
