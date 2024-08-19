const fetch = require("node-fetch");

exports.handler = async (event) => {
  const apiId = process.env.AGROMONITORING_API_ID;
  const polyid = process.env.VINEYARD_POLYGON_ID;

  const date = event.queryStringParameters?.date
    ? new Date(event.queryStringParameters.date)
    : new Date();
  const targetTimestamp = Math.floor(date.getTime() / 1000);

  try {
    const satelliteData = await fetchSatelliteData(
      apiId,
      polyid,
      targetTimestamp
    );

    if (!satelliteData) {
      return {
        statusCode: 404,
        body: JSON.stringify({
          error: "No satellite data found for the specified date",
        }),
      };
    }

    const ndviImageUrl = satelliteData.image.ndvi;
    const polygonData = await fetchPolygonData(apiId, polyid);
    const ndviStats = await fetchNDVIStats(satelliteData.stats.ndvi);

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
          "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
        "Access-Control-Allow-Methods": "*",
      },
      body: JSON.stringify({
        metadata: {
          dt: satelliteData.dt,
          type: satelliteData.type,
          dc: satelliteData.dc,
          cl: satelliteData.cl,
          sun: satelliteData.sun,
        },
        ndviImageUrl: ndviImageUrl,
        polygonData: polygonData,
        ndviStats: ndviStats,
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

async function fetchSatelliteData(apiId, polyid, targetTimestamp) {
  const endDate = targetTimestamp;
  const startDate = endDate - 24 * 60 * 60 * 30; // 30 días antes
  const url = `https://api.agromonitoring.com/agro/1.0/image/search?start=${startDate}&end=${endDate}&polyid=${polyid}&appid=${apiId}`;
  console.log("fetchSatelliteData", url);

  const response = await fetch(url);
  const data = await response.json();
  console.log("fetchSatelliteDatadata", data);

  if (data.length === 0) {
    return null;
  }

  return data.reduce((prev, curr) =>
    Math.abs(curr.dt - targetTimestamp) < Math.abs(prev.dt - targetTimestamp)
      ? curr
      : prev
  );
}

async function fetchPolygonData(apiId, polyid) {
  const url = `https://api.agromonitoring.com/agro/1.0/polygons/${polyid}?appid=${apiId}`;
  const response = await fetch(url);
  const data = await response.json();
  return {
    id: data.id,
    name: data.name,
    center: data.center,
    area: data.area,
    coordinates: data.geo_json.geometry.coordinates[0],
  };
}

async function fetchNDVIStats(ndviStatsUrl) {
  const response = await fetch(ndviStatsUrl);
  return await response.json();
}
