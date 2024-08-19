import boto3
import sys

def send_email(from_email, to_email, access_key_id, secret_access_key, region):
    ses_client = boto3.client('ses', region_name=region)
    
    subject = 'Credenciales de Usuario IAM para Terraform'
    body = f'''
    Hola,

    Las credenciales del usuario IAM son:
    Access Key ID: {access_key_id}
    Secret Access Key: {secret_access_key}

    Saludos,
    Tu Equipo
    '''
    
    response = ses_client.send_email(
        Source=from_email,
        Destination={
            'ToAddresses': [to_email],
        },
        Message={
            'Subject': {
                'Data': subject,
            },
            'Body': {
                'Text': {
                    'Data': body,
                },
            },
        }
    )
    return response

if __name__ == "__main__":
    from_email = sys.argv[1]
    to_email = sys.argv[2]
    access_key_id = sys.argv[3]
    secret_access_key = sys.argv[4]
    region = sys.argv[5]
  
    send_email(from_email, to_email, access_key_id, secret_access_key, region)
