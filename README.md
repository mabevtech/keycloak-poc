This repo is a Proof-of-Concept of authentication/authorization with Keycloak, using the [OIDC](https://openid.net/connect/) standard and internal keycloak projects.

# Requirements

- `docker-compose`: the components are glued together with it
- Access to [AMBEV-SA/Plataforma-comum](https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/) repos: some projects are cloned and referenced
- a unix shell: startup scripts are provided in `.sh` format

# Components

We have a sample react app (**client**) that, with the help of a back-end* (**back-channel**), requests to keycloak (**authorization server**) to authenticate the user and get access to their roles, so it is possible to request protected resources (user contacts) to a **resource-server**.

These components are defined in a top-level docker-compose file:
 - **keycloak:** our Authorization Server
 - **resource-server**: a .NET web API with the protected resources
 - **client-backend**: a .NET web API acting as the client's back channel
 - **client**: a react app the user interacts with

\*See Flow section for updated details.

## Dependencies

The react app uses the `@react-keycloak/web` package to interact with Keycloak, which uses the official [keycloak-js](https://www.keycloak.org/docs/latest/securing_apps/#_javascript_adapter) adapter under the hood. Requests to the resource-server are made with the `axios` package.

The client-backend
TODO dependencies

## Authorization Flow

The `keycloak-js` adapter performs the Authorization Code Flow [by default](https://github.com/keycloak/keycloak-documentation/blob/main/securing_apps/topics/oidc/javascript-adapter.adoc#implicit-and-hybrid-flow), where the authorization endpoint returns an authorization code first, and then it is exchanged with the tokens themselves in another round-trip. This all is done by the adapter in browser-land. Originally it was intended to use this flow but using the **client-backend** for the second round-trip (code for tokens exchange), but I didn't figure out a simple way to do so with the official adapter.

In the meantime, `keycloak-dotnet-client` provides a way to get tokens from keycloak using a Client Credentials Flow, where a secret is used to get tokens on behalf of the user.

Thus, 2 authorization methods are provided in the app:
 - *User login*: authorization with Auth. Code flow, performed by **client** with no **client-backend** influence
 - *Api login*: authorization with Client Cred. flow, performed by **client-backend** when requested by the **client**

Unfortunately, both authorization mechanisms can't be available in parallel without exposing the secret to the **client** (front-channel):
 - if the **client** is confidential, Keycloak expects a secret in the token endpoint, so the **client** can't authenticate the user after they typed their credentials
 - if the **client** is public, it can't use the client-credentials grant, so the **client-backend** can't call the token endpoint (at least with the default request done by AmbevTech.Keycloak.Client.Service.TokenManager) to authenticate

> See [Confidential and Public Applications](https://auth0.com/docs/get-started/applications/confidential-and-public-applications) for more info about public/confidential clients.

### TODO update client.


# Setup

## Load env

Create a copy of the *.env.development* file named *.env*:
```shell
cp .env.development .env
```

Make all defined variables available to this and sub shells:
```shell
export $(xargs <.env)
```

## Pull keycloak projects from [AMBEV-SA/Plataforma-comum](https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/)

Create a *libs/* directory:
```shell
mkdir libs
```

Clone `keycloak-dotnet-client` into *libs/*:
```shell
git clone https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-dotnet-client libs/keycloak-dotnet-client
```

Clone `keycloak-dotnet-jwt` into *libs/*:
```shell
git clone https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-dotnet-jwt libs/keycloak-dotnet-jwt
```

Clone `keycloak-themes` into *libs/*:
```shell
git clone https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-themes libs/keycloak-themes
```

# Build images

Build resource-server image:
```shell
docker build -t keycloak-poc/resource-server:1.0 --file ResourceServer.Dockerfile .
```

Build client-backend (back-channel) image:
```shell
docker build -t keycloak-poc/keycloak-client-backend:1.0 --file ClientBackend.Dockerfile .
```

Build client image:
```shell
docker build -t keycloak-poc/keycloak-client:1.0 --file Client.Dockerfile .
```

For keycloak we're using the standard image ([quay.io/keycloak/keycloak](https://quay.io/repository/keycloak/keycloak))).

# Run

```shell
docker-compose up -d client
```

After a while a react app will load in your browser. Nothing will be working as Keycloak are still empty at this point. Execute the following script to fill Keycloak with sample data:

```shell
./keycloak-setup.sh
```

It will create a realm, a user, a client, a client role, and assign it to the user, so they'll have access to the protected endpoint in the resource-server. Check the `.env` file for credentials and other variables.

# While running

- keycloak stuff can be customized with standard admin login
- it is possible to update the frontend /client/src/
- it is possible to customize the theme /libs/keycloak-themes/theme/ambevtech-b2c

# Keycloak stuff

TODO Explain that resource=client.

We are using only the access token. It is a JWT.
In Keycloak a user can have different roles in different clients...

Token example with client_id_123:

```json
{
  ...
  "realm_access": {
    "roles": [
      "default-roles-myrealm",
      "offline_access",
      "rolex",
      "uma_authorization"
    ]
  },
  "resource_access": {
    "client_id_123": {
      "roles": [
        "read_contacts"
      ]
    },
    "account": {
      "roles": [
        "manage-account",
        "manage-account-links",
        "view-profile"
      ]
    }
  },
  ...
}
```
