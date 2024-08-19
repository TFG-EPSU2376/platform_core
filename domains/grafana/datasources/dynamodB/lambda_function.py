import json
import boto3
from boto3.dynamodb.conditions import Key
import json

json_file_path = '../domains/core/output.json'

with open(json_file_path, 'r') as file:
    data = json.load(file)

table_name = data['dynamodb_sensors_data_table_name']['value']
 
dynamodb = boto3.resource('dynamodb', region_name='eu-central-1')
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    device_id = event.get('DeviceID', 'sensor-12345')
    category = event.get('Category', 'Temperature')
    start_time = event.get('StartTime', '2021-05-01T00:00:00Z')
    end_time = event.get('EndTime', '2021-05-02T00:00:00Z')
    
    response = table.query(
        KeyConditionExpression=Key('DeviceID').eq(device_id) & Key('Timestamp').between(start_time, end_time)
    )
    
    items = response['Items']
    data = []

    for item in items:
        data.append({
            'timestamp': item['Timestamp'],
            'value': item['Value'],
            'category': item['Category']
        })
    
    return {
        'statusCode': 200,
        'body': json.dumps(data)
    }
