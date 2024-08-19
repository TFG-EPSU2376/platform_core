ACCESS_KEY_ID=$1
SECRET_ACCESS_KEY=$2
OWNER_EMAIL=$3
ADMIN_EMAIL=$4
DOMAIN=$5:null
REGION=eu-central-1
# python -m pip install boto3
./init_configure_aws_cli.sh $ACCESS_KEY_ID $SECRET_ACCESS_KEY $REGION
printf "Creando usuario IAM para el portal\n"
printf "IAM ACCESS_KEY_ID: $ACCESS_KEY_ID\n"
printf "IAM SECRET_ACCESS_KEY: $SECRET_ACCESS_KEY\n"
cd create_iam_user
terraform init
terraform apply -auto-approve -var="email=$ADMIN_EMAIL"-var="optional_domain=example.com"
cd ..

ACCESS_KEY_ID=$(jq -r '.terraform_user_access_key_id.value' ../domains/core/output.json)
SECRET_ACCESS_KEY=$(jq -r '.terraform_user_secret_access_key.value' ../domains/core/output.json)
printf "IAM ACCESS_KEY_ID: $ACCESS_KEY_ID\n"
printf "IAM SECRET_ACCESS_KEY: $SECRET_ACCESS_KEY\n"
./init_configure_aws_cli.sh $ACCESS_KEY_ID $SECRET_ACCESS_KEY $REGION
python action_send_email_new_iam_user.py $OWNER_EMAIL $ADMIN_EMAIL $ACCESS_KEY_ID $SECRET_ACCESS_KEY $REGION
