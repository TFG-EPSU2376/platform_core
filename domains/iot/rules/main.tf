


data "archive_file" "data_iot_rules_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/data_analyze_iot_rules/"
  output_path = "${path.module}/../lambda/builds/data_analyze_iot_rules.zip"
  excludes    = []
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = var.vineyard_data_alerts_topic_arn
  protocol  = "email-json"
  endpoint  = "contact@EPSU2376.es"
}

resource "aws_sns_topic_subscription" "email_subscription_2" {
  topic_arn = var.vineyard_data_alerts_topic_arn
  protocol  = "email-json"
  endpoint  = "info@EPSU2376.es"
}

resource "aws_lambda_function" "process_vineyard_alert" {
  filename      = data.archive_file.data_iot_rules_zip.output_path
  function_name = "process_vineyard_alert"
  role          = var.iot_rule_assume_role_arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  environment {
    variables = {
      SENSOR_DATA_TABLE_NAME = var.sensors_data_table_name
      ALERTS_TABLE_NAME      = var.alerts_table_name
      SNS_TOPIC_ARN          = var.vineyard_data_alerts_topic_arn
    }
  }
  source_code_hash = filebase64sha256(data.archive_file.data_iot_rules_zip.output_path)
}

# Regla IoT para Estrés Hídrico
resource "aws_iot_topic_rule" "water_stress_rule" {
  name        = "water_stress_detection"
  description = "Detect water stress conditions"
  enabled     = true
  sql         = <<EOF
    SELECT * FROM 'iot/gw/+/data'
    WHERE 
      soil_moisture > 600
  EOF
  sql_version = "2016-03-23"

  lambda {
    function_arn = aws_lambda_function.process_vineyard_alert.arn
  }
}

# Regla IoT para Condiciones Favorables de Filoxera
resource "aws_iot_topic_rule" "phylloxera_rule" {
  name        = "phylloxera_condition_detection"
  description = "Detect favorable conditions for phylloxera"
  enabled     = true
  sql         = <<EOF
    SELECT * FROM 'iot/gw/+/data'
    WHERE 
      soil_temperature >= 20 AND soil_temperature <= 30 AND
      soil_moisture > 60
  EOF
  sql_version = "2016-03-23"

  lambda {
    function_arn = aws_lambda_function.process_vineyard_alert.arn
  }
}

# Regla IoT para Condiciones Favorables de Polilla del Racimo
resource "aws_iot_topic_rule" "grape_moth_rule" {
  name        = "grape_moth_condition_detection"
  description = "Detect favorable conditions for grape moth"
  enabled     = true
  sql         = <<EOF
    SELECT * FROM 'iot/gw/+/data'
    WHERE 
      air_temperature >= 15 AND air_temperature <= 25 AND
      timestamp() > (timestamp() - 3 * 24 * 60 * 60 * 1000)
  EOF
  sql_version = "2016-03-23"

  lambda {
    function_arn = aws_lambda_function.process_vineyard_alert.arn
  }
}

# Regla IoT para Condiciones Favorables de Mildiu
resource "aws_iot_topic_rule" "downy_mildew_rule" {
  name        = "downy_mildew_condition_detection"
  description = "Detect favorable conditions for downy mildew"
  enabled     = true
  sql         = <<EOF
    SELECT * FROM 'iot/gw/+/data'
    WHERE 
      relative_humidity > 95 AND
      air_temperature >= 15 AND air_temperature <= 20 AND
      timestamp() > (timestamp() - 6 * 60 * 60 * 1000)
  EOF
  sql_version = "2016-03-23"

  lambda {
    function_arn = aws_lambda_function.process_vineyard_alert.arn
  }
}

# Regla IoT para Condiciones Favorables de Oídio
resource "aws_iot_topic_rule" "powdery_mildew_rule" {
  name        = "powdery_mildew_condition_detection"
  description = "Detect favorable conditions for powdery mildew"
  enabled     = true
  sql         = <<EOF
    SELECT * FROM 'iot/gw/+/data'
    WHERE 
      air_temperature >= 20 AND air_temperature <= 28 AND
      relative_humidity >= 40 AND relative_humidity <= 70 AND
      timestamp() > (timestamp() - 5 * 24 * 60 * 60 * 1000)
  EOF
  sql_version = "2016-03-23"

  lambda {
    function_arn = aws_lambda_function.process_vineyard_alert.arn
  }
}
