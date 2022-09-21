This repo is a Proof-of-Concept of authentication/authorization with Keycloak, using the [OIDC](https://openid.net/connect/) standard and internal keycloak projects.

# Requirements

- `docker-compose`: the components are glued together with it
- Access to [AMBEV-SA/Plataforma-comum](https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/) repos: some projects are cloned and referenced
- a unix shell: startup scripts are provided in `.sh` format

# Setup and run

First, create the env file with the environment variables:
```shell
cp -n .env.development .env
```

You can open the `.env` file in your editor to tweak some variable if you want.

Make all defined variables available to this and sub shells:
```shell
export $(grep -v '^#' .env | xargs)
```

Run the following script in the terminal:
```shell
./setup-and-run.sh
```

And wait. At some point you'll be prompted to type a password to clone repositories from [AMBEV-SA/Plataforma-comum](https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/). You can get one in any repository like [this one](https://dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-themes) by clicking *Clone* > *Generate Git Credentials* > Copy password.

After completion the browser should open with a running application. If not, open manually http://localhost:8080.

## Tweaking

The client application can be tweaked on the fly by changing files under `./client/src`. Keycloak's login theme can also be updated on the fly by changing files in `./libs/keycloak-themes/theme/ambevtech-b2c`. To update Keycloak configuration (User/Client/Roles/etc) it is necessary to login to Keycloak's admin console, check the `.env` file for Keycloak port and admin credentials.

# Components

We have a sample react app (**client**) that, with the help of a back-end* (**back-channel**), requests to keycloak (**authorization server**) to authenticate the user and get access to their roles, so it is possible to request protected resources (user contacts) to a **resource-server**.

These components are defined in a top-level docker-compose file:
 - **keycloak:** our Authorization Server
 - **resource-server**: a .NET web API with the protected resources
 - **client-backend**: a .NET web API acting as the client's back channel
 - **client**: a react app the user interacts with

\*See *Authorization Flow* section for updated details.

## Dependencies

The react app uses the `@react-keycloak/web` package to interact with Keycloak, which uses the official [keycloak-js](https://www.keycloak.org/docs/latest/securing_apps/#_javascript_adapter) adapter under the hood. Requests to the **client-backend** and **resource-server** are made with the `axios` package.

The **client-backend** relies on the `keycloak-dotnet-client` to make token requests to Keycloak.

The **resource-server** relies on the `keycloak-dotnet-jwt` to validate and parse tokens issued by
Keycloak.

We also are using `keycloak-themes` to configure a custom theme for the login page in Keycloak.

## Authorization Flow

The `keycloak-js` adapter performs the Authorization Code Flow [by default](https://github.com/keycloak/keycloak-documentation/blob/main/securing_apps/topics/oidc/javascript-adapter.adoc#implicit-and-hybrid-flow), where the authorization endpoint returns an authorization code first, and then it is exchanged with the tokens themselves in another round-trip. This all is done by the adapter in browser-land. Originally it was intended to use this flow but using the **client-backend** for the second round-trip (code for tokens exchange), but I didn't figure out a simple way to do so with the official adapter.

In the meantime, `keycloak-dotnet-client` provides a way to get tokens from keycloak using a Client Credentials Flow, where a secret is used to get tokens on behalf of the user.

Thus, 2 authorization methods are provided in the app:
 - *User login*: authorization with Authorization Code Flow, performed by **client** with no **client-backend** influence
 - *Api login*: authorization with Client Credentials Flow, performed by **client-backend** when requested by the **client**

Unfortunately, both authorization mechanisms can't be available in parallel without exposing the secret to the **client** app (front-channel):
 - if the **client** is confidential, Keycloak expects a secret in the token endpoint, so the **client** can't authenticate the user after they typed their credentials
 - if the **client** is public, it can't use the client-credentials grant, so the **client-backend** can't call the token endpoint (at least with the default request done by AmbevTech.Keycloak.Client.Service.TokenManager) to authenticate

> See [Confidential and Public Applications](https://auth0.com/docs/get-started/applications/confidential-and-public-applications) for more info about public/confidential clients.

### Changing default flow

The default authorization method is *User login*. To use *Api login* instead, you'll need to login to Keycloak's admin console and edit the created client, enabling "Client authentication" and the "Service accounts roles" flow. The admin credentials and client id are laid out in the `.env` file.

Alternatively, you can kill the running Keycloak instance and set it up again with the variable `USE_API_AUTH=true`. You can also tweak any other Keycloak variable you want in the `.env` file to set it up with different sample data.

Kill and recreate Keycloak container with new data and to use *Api login*:
```shell
USE_API_AUTH=true ./reset-keycloak.sh
```

## Tokens

After successful authorization/authentication, the official adapter `keycloak-js` provides all tokens (Id Token, Access Token, Refresh Token), and our `keycloak-dotnet-client` provides the Access Token only. We only need the Access Token, which is in JWT format. Here's an excerpt of a (parsed) Access Token returned by Keycloak:

```json
{
  ...
  "realm_access": {
    "roles": [
      "default-roles-myrealm",
      "offline_access",
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

The `resource_access` entry denotes which roles the user have for each client/resource. Under resource `account`, we can see the user has 3 roles, which are set by default when we create a user. But there's also a `read_contacts` role under the `client_id_123` client/resource, which was introduced by us when we created the client role in Keycloak and mapped it to the created user.

When receiving a request with the access token, the **resource-server** validates the signature and a middleware (`AmbevTech.Keycloak.JWT.Entity.JwtKeycloakEvents`) parses and extracts from the token all the roles the user have for the client/resource the **resource-server** was configured with ("Keycloak:Resource"), and adds them as role claims in the [Identity Object](https://learn.microsoft.com/en-us/dotnet/api/system.security.claims.claimsprincipal.identity?view=net-6.0) of the context of the request.

With this, the user will be authorized to any resource endpoint that specifies a role which Keycloak says they have. In our case, the user will have the role `read_contacts` and so it will be possible to retrieve data from the /contacts endpoint (which has the `[Authorize(Roles = "read_contacts")]` attribute).

>See [Principal and Identity Objects](https://learn.microsoft.com/en-us/dotnet/standard/security/principal-and-identity-objects) for more details about Role-based authorization in .NET.

# Setup

# TODO explain the steps briefly and that password will be prompted

# Run

```shell
docker-compose up -d client
```

After a while a react app will load in your browser. Nothing will be working as Keycloak are still empty at this point. Execute the following script to fill Keycloak with sample data:

```shell
./keycloak-data-setup.sh
```

It will create a realm, a user, a client, a client role, and assign it to the user, so they'll have access to the protected endpoint in the resource-server. Check the `.env` file for credentials and other variables.

## Disclaimer

TODO explaing this is for learning purposes only and should be used with caution. Things were configured with loose security and in an inefficient manner.

It is advisable NOT to copy and start from this POC as baseline, but rather start from scratch and use each xxxxx one by one, making sure it is done properly.
