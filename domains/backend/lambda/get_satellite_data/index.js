const fetch = require("node-fetch");

exports.handler = async (event) => {
  const apiId = process.env.AGROMONITORING_API_ID;
  const polyid = process.env.VINEYARD_POLYGON_ID;

  try {
    const polygonData = await fetchPolygonData(apiId, polyid);

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
          "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
        "Access-Control-Allow-Methods": "*",
      },
      body: JSON.stringify({
        polygonData: polygonData,
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

async function fetchPolygonData(apiId, polyid) {
  const url = `https://api.agromonitoring.com/agro/1.0/polygons/${polyid}?appid=${apiId}`;
  console.log("fetchPolygonData", url);
  const response = await fetch(url);
  const data = await response.json();
  console.log("data", data);

  return {
    id: data.id,
    name: data.name,
    center: data.center,
    area: data.area,
    coordinates: data.geo_json.geometry.coordinates[0],
  };
}
