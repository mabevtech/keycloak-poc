#!/bin/bash

### Pull keycloak projects from [AMBEV-SA/Plataforma-comum](https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/)

# Create a *libs/* directory if non-existent:
ls libs || mkdir libs

# Clone `keycloak-dotnet-client` into *libs/*:
git clone https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-dotnet-client libs/keycloak-dotnet-client

# Clone `keycloak-dotnet-jwt` into *libs/*:
git clone https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-dotnet-jwt libs/keycloak-dotnet-jwt

# Clone `keycloak-themes` into *libs/*:
git clone https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-themes libs/keycloak-themes
