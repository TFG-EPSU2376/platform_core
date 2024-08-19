import boto3
from decimal import Decimal
from datetime import datetime, timedelta
import random
import uuid
import json

json_file_path = '../domains/core/output.json'

# Configurar DynamoDB
dynamodb = boto3.resource('dynamodb', region_name='eu-central-1')
with open(json_file_path, 'r') as file:
    data = json.load(file)

table_name = data['dynamodb_alerts_table_name']['value']


table = dynamodb.Table(table_name)

# Función para generar una alerta
def generate_alert(alert_id, title, description, severity, date, temperature_max, temperature_min, humidity, precipitation, condition):
    return {
        'alertId': alert_id,
        'createdAt': date.isoformat(),
        'Title': title,
        'Description': description,
        'Severity': severity,
        'Metadata': {
            'time': date.strftime("%a, %d %b"),
            'temperatureMax': Decimal(str(temperature_max)),
            'temperatureMin': Decimal(str(temperature_min)),
            'humidity': Decimal(str(humidity)),
            'precipitation': Decimal(str(precipitation)),
            'condition': condition
        }
    }

# Generar alertas para un rango de fechas
start_date = datetime(2024, 5, 1)
end_date = datetime(2024, 6, 1)
current_date = start_date

while current_date <= end_date:
    alerts = []

    # Generar diferentes tipos de alertas
    alerts.append(generate_alert(
        str(uuid.uuid4()),  # Generar un alertId único
        "Posibilidad de lluvia",
        "Se esperan lluvias moderadas durante el día.",
        random.randint(1, 3),
        current_date,
        random.randint(10, 20),
        random.randint(5, 10),
        random.randint(60, 90),
        random.randint(5, 20),
        "Lluvias Moderadas"
    ))

    alerts.append(generate_alert(
        str(uuid.uuid4()),  # Generar un alertId único
        "Riesgo de heladas",
        "Se espera una bajada drástica de las temperaturas con posibilidad de heladas.",
        random.randint(1, 3),
        current_date + timedelta(days=1),
        random.randint(0, 5),
        random.randint(-5, 0),
        random.randint(50, 70),
        0,
        "Heladas"
    ))

    alerts.append(generate_alert(
        str(uuid.uuid4()),  # Generar un alertId único
        "Alta temperatura",
        "Se espera una ola de calor con temperaturas muy altas.",
        random.randint(1, 3),
        current_date + timedelta(days=2),
        random.randint(35, 45),
        random.randint(25, 30),
        random.randint(20, 30),
        0,
        "Ola de Calor"
    ))

    alerts.append(generate_alert(
        str(uuid.uuid4()),  # Generar un alertId único
        "Fuerte tormenta",
        "Se espera una fuerte tormenta con vientos y lluvias intensas.",
        random.randint(1, 3),
        current_date + timedelta(days=3),
        random.randint(15, 25),
        random.randint(10, 15),
        random.randint(80, 100),
        random.randint(20, 50),
        "Tormenta"
    ))

    alerts.append(generate_alert(
        str(uuid.uuid4()),  # Generar un alertId único
        "Semana de sequía",
        "Se espera un periodo sin precipitaciones.",
        random.randint(1, 3),
        current_date + timedelta(days=7),
        random.randint(25, 35),
        random.randint(15, 25),
        random.randint(10, 20),
        0,
        "Sequía"
    ))

    alerts.append(generate_alert(
        str(uuid.uuid4()),  # Generar un alertId único
        "Alta humedad",
        "Se espera un periodo con alta humedad.",
        random.randint(1, 3),
        current_date + timedelta(days=4),
        random.randint(20, 30),
        random.randint(15, 20),
        random.randint(70, 100),
        random.randint(0, 5),
        "Alta Humedad"
    ))

    for alert in alerts:
        try:
            table.put_item(Item=alert)
            print(f"Inserted alert: {alert}")
        except boto3.exceptions.Boto3Error as e:
            print(f"Failed to insert alert: {alert}")
            print(e)

    # Incrementar la fecha actual
    current_date += timedelta(days=5)
