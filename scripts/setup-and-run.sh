#!/bin/sh

# Make sure we are in project root
cd $(dirname $0)/..

# Clone internal projects
./scripts/clone-libs.sh

# Build component images
./scripts/build-images.sh

# Run the containers
docker-compose up -d client

# Wait for keycloak service to be ready
echo "Waiting for keycloak to be ready..."
while ! curl --fail --silent --head http://localhost:${KEYCLOAK_PORT}; do
    sleep 1
done

# Feed sample data to Keycloak
./scripts/keycloak-data-setup.sh

# Wait for client app to be ready
echo "Waiting for client app to be ready..."
while ! curl --fail --silent --head http://localhost:${CLIENT_PORT}; do
    sleep 1
done

# Open client in browser
cmd.exe /C start http://localhost:${CLIENT_PORT}
