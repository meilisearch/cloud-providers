#!/bin/bash

PUBLIC_IP=$1
status="$(curl http://$PUBLIC_IP/health)"

# Check if the variable content is equal to '{"status":"available"}'
if [ "$status" != '{"status":"available"}' ]; then
  # If not, echo the variable value and an error message, and exit with code 1
  echo "Error: Meilisearch is not running correctly."
  echo "Server response: $status"
  exit 1
else
  # If it is equal, echo a success message and exit with code 0
  echo "Meilisearch is available."
  exit 0
fi
