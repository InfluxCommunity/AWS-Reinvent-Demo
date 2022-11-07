#!/bin/sh

# install local dashboard and tasks
influx apply --file ./demo/template.yml

# setup EDR to Cloud
source ./.secrets

if [ -z "$INFLUXDB_CLOUD_TOKEN" ]; then echo "You must add your remote cloud credentials to a .secrets file"; exit 1; fi

EXISTING_REPLICATION_ID=$(influx replication list --name coffee_cups --hide-headers |awk '{print $1}') 
if [ ! -z "$EXISTING_REPLICATION_ID" ]; then influx replication delete --id $EXISTING_REPLICATION_ID; fi

EXISTING_REMOTE_ID=$(influx remote list --name coffee_cloud --hide-headers |awk '{print $1}') 
if [ ! -z "$EXISTING_REMOTE_ID" ]; then influx remote delete --id ${EXISTING_REMOTE_ID}; fi

influx remote create --name coffee_cloud --org influxdata --remote-org-id ${INFLUXDB_CLOUD_ORG_ID} --remote-url ${INFLUXDB_CLOUD_HOST} --remote-api-token ${INFLUXDB_CLOUD_TOKEN}

REMOTE_ID=$(influx remote list --name coffee_cloud --hide-headers |awk '{print $1}') 

influx replication create --name coffee_cups --org influxdata --remote-id $REMOTE_ID --local-bucket-id e7999e4a85023417 --remote-bucket-id ${INFLUXDB_CLOUD_BUCKET_ID}
