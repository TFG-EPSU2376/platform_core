import json
import boto3
import json

json_file_path = '../domains/core/output.json'

with open(json_file_path, 'r') as file:
    data = json.load(file)

TableName = data['dynamodb_sensors_data_table_name']['value']
 
dynamodb = boto3.client('dynamodb', region_name='eu-central-1')

def lambda_handler(event, context):
    sensor_id = event.get('sensorId', 'SoilMoisture1')
    category = event.get('category', 'Temperature')
    
    response = dynamodb.query(
        TableName,
        IndexName='GSI1',
        KeyConditionExpression='sensorId = :sensorId AND begins_with(categoryTimestamp, :category)',
        ExpressionAttributeValues={
            ':sensorId': {'S': sensor_id},
            ':category': {'S': category}
        }
    )
    
    items = response['Items']
    data = []
    
    for item in items:
        data.append({
            'timestamp': item['timestamp']['S'],
            'value': float(item['value']['N'])
        })
    
    return {
        'statusCode': 200,
        'body': json.dumps(data)
    }
