# Create a copy of the *.env.development* file named *.env*.

```shell
cp .env.development .env
```

# Make all defined variables available to this and sub shells
```shell
export $(xargs <.env)
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

# Build client-backend (back-channel) image

```shell
docker build -t keycloak-poc/keycloak-client-backend:1.0 --file ClientBackend.Dockerfile .
```


# Run only the api

```shell
docker-compose up client-backend
```

Sending a GET request to the /token endpoint makes the api request a token to keycloak and return it
