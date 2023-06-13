#!/bin/bash

PUBLIC_IP=$1
status="$(curl http://$PUBLIC_IP/health)"

# Check if the variable content is equal to '{"status":"available"}'
if [ "$status" != '{"status":"available"}' ]; then
  echo "Error: Meilisearch is not running correctly."
  echo "Server response: $status"
  exit 1
else
  echo "Meilisearch is available."
  exit 0
fi
