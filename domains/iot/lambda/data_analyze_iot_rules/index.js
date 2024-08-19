const AWS = require("aws-sdk");
const sns = new AWS.SNS();

// Función para formatear la fecha
function formatDate(timestamp) {
  const date = new Date(timestamp);
  return date.toLocaleString("es-ES", { timeZone: "Europe/Madrid" });
}

// Plantilla HTML para el correo electrónico
const htmlTemplate = `
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alerta del Viñedo</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { width: 100%; max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background-color: #4CAF50; color: white; padding: 10px; text-align: center; }
        .content { background-color: #f9f9f9; padding: 20px; border-radius: 5px; }
        .footer { text-align: center; margin-top: 20px; font-size: 0.8em; color: #777; }
        .alert-details { margin-top: 20px; }
        .alert-details dt { font-weight: bold; }
        .alert-details dd { margin-left: 0; margin-bottom: 10px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Alerta del Viñedo</h1>
        </div>
        <div class="content">
            <h2>{{tipoAlerta}}</h2>
            <p>Se ha detectado una condición que requiere su atención:</p>
            <dl class="alert-details">
                <dt>Sensor:</dt>
                <dd>{{sensor}}</dd>
                <dt>Fecha y hora:</dt>
                <dd>{{fechaHora}}</dd>
                {{detallesAdicionales}}
            </dl>
            <p><strong>Acción recomendada:</strong> {{accionRecomendada}}</p>
        </div>
        <div class="footer">
            <p>Este es un mensaje automático del sistema de monitoreo del viñedo. Por favor, no responda a este correo.</p>
        </div>
    </div>
</body>
</html>
`;

// Función para generar el contenido HTML
function generateHtmlContent(event) {
  const alertTypes = {
    water_stress_detection: "Detección de estrés hídrico",
    phylloxera_condition_detection: "Condiciones favorables para la filoxera",
    grape_moth_condition_detection:
      "Condiciones favorables para la polilla del racimo",
    downy_mildew_condition_detection: "Condiciones favorables para el mildiu",
    powdery_mildew_condition_detection: "Condiciones favorables para el oídio",
  };

  const recommendedActions = {
    water_stress_detection: "Evalúe la necesidad de riego adicional.",
    phylloxera_condition_detection:
      "Inspeccione las raíces de las vides en busca de signos de filoxera.",
    grape_moth_condition_detection:
      "Considere aplicar medidas de control contra la polilla del racimo.",
    downy_mildew_condition_detection:
      "Considere la aplicación de fungicidas preventivos contra el mildiu.",
    powdery_mildew_condition_detection:
      "Evalúe la necesidad de tratamientos contra el oídio.",
  };

  let detallesAdicionales = "";
  for (const [key, value] of Object.entries(event)) {
    if (!["ruleId", "sensor", "timestamp"].includes(key)) {
      detallesAdicionales += `<dt>${key}:</dt><dd>${value}</dd>`;
    }
  }

  return htmlTemplate
    .replace("{{tipoAlerta}}", alertTypes[event.ruleId] || "Alerta desconocida")
    .replace("{{sensor}}", event.sensor || "Desconocido")
    .replace("{{fechaHora}}", formatDate(event.timestamp))
    .replace("{{detallesAdicionales}}", detallesAdicionales)
    .replace(
      "{{accionRecomendada}}",
      recommendedActions[event.ruleId] || "Revise las condiciones del viñedo."
    );
}

exports.handler = async (event) => {
  console.log("Event received:", JSON.stringify(event, null, 2));

  const htmlContent = generateHtmlContent(event);
  console.log("Event htmlContent:", JSON.stringify(htmlContent));

  const params = {
    Message: htmlContent,
    TopicArn: process.env.SNS_TOPIC_ARN,
    Subject: `Alerta del Viñedo: ${event.ruleId}`,
  };

  try {
    const result = await sns.publish(params).promise();
    console.log("Message published to SNS successfully:", result);
    console.log("Alert sent successfully");
    return { statusCode: 200, body: "Alert processed and sent" };
  } catch (error) {
    console.error("Error sending alert:", error);
    return { statusCode: 500, body: "Error processing alert" };
  }
};
