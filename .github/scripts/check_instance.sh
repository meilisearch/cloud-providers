#!/bin/bash

start_time=$(date +%s)

while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' --max-time 5 http://11.1.1)" != "200" ]]; do
  sleep 5

  elapsed_time=$(($(date +%s) - $start_time))
  # A timeout error is raised after waiting for 10 minutes
  if [[ $elapsed_time -gt 600 ]]; then
    echo "Timeout error: The request took too long to complete."
    exit 1
  fi
done

echo "Instance is ready!"
exit 0
