# Create a copy of the *.env.development* file named *.env*.

```shell
cp .env.development .env
```

# Pull internal keycloak libs

## Clone `keycloak-dotnet-client` into libs/

```shell
mkdir libs
git clone https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-dotnet-client libs/keycloak-dotnet-client
```

## Clone `keycloak-dotnet-jwt` into libs/

```shell
git clone https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-dotnet-jwt libs/keycloak-dotnet-jwt
```

## Clone `keycloak-themes` into libs/

```shell
git clone https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-themes libs/keycloak-themes
```

Build client-backend
docker build -t keycloak-poc/keycloak-client-backend:1.0 --file ClientBackend.Dockerfile .
