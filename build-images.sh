#!/bin/bash

### Build component images

# Build resource-server image:
docker build -t keycloak-poc/resource-server:1.0 --file ResourceServer.Dockerfile .

# Build client-backend (back-channel) image:
docker build -t keycloak-poc/keycloak-client-backend:1.0 --file ClientBackend.Dockerfile .

# Build client image:
docker build -t keycloak-poc/keycloak-client:1.0 --file Client.Dockerfile .
