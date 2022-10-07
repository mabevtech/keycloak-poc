#!/bin/sh

# Make sure we are in project root
cd $(dirname $0)/..

### Pull keycloak projects from [AMBEV-SA/Plataforma-comum](https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/)

# Create a *libs/* directory if non-existent:
ls libs 2>/dev/null || mkdir libs

# Clone `keycloak-dotnet-client` into *libs/* it not cloned yet:
ls libs/keycloak-dotnet-client 2>/dev/null || \
    git clone \
        https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-dotnet-client \
        libs/keycloak-dotnet-client

# Clone `keycloak-dotnet-jwt` into *libs/* if not cloned yet:
ls libs/keycloak-dotnet-jwt 2>/dev/null || \
    git clone \
        https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-dotnet-jwt \
        libs/keycloak-dotnet-jwt

# Clone `keycloak-themes` into *libs/* if not cloned yet:
ls libs/keycloak-themes 2>/dev/null || \
    git clone \
        https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-themes \
        libs/keycloak-themes

# Remove solution files as we're not using them
# and they can cause problems during build:
# https://github.com/dotnet/sdk/issues/2902
find | grep .sln | xargs rm 2>/dev/null
