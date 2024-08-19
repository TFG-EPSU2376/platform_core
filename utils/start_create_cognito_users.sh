#!/bin/bash
USER_POOL_ID=$1

USERNAME=User1
EMAIL=user1@EPSU2376.es
sudo aws cognito-idp admin-create-user \
    --user-pool-id $USER_POOL_ID \
    --username $USERNAME \
    --user-attributes Name=email,Value=$EMAIL \
    --desired-delivery-mediums EMAIL \
    --temporary-password EPSU23762024!

USERNAME=User2
EMAIL=user1@EPSU2376.es
sudo aws cognito-idp admin-create-user \
    --user-pool-id $USER_POOL_ID \
    --username $USERNAME \
    --user-attributes Name=email,Value=$EMAIL \
    --desired-delivery-mediums EMAIL \
    --temporary-password EPSU23762024!

USERNAME=User3
EMAIL=user1@EPSU2376.es
sudo aws cognito-idp admin-create-user \
    --user-pool-id $USER_POOL_ID \
    --username $USERNAME \
    --user-attributes Name=email,Value=$EMAIL \
    --desired-delivery-mediums EMAIL \
    --temporary-password EPSU23762024!