#!/bin/bash

ACCESS_KEY_ID=$1
SECRET_ACCESS_KEY=$2
REGION=$3

sudo aws configure set aws_access_key_id $ACCESS_KEY_ID
sudo aws configure set aws_secret_access_key $SECRET_ACCESS_KEY
sudo aws configure set region $REGION
sudo aws configure set output json