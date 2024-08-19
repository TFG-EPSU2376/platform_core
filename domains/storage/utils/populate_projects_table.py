import boto3
from decimal import Decimal
from datetime import datetime
from utils import get_terraform_output
import uuid
import json

json_file_path = '../domains/core/output.json'

dynamodb = boto3.resource('dynamodb', region_name='eu-central-1')

with open(json_file_path, 'r') as file:
    data = json.load(file)

table_name = data['dynamodb_projects_table_name']['value']

table = dynamodb.Table(table_name)

project_id = str(uuid.uuid4())

project = {
    "projectId": project_id,
    "name": "Project1",
    "owner": "Owner1",
    "description": "This is a test project for monitoring vineyard conditions.",
    "location": {
        "country": "COUNTRY",
        "city": "CITY",
        "street": "STREET",
        "country_code": "COUNTRY_CODE",
        "postal_code": "POSTAL_CODE",
        "latitude": "LATITUDE",
        "longitude": "LONGITUDE"
    },
     "status": "active",
     "createdAt": datetime.now().isoformat(),
    "updatedAt": datetime.now().isoformat()
}

table.put_item(Item=project)
print(f"Inserted project: {project}")
