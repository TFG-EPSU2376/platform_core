OWNER_EMAIL=$1
ADMIN_EMAIL=$2
REGION=$3

aws ses verify-email-identity --email-address $OWNER_EMAIL --region $REGION
aws ses verify-email-identity --email-address $ADMIN_EMAIL --region $REGION
