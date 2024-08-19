import boto3
from decimal import Decimal
from datetime import datetime, timedelta
import random

dynamodb = boto3.resource('dynamodb', region_name='eu-central-1')
table = dynamodb.Table('SensorDataTablegreat-pig')

sensors = [
    {"type": "SoilMoisture", "id": "SoilMoisture1", "categories": ["Temperature", "Humidity"]},
    {"type": "SoilMoisture", "id": "SoilMoisture2", "categories": ["Temperature", "Humidity"]},
    {"type": "OpticV1", "id": "FiberSensor1", "categories": ["Battery", "Fructosa"]},
    {"type": "OpticV1", "id": "FiberSensor2", "categories": ["Battery", "Fructosa"]}
]

for sensor in sensors:
    for category in sensor['categories']:
        for i in range(50):  # Inserting 100 sample records per category per sensor
            timestamp = (datetime.now() - timedelta(minutes=i)).isoformat()
            data = {
                'PK': sensor['type'],
                'SK': f"{sensor['id']}#{category}#{timestamp}",
                'Timestamp': timestamp,
                'Value': Decimal(str(random.uniform(0, 100))),
                'DeviceID': sensor['id'],
                'Category': category,
                # 'metadata': {
                #     'unit': 'Celsius' if category == 'Temperature' else 'Percentage'
                # }
            }
            table.put_item(Item=data)
            print(f"Inserted data: {data}")
