import boto3
from decimal import Decimal
from datetime import datetime, timedelta
import random
import uuid
import json

dynamodb = boto3.resource('dynamodb', region_name='eu-central-1')
json_file_path = '../domains/core/output.json'

with open(json_file_path, 'r') as file:
    data = json.load(file)

table_name = data['dynamodb_table_name_recommendations']['value']
table = dynamodb.Table(table_name)

# Función para generar una recomendación
def generate_recommendation(title, description, rec_type, date):
    return {
        'recommendationId': str(uuid.uuid4()),
        'createdAt': date.isoformat(),
        'Title': title,
        'Description': description,
        'Type': rec_type
    }

# Lista de posibles recomendaciones
recommendations_data = [
    ("Riego", "Es un buen momento para regar las vides. 💧", "Mantenimiento"),
    ("Poda", "Recuerda podar las vides para fomentar un crecimiento saludable. ✂️", "Mantenimiento"),
    ("Fertilización", "Aplicar fertilizante para enriquecer el suelo. 🌱", "Nutrición"),
    ("Revisión de plagas", "Inspeccionar las vides para detectar posibles plagas. 🐛", "Mantenimiento"),
    ("Recolección", "Es tiempo de cosechar las uvas maduras. 🍇", "Cosecha"),
    ("Desbroce", "Elimina las malas hierbas alrededor de las vides. 🌿", "Mantenimiento"),
    ("Revisión del riego", "Verifica el sistema de riego para asegurar su correcto funcionamiento. 💧", "Mantenimiento"),
    ("Tratamiento de enfermedades", "Aplicar tratamientos preventivos para enfermedades comunes en el viñedo. 💊", "Salud"),
    ("Protección contra heladas", "Instalar protecciones contra heladas. ❄️", "Protección"),
    ("Monitoreo del clima", "Revisar el pronóstico del tiempo y ajustar las tareas según sea necesario. 🌤️", "Planificación")
]

# Generar recomendaciones para un rango de fechas
start_date = datetime(2024, 5, 1)
end_date = datetime(2024, 6, 1)
current_date = start_date

while current_date <= end_date:
    recommendations = []

    # Generar diferentes recomendaciones
    for _ in range(5):  # Generar 5 recomendaciones por día
        title, description, rec_type = random.choice(recommendations_data)
        recommendations.append(generate_recommendation(
            title,
            description,
            rec_type,
            current_date
        ))

    for recommendation in recommendations:
        table.put_item(Item=recommendation)
        print(f"Inserted recommendation: {recommendation}")

    # Incrementar la fecha actual
    current_date += timedelta(days=1)
