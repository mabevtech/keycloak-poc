#!/bin/sh

# Clone internal projects
./clone-libs.sh

# Build component images
./build-images.sh

# Run the containers
docker-compose up -d client

# Wait for keycloak service to be ready
echo "Waiting for keycloak to be ready..."
while ! curl --fail --silent --head http://localhost:${KEYCLOAK_PORT}; do
    sleep 1
done

# Feed sample data to Keycloak
./keycloak-data-setup.sh

# Wait for client app to be ready
echo "Waiting for client app to be ready..."
while ! curl --fail --silent --head http://localhost:${CLIENT_PORT}; do
    sleep 1
done

# Open client in browser
cmd.exe /C start http://localhost:${CLIENT_PORT}
