import boto3
from decimal import Decimal
from datetime import datetime, timedelta
import math
import random
import json

dynamodb = boto3.resource('dynamodb', region_name='eu-central-1')
json_file_path = '../domains/core/output.json'

with open(json_file_path, 'r') as file:
    data = json.load(file)

table_name = data['dynamodb_sensors_data_table_name']['value']
table = dynamodb.Table(table_name)

sensors = [
    {"type": "SoilMoisture", "id": "SoilMoisture1", "categories": ["Temperature", "Humidity", "Rainfall"]},
    {"type": "SoilMoisture", "id": "SoilMoisture2", "categories": ["Temperature", "Humidity", "Rainfall"]},
]

def generate_sinusoidal_data(base, amplitude, period, phase, noise_factor):
    """Generates sinusoidal data with added random noise."""
    return base + amplitude * math.sin(2 * math.pi * phase / period) + random.uniform(-noise_factor, noise_factor)




last_timestamp = datetime.now()
last_timestamp = last_timestamp - timedelta(days=1)

interval_minutes = 10  # Fixed interval of 10 minutes for consistency
for i in range(500):  # Inserting 50 sample records per category per sensor
            timestamp = last_timestamp - timedelta(minutes=i * interval_minutes)
            timestamp_iso = timestamp.isoformat()
            rain = random.uniform(0, 100)
            rain = generate_sinusoidal_data(base=5, amplitude=25, period=1440, phase=i * interval_minutes, noise_factor=1)
            rain = max(0, min(round(rain), 50))  # Clamp value between 0 and 50 and round to nearest integer
    
            data3 = {
                'PK': "WeatherStation",
                'SK': f"WeatherStation#Rainfall#{timestamp_iso}",
                'Timestamp': timestamp_iso,
                'Value': Decimal(str(rain)),
                'DeviceID': "WeatherStation1",
                'Category': "Rainfall",
            }

            table.put_item(Item=data3)




for sensor in sensors:
    last_timestamp = datetime.now()
    last_timestamp = last_timestamp - timedelta(days=1)
    
    interval_minutes = 10  # Fixed interval of 10 minutes for consistency
    for i in range(500):  # Inserting 50 sample records per category per sensor
            timestamp = last_timestamp - timedelta(minutes=i * interval_minutes)
            timestamp_iso = timestamp.isoformat()
            temp = random.uniform(0, 100)
            temp = generate_sinusoidal_data(base=17.5, amplitude=22.5, period=1440, phase=i * interval_minutes, noise_factor=2)
            temp = max(-5, min(round(temp), 40))  # Clamp value between -5 and 40 and round to nearest intege
            # //para cada iteracion  crear un item de cada cosa en el table
            data1 = {
                'PK': "Temperature",
                'SK': f"{sensor['id']}#Temperature#{timestamp_iso}",
                'Timestamp': timestamp_iso,
                'Value': Decimal(str(temp)),
                'DeviceID': sensor['id'],
                'Category': "Temperature",
            }
            table.put_item(Item=data1)
            print(f"Inserted data: {data1}")
 


for sensor in sensors:
    last_timestamp = datetime.now()
    last_timestamp = last_timestamp - timedelta(days=1)
    interval_minutes = 10  # Fixed interval of 10 minutes for consistency
    for i in range(500):  # Inserting 50 sample records per category per sensor
            timestamp = last_timestamp - timedelta(minutes=i * interval_minutes)
            timestamp_iso = timestamp.isoformat()
            hum = random.uniform(0, 100)
            hum = generate_sinusoidal_data(base=50, amplitude=50, period=1440, phase=i * interval_minutes, noise_factor=5)
            hum = max(0, min(round(hum), 100))  # Clamp value between 0 and 100 and round to nearest integer

            data2 = {
                'PK': "Humidity",
                'SK': f"{sensor['id']}#Humidity#{timestamp_iso}",
                'Timestamp': timestamp_iso,
                'Value': Decimal(str(hum)),
                'DeviceID': sensor['id'],
                'Category': "Humidity",
            }
            table.put_item(Item=data2)
            print(f"Inserted data: {data2}")
 