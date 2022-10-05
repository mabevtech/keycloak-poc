#!/bin/sh

# Make sure we are in project root
cd $(dirname $0)/..

### Pull keycloak projects from [AMBEV-SA/Plataforma-comum](https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/)

# Create a *libs/* directory if non-existent:
ls libs || mkdir libs

# Clone `keycloak-dotnet-client` into *libs/* it not cloned yet:
ls libs/keycloak-dotnet-client || \
    git clone \
        https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-dotnet-client \
        libs/keycloak-dotnet-client

# Clone `keycloak-dotnet-jwt` into *libs/* if not cloned yet:
ls libs/keycloak-dotnet-jwt || \
    git clone \
        https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-dotnet-jwt \
        libs/keycloak-dotnet-jwt

# Clone `keycloak-themes` into *libs/* if not cloned yet:
ls libs/keycloak-themes || \
    git clone \
        https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-themes \
        libs/keycloak-themes
