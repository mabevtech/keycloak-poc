#!/bin/sh

# Make sure we are in project root
cd $(dirname $0)/..

### Build component images

# Build resource-server image if non existent:
docker image inspect keycloak-poc/resource-server:1.0 -f'Resource server found' 2>/dev/null || \
    docker build -t keycloak-poc/resource-server:1.0 --file ResourceServer.Dockerfile .

# Build client-backend (back-channel) image if non existent:
docker image inspect keycloak-poc/client-backend:1.0 -f'Client backend found' 2>/dev/null || \
    docker build -t keycloak-poc/client-backend:1.0 --file ClientBackend.Dockerfile .

# Build client image if non existent:
docker image inspect keycloak-poc/client:1.0 -f'Client found' 2>/dev/null || \
    docker build -t keycloak-poc/client:1.0 --file Client.Dockerfile .
