#!/bin/bash

# Following https://www.keycloak.org/getting-started/getting-started-docker#_login_to_the_admin_console
# what we need:
# (0) Set admin credentials (this is done before running the keycloak container)
# (1) Create a new realm
# (2) Create a new user in the new realm
# (3) Register a client in the new realm
# We'll also update the login theme of the new realm to ours

# Load variables from env file
export $(xargs <.env)

# curl calls adapted from https://stackoverflow.com/a/54110718
# there's no /auth in keycloak URLs anymore

echo ""
echo "## Getting access token for the admin user"
echo ""
TOKEN=$(
    curl http://localhost:$KEYCLOAK_PORT/realms/master/protocol/openid-connect/token \
         -d "username=${KEYCLOAK_ADMIN}&password=${KEYCLOAK_ADMIN_PASSWORD}&grant_type=password&client_id=admin-cli" |
         # striping the token value from the returned json
         sed 's/{"access_token":"//g' |
         sed 's/".*//g'
     )

echo ""
echo "## Token:"
echo ""
echo $TOKEN

# (1) Create a new realm

echo ""
echo "## Creating realm " $KEYCLOAK_REALM_NAME
echo ""
curl http://localhost:$KEYCLOAK_PORT/admin/realms \
     -H "Content-Type: application/json" \
     -H "Authorization: bearer $TOKEN" \
     -d '{"realm":"'"$KEYCLOAK_REALM_NAME"'","enabled":"true"}'

# (2) Create a new user in the new realm

echo ""
echo "## Creating user" $KEYCLOAK_USER_UNAME "in" $KEYCLOAK_REALM_NAME
echo ""
curl http://localhost:$KEYCLOAK_PORT/admin/realms/$KEYCLOAK_REALM_NAME/users \
     -H "Content-Type: application/json" \
     -H "Authorization: bearer ${TOKEN}" \
     -d '{
           "username": "'"$KEYCLOAK_USER_UNAME"'",
           "email":    "'"$KEYCLOAK_USER_EMAIL"'",
           "enabled":  true
         }'

# (3) Register a client in the new realm

echo ""
echo "## Registering client" $CLIENT_ID "in" $KEYCLOAK_REALM_NAME
echo ""

# Client set as confidential so it can request tokens by itself
# using a secret (client credentials grant).
IS_PUBLIC_CLIENT=false
curl http://localhost:$KEYCLOAK_PORT/admin/realms/$KEYCLOAK_REALM_NAME/clients \
     -H "Content-Type: application/json" \
     -H "Authorization: bearer ${TOKEN}" \
     -d '{
           "protocol":      "openid-connect",
           "clientId":      "'"$CLIENT_ID"'",
           "secret":        "'"$CLIENT_SECRET"'",
           "publicClient":  "'"$IS_PUBLIC_CLIENT"'",
           "authorizationServicesEnabled": false,
           "serviceAccountsEnabled":       true,
           "implicitFlowEnabled":          true,
           "directAccessGrantsEnabled":    true,
           "standardFlowEnabled":          true,
           "frontchannelLogout":           true,
           "alwaysDisplayInConsole":       false,
           "attributes": {
             "oauth2.device.authorization.grant.enabled": false,
             "oidc.ciba.grant.enabled":                   false
           },
           "webOrigins": ["*"],
           "redirectUris": ["*"]
         }'

# Update theme of the new realm

THEME=$(ls libs/keycloak-themes/theme | head -1)
echo ""
echo "## Setting theme" $THEME "in" $KEYCLOAK_REALM_NAME "login page"
echo ""
curl http://localhost:$KEYCLOAK_PORT/admin/realms/$KEYCLOAK_REALM_NAME \
     -X 'PUT' \
     -H "Content-Type: application/json" \
     -H "Authorization: bearer $TOKEN" \
     -d '{"realm":"'"$KEYCLOAK_REALM_NAME"'","loginTheme":"'"$THEME"'"}'
