const fetch = require("node-fetch");

exports.handler = async (event) => {
  const lat = event.queryStringParameters.lat;
  const lon = event.queryStringParameters.lon;
  const apiKey = process.env.OPENWEATHERMAP_API_KEY;
  const forecastUrl = `https://api.openweathermap.org/data/2.5/forecast?lat=${lat}&lon=${lon}&appid=${apiKey}&units=metric`;

  try {
    const response = await fetch(forecastUrl);
    const data = await response.json();
    const selectedIntervals = [3, 12, 24, 48];
    const filteredData = data.list.filter((entry, index) =>
      selectedIntervals.includes(index * 3)
    );

    const formattedData = filteredData.map((entry) => ({
      time: entry.dt_txt,
      temp: entry.main.temp,
      temp_min: entry.main.temp_min,
      temp_max: entry.main.temp_max,
      weather: entry.weather[0].main,
      description: entry.weather[0].description,
      icon: entry.weather[0].icon,
      humidity: entry.main.humidity,
      rain: entry.rain ? entry.rain["3h"] : 0,
    }));

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
          "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
        "Access-Control-Allow-Methods": "*",
      },
      body: JSON.stringify(formattedData),
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
