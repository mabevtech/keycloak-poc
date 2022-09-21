#!/bin/bash

## Kill and recreate the Keycloak container

docker-compose stop keycloak && docker-compose rm -f keycloak && docker-compose up keycloak

# Wait for it to be available again
while ! curl --fail --silent --head http://localhost:${KEYCLOAK_PORT}; do
    sleep 1
done

# Feed data
source ./keycloak-data-setup.sh
