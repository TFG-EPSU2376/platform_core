import fetch from "node-fetch";
import { fromArrayBuffer } from "geotiff";

export const handler = async (event) => {
  const apiId = process.env.AGROMONITORING_API_ID;
  const polyid = "POLYGON_ID"; // Reemplaza con el ID de tu polígono

  const date = event.queryStringParameters?.date
    ? new Date(event.queryStringParameters.date)
    : new Date();
  const endDate = Math.floor(date.getTime() / 1000);
  const startDate = endDate - 24 * 60 * 60 * 15; // 15 días antes
  const nextDay = Math.min(
    endDate + 24 * 60 * 60,
    Math.floor(Date.now() / 1000)
  );
  const url = `https://api.agromonitoring.com/agro/1.0/image/search?start=${startDate}&end=${nextDay}&polyid=${polyid}&appid=${apiId}`;
  console.log("url", url);
  try {
    const response = await fetch(url);
    const data = await response.json();
    console.log("data", JSON.stringify(data));

    if (data.length === 0) {
      return {
        statusCode: 404,
        body: JSON.stringify({ error: "No NDVI TIFF file found" }),
      };
    }

    const ndviItems = data?.filter((item) => item.data.ndvi); // Filtrar elementos que tengan un archivo NDVI TIFF
    if (ndviItems?.length === 0) {
      return {
        statusCode: 404,
        body: JSON.stringify({ error: "No NDVI TIFF file found" }),
      };
    }
    console.log("ndviItems", ndviItems);
    const latestItem = ndviItems[ndviItems.length - 1]; // Obtener el último elemento (más reciente)
    const tiffUrl = latestItem.data.ndvi;
    console.log("tiffUrl", tiffUrl);
    // Descargar y procesar el archivo TIFF
    const tiffResponse = await fetch(tiffUrl);
    const arrayBuffer = await tiffResponse.arrayBuffer();
    const tiff = await fromArrayBuffer(arrayBuffer);
    const image = await tiff.getImage();
    const rasterData = await image.readRasters();
    console.log("rasterData", JSON.stringify(rasterData));

    // Verificar la cantidad de bandas
    const numBands = rasterData.length;
    console.log("numBands", numBands);
    if (numBands !== 1) {
      return {
        statusCode: 500,
        body: JSON.stringify({
          error: `Expected 1 band but found ${numBands} bands`,
        }),
      };
    }

    const values = rasterData[0]; // Usar la primera banda de datos
    const stats = calculateStats(values);

    const metadata = {
      dt: latestItem.dt,
      type: latestItem.type,
      dc: latestItem.dc,
      cl: latestItem.cl,
      sun: {
        elevation: latestItem.sun.elevation,
        azimuth: latestItem.sun.azimuth,
      },
    };
    console.log("stats", stats);

    const tiepoint = image.getTiePoints()[0];
    // const [originX, originY] = tiepoint.coordinate;
    const originX = tiepoint.x;
    const originY = tiepoint.y;
    const pixelScale = image.getFileDirectory().ModelPixelScale;

    // Transformar coordenadas de píxeles a coordenadas geográficas
    const pixelToGeo = (x, y) => {
      const lon = originX + x * pixelScale[0];
      const lat = originY - y * pixelScale[1];
      return [lon, lat];
    };

    // Formatear los datos para Mapbox
    const width = image.getWidth();
    const height = image.getHeight();
    const formattedData = {
      type: "FeatureCollection",
      features: [],
    };

    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const value = values[y * width + x];
        if (value !== undefined && value != -9999) {
          const [lon, lat] = pixelToGeo(x, y);

          formattedData.features.push({
            type: "Feature",
            geometry: {
              type: "Point",
              coordinates: [lon, lat],
              properties: {
                value,
              },
            },
          });
        }
      }
    }

    // Calcular las fechas para los punteros
    const prevDate = new Date(date);
    prevDate.setDate(prevDate.getDate() - 1);

    const nextDate =
      date.getDate() == new Date().getDate() ? undefined : new Date(date);
    nextDate?.setDate(nextDate.getDate() + 1);

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
          "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
        "Access-Control-Allow-Methods": "*",
      },
      body: JSON.stringify({
        metadata,
        stats,
        data: formattedData,
        prevDate: prevDate.toISOString().split("T")[0],
        nextDate: nextDate ? nextDate.toISOString().split("T")[0] : undefined,
      }),
    };
  } catch (error) {
    console.error(error);
    return {
      statusCode: 500,
      body: JSON.stringify({
        error: "Failed to fetch and process NDVI data",
        message: error.message,
      }),
    };
  }
};

const calculateStats = (values) => {
  const num = values.length;
  const mean = values.reduce((sum, value) => sum + value, 0) / num;
  const std = Math.sqrt(
    values.reduce((sum, value) => sum + (value - mean) ** 2, 0) / num
  );
  const min = Math.min(...values);
  const max = Math.max(...values);
  values.sort((a, b) => a - b);
  const p25 = values[Math.floor(num * 0.25)];
  const median = values[Math.floor(num * 0.5)];
  const p75 = values[Math.floor(num * 0.75)];

  return { std, p25, num, min, max, median, p75, mean };
};
