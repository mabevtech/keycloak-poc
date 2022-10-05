#!/bin/sh

# Make sure we are in project root
cd $(dirname $0)/..

## Kill and recreate the Keycloak container
docker-compose rm -sf keycloak && docker-compose up -d keycloak

# Wait for it to be available again
echo "Waiting for keycloak to be ready..."
while ! curl --fail --silent --head http://localhost:${KEYCLOAK_PORT}; do
    sleep 1
done

# Feed data
./scripts/keycloak-data-setup.sh

