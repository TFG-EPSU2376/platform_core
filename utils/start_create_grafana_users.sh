#!/bin/bash

IDENTITY_STORE_ID=$1
WORKSPACE_ID=$(aws grafana list-workspaces --query 'workspaces[?name==`portal-grafana-workspace2_bright-mole`].id' --output text)

 ADMIN_GROUP_NAME="grafana-batch-op-dashboard-admin"
VIEWER_GROUP_NAME="grafana-batch-op-dashboard-viewer"

 ADMIN_GROUP=$(aws identitystore list-groups --identity-store-id $IDENTITY_STORE_ID --query "Groups[?DisplayName=='$ADMIN_GROUP_NAME'].GroupId" --output text)
if [ -z "$ADMIN_GROUP" ]; then
  ADMIN_GROUP=$(aws identitystore create-group --identity-store-id $IDENTITY_STORE_ID --display-name $ADMIN_GROUP_NAME --query 'GroupId' --output text)
fi

# Obtener o crear grupo de visualización
VIEWER_GROUP=$(aws identitystore list-groups --identity-store-id $IDENTITY_STORE_ID --query "Groups[?DisplayName=='$VIEWER_GROUP_NAME'].GroupId" --output text)
if [ -z "$VIEWER_GROUP" ]; then
  VIEWER_GROUP=$(aws identitystore create-group --identity-store-id $IDENTITY_STORE_ID --display-name $VIEWER_GROUP_NAME --query 'GroupId' --output text)
fi


# Crear usuario grafana admin
EMAIL=grafana_admin@EPSU2376.es
USER_NAME=grafana_admin
aws identitystore create-user --identity-store-id $IDENTITY_STORE_ID --user-name $USER_NAME --display-name $USER_NAME --emails "[{ \"Value\": \"$EMAIL\", \"Primary\": true }]" --name "GivenName=User,FamilyName=Admin"
USER_ID=$(aws identitystore list-users --identity-store-id $IDENTITY_STORE_ID --query "Users[?UserName=='$USER_NAME'].UserId" --output text)
aws identitystore create-group-membership --identity-store-id $IDENTITY_STORE_ID --group-id $ADMIN_GROUP --member-id UserId="$USER_ID"
aws grafana update-permissions --workspace-id $WORKSPACE_ID \
    --update-instruction-batch \
    "action=ADD,role=ADMIN,users=[{id=$ADMIN_GROUP,type=SSO_GROUP}]"

 

# Crear usuario grafana viewer
EMAIL=grafana_viewer@EPSU2376.es
USER_NAME=grafana_viewer
aws identitystore create-user --identity-store-id $IDENTITY_STORE_ID --user-name $USER_NAME --display-name $USER_NAME --emails "[{ \"Value\": \"$EMAIL\", \"Primary\": true }]" --name "GivenName=User,FamilyName=Viewer"
USER_ID=$(aws identitystore list-users --identity-store-id $IDENTITY_STORE_ID --query "Users[?UserName=='$USER_NAME'].UserId" --output text)
aws identitystore create-group-membership --identity-store-id $IDENTITY_STORE_ID --group-id $VIEWER_GROUP --member-id UserId="$USER_ID"
aws grafana update-permissions --workspace-id $WORKSPACE_ID \
    --update-instruction-batch \
    "action=ADD,role=VIEWER,users=[{id=$VIEWER_GROUP,type=SSO_GROUP}]"
 