This repo is a Proof-of-Concept of authentication/authorization with Keycloak, using the [OIDC](https://openid.net/connect/) standard and internal keycloak projects.

# Requirements

- `docker-compose`: the components are glued together with it
- Access to [AMBEV-SA/Plataforma-comum](https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/) repos: some projects are cloned and referenced
- a unix shell: startup scripts are provided in `.sh` format

# Setup and run

First, create the *.env* file from the versioned template:
```shell
cp -n .env.development .env
```

You can open the [.env](.env) file in your editor to tweak some variables if you want.

Make all defined variables available to this and sub shells:
```shell
export $(grep -v '^#' .env | xargs)
```

Run the following [script](scripts/setup-and-run.sh) in the terminal:
```shell
./scripts/setup-and-run.sh
```

And wait. At some point you'll be prompted to type a password to clone repositories from [AMBEV-SA/Plataforma-comum](https://AMBEV-SA@dev.azure.com/AMBEV-SA/Plataforma-comum/). You can get one in any repository like [this one](https://dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-themes) by clicking *Clone* > *Generate Git Credentials* > Copy password.

After finishing the browser should open with a running application. If not, open manually http://localhost:8080.

## Tweaking

The client application can be tweaked on the fly by changing files in the [client/src/](client/src/) directory. This is possible due to the container been run with a volume mounted to that directory.

Keycloak's login theme can also be updated on the fly by changing files in [libs/keycloak-themes/theme/ambevtech-b2c/](libs/keycloak-themes/theme/ambevtech-b2c/). This is possible due to starting Keycloak in development mode. See *Starting Keycloak* section [here](https://www.keycloak.org/server/configuration) for more details.

Changes to the `resoure-server` or `client-backend` code need to be recompiled in a new image. You can do so by killing the respective container and running the respective build command present in the [build-images.sh](scripts/build-images.sh) script, and then starting the service again `docker-compose up -d <service>`. Alternatively, it is possible to kill the running service and debug it with your IDE. Don't forget to run in the correct port and with the needed environment variables set if you choose this route. Check out the [.env](.env) file for required variables and credentials.

The Keycloak stuff (User, Roles, Realm, etc) can be updated in the admin console. Check the [.env](.env) file for the Keycloak port and the admin credentials. It is also possible to update the environment variables and setup Keycloak again, see [Changing default flow](#changing-default-flow) section.

## Stopping

The standard `docker-compose` [commands](https://docs.docker.com/engine/reference/commandline/compose/#child-commands) apply.

To stop and remove a single service (check [docker-compose.yml](docker-compose.yml) for service names):
```shell
docker-compose rm -sf <service>
```

To stop and remove everything:
```shell
docker-compose down
```

# Components

We have a sample react app (**client**) that, with the help of a back-end* (**back-channel**), requests to keycloak (**authorization server**) to authenticate the user and get access to their roles, so it is possible to request protected resources (user contacts) to a **resource-server**.

These components are defined in a top-level docker-compose [file](docker-compose.yml):
 - **keycloak:** our Authorization Server
 - **resource-server**: a .NET web API with the protected resources
 - **client-backend**: a .NET web API acting as the client's back channel
 - **client**: a react app the user interacts with

\*See [Authorization Flow](#authorization-flow) section for updated details.

## Dependencies

The react app uses the [@react-keycloak/web](https://github.com/react-keycloak/react-keycloak/tree/master/packages/web) package to interact with Keycloak, which in turn uses the official [keycloak-js](https://www.keycloak.org/docs/latest/securing_apps/#_javascript_adapter) adapter under the hood. Requests to the **client-backend** and **resource-server** are made with the [axios](https://github.com/axios/axios) package.

The **client-backend** relies on [keycloak-dotnet-client](https://dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-dotnet-client) to make token requests to Keycloak.

The **resource-server** relies on the [keycloak-dotnet-jwt](https://dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-dotnet-jwt) to validate and parse tokens issued by Keycloak.

We also are using [keycloak-themes](https://dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-themes) to configure a custom theme for the login page in Keycloak.

## Authorization Flow

The *keycloak-js* adapter performs the Authorization Code Flow [by default](https://github.com/keycloak/keycloak-documentation/blob/main/securing_apps/topics/oidc/javascript-adapter.adoc#implicit-and-hybrid-flow), where the authorization endpoint returns an authorization code first, and then it is exchanged with the tokens themselves in another round-trip. This all is done by the adapter in browser-land. Originally it was intended to use this flow but using the **client-backend** for the second round-trip (code for tokens exchange), but I didn't figure out a simple way to do so with the official adapter.

In the meantime, [keycloak-dotnet-client](https://dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-dotnet-client) provides a way to get tokens from keycloak using a Client Credentials Flow, where a secret is used to get tokens on behalf of the user.

Thus, 2 authorization methods are provided in the app:
 - *User login*: authorization with Authorization Code Flow, performed by **client** with no **client-backend** influence
 - *Api login*: authorization with Client Credentials Flow, performed by **client-backend** when requested by the **client**

Unfortunately, both authorization mechanisms can't be available in parallel without exposing the secret to the **client** app (front-channel):
 - if the **client** is confidential, Keycloak expects a secret in the token endpoint, so the **client** can't authenticate the user after they typed their credentials
 - if the **client** is public, it can't use the client-credentials grant, so the **client-backend** can't call the token endpoint (at least with the default request done by AmbevTech.Keycloak.Client.Service.TokenManager) to authenticate

> See [Confidential and Public Applications](https://auth0.com/docs/get-started/applications/confidential-and-public-applications) for more info about public/confidential clients.

### Changing default flow

The default authorization method is *User login*. To use *Api login* instead, you'll need to login to Keycloak's admin console and edit the created client, enabling "Client authentication" and the "Service accounts roles" flow. You'll also need to assign the created role in the "Service accounts role" tab. The admin credentials and the client id and role are laid out in the [.env](.env) file.

Alternatively, you can kill the running Keycloak instance and set it up again with the variable `USE_API_AUTH=true`. You can also tweak any other Keycloak variable you want in the [.env](.env) file to set it up with different sample data (don't forget to export them after as done in [Setup and Run](#setup-and-run)).

Kill and recreate Keycloak container with new data and to use *Api login*:
```shell
export USE_API_AUTH=true; ./scripts/reset-keycloak.sh
```

## Tokens

After successful authorization/authentication, the official adapter *keycloak-js* provides all tokens (Id Token, Access Token, Refresh Token), and our [keycloak-dotnet-client](https://dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-dotnet-client) provides the Access Token only. We only need the Access Token, which is in JWT format. Here's an excerpt of a (parsed) Access Token returned by Keycloak:

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

When receiving a request with the access token, the **resource-server** validates the signature and a middleware ([AmbevTech.Keycloak.JWT.Entity.JwtKeycloakEvents](https://dev.azure.com/AMBEV-SA/Plataforma-comum/_git/keycloak-dotnet-jwt?path=/AmbevTech.Keycloak.JWT/Model/JwtKeycloakEvents.cs)) parses and extracts from the token all the roles the user have for the client/resource the **resource-server** was configured with ("Keycloak:Resource"), and adds them as role claims in the [Identity Object](https://learn.microsoft.com/en-us/dotnet/api/system.security.claims.claimsprincipal.identity?view=net-6.0) of the context of the request.

With this, the user will be authorized to any resource endpoint that specifies a role which Keycloak says they have. In our case, the user will have the role *read_contacts* and so it will be possible to retrieve data from the `/contacts` [endpoint](/home/marcel/repos/keycloak-poc/resource-server/Controllers/ResourcesController.cs) (which has the `[Authorize(Roles = "read_contacts")]` attribute).

>See [Principal and Identity Objects](https://learn.microsoft.com/en-us/dotnet/standard/security/principal-and-identity-objects) for more details about Role-based authorization in .NET.

# Other stuff worth mentioning

## Environment variables

Most commonly you'll be reading variables from the configuration files (e.g. *appsettings.json*, *config.json*). Here, for simplicity's sake, we're grouping and reading everything from a top level [.env](.env) file.

The exception is the client, in which we are still using a [config.json](client/src/config.json) file that should be kept in sync with [.env](.env). This is due to a [bug](https://github.com/facebook/create-react-app/issues/11773) in Creat React App that keep us from reading the environment.

## .NET APIs sharing hosts' *localhost*

As the *localhost* address is not the same in the host machine and within each container, we can run into problems using *localhost* URLs for service-to-service communication. One instance of this problem is the `resource-server` not being able to fetch authorization [metadata](http://localhost:8000/realms/myrealm/.well-known/openid-configuration) from Keycloak before starting to validate tokens.

We are circumventing this by making the *localhost* address point to the hosts' in the .NET APIs (note the `extra_hosts` entries in the `docker-compose` [file](docker-compose.yml)). This is hacky but the simplest considered alternative (see commit [57f75b253a](https://github.com/mabevtech/keycloak-poc/commit/57f75b253ac9bd5d802740ebc5ba256cdd76ae6a) for more details).

# Disclaimer

This repository was made for learning purposes, and its usage should be limited to that.

Things are configured with loose security and in an inefficient manner to make it practical to run and test out stuff. Environment variables are being leaked to every service, container images are bloated due to shared build context, Keycloak is configured to accept any origin in the endpoints, etc.

It is advisable **NOT** to start a project aimed for production with this POC as baseline, but rather to start from scratch and use this as a reference, replicating things only when applicable.
