const fetch = require("node-fetch");

exports.handler = async (event) => {
  const lat = event.queryStringParameters.lat;
  const lon = event.queryStringParameters.lon;
  const apiKey = process.env.OPENWEATHERMAP_API_KEY;
  const currentWeatherUrl = `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=${apiKey}&units=metric`;
  const forecastUrl = `https://api.openweathermap.org/data/2.5/forecast?lat=${lat}&lon=${lon}&appid=${apiKey}&units=metric`;

  try {
    const [currentWeatherResponse, forecastResponse] = await Promise.all([
      fetch(currentWeatherUrl),
      fetch(forecastUrl),
      // fetch(pvgisUrl),
    ]);

    const currentWeatherData = await currentWeatherResponse.json();
    const forecastData = await forecastResponse.json();

    let radiationIndex = "No disponible";
    let ghiValue = null;
    let radiationDate = null;
    let colorCode = "#808080";

    const currentWeather = {
      radiation: {
        value: currentWeatherData.solarradiation?.value || null,
        index: radiationIndex,
        ghi: ghiValue,
        date: radiationDate,
        colorCode: colorCode,
      },
      time: currentWeatherData.dt,
      temp: currentWeatherData.main.temp,
      temp_min: currentWeatherData.main.temp_min,
      temp_max: currentWeatherData.main.temp_max,
      weather: currentWeatherData.weather[0].main,
      description: currentWeatherData.weather[0].description,
      icon: currentWeatherData.weather[0].icon,
      humidity: currentWeatherData.main.humidity,
      rain: currentWeatherData.rain ? currentWeatherData.rain["1h"] : 0,
    };

    const selectedIntervals = [3, 12, 24, 48];
    const filteredForecastData = forecastData.list.filter((entry, index) =>
      selectedIntervals.includes(index * 3)
    );

    const formattedForecastData = filteredForecastData.map((entry) => ({
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
      body: JSON.stringify({
        currentWeather,
        forecast: formattedForecastData,
      }),
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
