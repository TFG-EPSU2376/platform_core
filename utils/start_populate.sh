#!/bin/bash

# Ejecutar el script de Python para poblar la tabla
python3 ../domains/storage/utils/populate_projects_table.py
python3 ../domains/storage/utils/populate_sensor_data_table.py
python3 ../domains/storage/utils/populate_alerts_table.py
python3 ../domains/storage/utils/populate_recommendations_table.py


#  ./test_mqtt_sample_data.sh