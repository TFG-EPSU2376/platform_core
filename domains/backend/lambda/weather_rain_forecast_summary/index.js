const fetch = require("node-fetch");

const getPrecipitationDataMeteostat = async (lat, lon, start, end, apiKey) => {
  const url = `https://meteostat.p.rapidapi.com/point/monthly?lat=${lat}&lon=${lon}&start=${start}&end=${end}`;
  console.log("url", url);

  const options = {
    method: "GET",
    headers: {
      "x-rapidapi-host": "meteostat.p.rapidapi.com",
      "x-rapidapi-key": apiKey,
    },
  };

  const response = await fetch(url, options);
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  const data = await response.json();

  if (!data || !data.data || !Array.isArray(data.data)) {
    throw new Error("Invalid data structure received from Meteostat");
  }
  return data;
};

const getPrecipitationDataOpenWeatherMap = async (lat, lon, apiKey) => {
  const url = `https://api.openweathermap.org/data/3.0/onecall?lat=${lat}&lon=${lon}&exclude=current,minutely,hourly,alerts&appid=${apiKey}`;
  console.log("url", url);
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  const data = await response.json();

  if (!data || !data.daily || !Array.isArray(data.daily)) {
    throw new Error("Invalid data structure received from OpenWeatherMap");
  }

  // OpenWeatherMap provides data for the next 7 days, including today
  return data.daily.map((day) => ({
    date: new Date(day.dt * 1000).toISOString().split("T")[0],
    precipitation: day.rain ? day.rain : 0,
  }));
};

exports.handler = async (event) => {
  try {
    const { lat, lon } = event.queryStringParameters || {};
    const meteostatApiKey = process.env.METEOSTAT_API_KEY;
    const openWeatherMapApiKey = process.env.OPENWEATHERMAP_API_KEY;

    if (!lat || !lon || !meteostatApiKey || !openWeatherMapApiKey) {
      throw new Error("Missing required parameters or API keys");
    }

    const endDate = new Date();
    const startDate = new Date(endDate);
    startDate.setFullYear(startDate.getFullYear() - 2); // Two years ago

    const start = startDate.toISOString().split("T")[0];
    const end = endDate.toISOString().split("T")[0];

    let monthlyPrecipitation;

    try {
      const meteostatData = await getPrecipitationDataMeteostat(
        lat,
        lon,
        start,
        end,
        meteostatApiKey
      );
      monthlyPrecipitation = meteostatData.data.map((month) => ({
        date: month.date,
        precipitation: month.prcp,
      }));
    } catch (meteostatError) {
      console.error("Error fetching data from Meteostat:", meteostatError);
      console.log("Falling back to OpenWeatherMap...");

      const openWeatherMapData = await getPrecipitationDataOpenWeatherMap(
        lat,
        lon,
        openWeatherMapApiKey
      );
      monthlyPrecipitation = openWeatherMapData;
    }

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Credentials": true,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ monthlyPrecipitation }),
    };
  } catch (error) {
    console.error("Lambda function error:", error);
    return {
      statusCode: error.statusCode || 500,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Credentials": true,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        error: "Error processing request",
        message: error.message,
      }),
    };
  }
};
