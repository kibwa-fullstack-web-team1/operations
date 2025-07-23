#!/bin/bash

# Check if fzf is installed


# Navigate to the operations directory
SCRIPT_DIR=$(dirname "$0")
cd "$SCRIPT_DIR/.." || { echo "Error: Could not navigate to operations directory."; exit 1; }

echo "Fetching Docker Compose service names..."
SERVICES=$(docker-compose config --services)

if [ -z "$SERVICES" ]; then
    echo "No services found in docker-compose.yml or docker-compose is not running." # docker-compose가 실행 중이 아닐 수도 있음을 명시
    exit 1
fi

echo "Select a service to view its logs (use arrow keys and Enter):"
SELECTED_SERVICE=$(echo "$SERVICES" | /usr/bin/fzf --prompt="Select service: " --height=20% --layout=reverse --border)

if [ -z "$SELECTED_SERVICE" ]; then
    echo "No service selected. Exiting."
    exit 0
fi

echo "Viewing logs for service: $SELECTED_SERVICE (Press Ctrl+C to stop)"
docker-compose logs -f "$SELECTED_SERVICE"
