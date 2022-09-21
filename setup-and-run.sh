#!/bin/bash

### Load environment

# Create a copy of the *.env.development* file named *.env* (if non-existent yet):
cp -n .env.development .env

# Make all defined variables available to this and sub shells:
export $(xargs <.env) 2>/dev/null

# Clone internal projects
source ./clone-libs.sh

# Build component images
source ./build-images.sh

# Run the containers
docker-compose up -d client

# Wait for keycloak service to be ready
while ! curl --fail --silent --head http://localhost:${KEYCLOAK_PORT}; do
    sleep 1
done

# Feed sample data to Keycloak
source ./keycloak-data-setup.sh

# Wait for client app to be ready
while ! curl --fail --silent --head http://localhost:${CLIENT_PORT}; do
    sleep 1
done

# Open client in browser
cmd.exe /C start http://localhost:${KEYCLOAK_CLIENT_PORT}
