#!/bin/sh

# Following https://www.keycloak.org/getting-started/getting-started-docker#_login_to_the_admin_console
# we need to  create a realm (1), create a user (2), and register a client (3).
# We'll do that and some extra stuff to make a working workflow:
#
# (0) Set admin credentials (this is done before running the keycloak container)
# (1) Create a new realm
#     (1.1) Update the theme of the new realm
#     (1.2) Update the Content Security Policy of the new realm
# (2) Create a new user in the new realm
#     (2.1) Set a password for the new user
# (3) Register a client in the new realm
#     (3.1) Create client role
#     (3.2) Assign created role to user*
#
# * Note that if using API login (client-credentials grant),
#   we ignore the created user and assign the role to the
#   default service-accounts user of the client.

# curl calls adapted from https://stackoverflow.com/a/54110718
# there's no /auth in keycloak URLs anymore

# Make sure we are in project root
cd $(dirname $0)/..

# Suppress progress meter by default in curl calls
alias curl="curl --no-progress-meter"

echo ""
echo "Getting access token for the admin user"
TOKEN=$(
    curl http://localhost:$KEYCLOAK_PORT/realms/master/protocol/openid-connect/token \
         -d "username=${KEYCLOAK_ADMIN}&password=${KEYCLOAK_ADMIN_PASSWORD}&grant_type=password&client_id=admin-cli" |
         # striping the token value from the returned json
         sed 's/{"access_token":"//g' |
         sed 's/".*//g'
     )

echo ""
echo "Token:"
echo $TOKEN

# (1) Create a new realm

echo ""
echo "Creating realm" $KEYCLOAK_REALM_NAME
curl http://localhost:$KEYCLOAK_PORT/admin/realms \
     -H "Content-Type: application/json" \
     -H "Authorization: bearer $TOKEN" \
     -d '{"realm":"'"$KEYCLOAK_REALM_NAME"'","enabled":"true"}'

# (1.1) Update theme of the new realm

THEME=$(ls libs/keycloak-themes/theme | head -1)
echo ""
echo "Setting theme" $THEME "in" $KEYCLOAK_REALM_NAME "login page"
curl http://localhost:$KEYCLOAK_PORT/admin/realms/$KEYCLOAK_REALM_NAME \
     -X 'PUT' \
     -H "Content-Type: application/json" \
     -H "Authorization: bearer $TOKEN" \
     -d '{"realm":"'"$KEYCLOAK_REALM_NAME"'","loginTheme":"'"$THEME"'"}'

# (1.2) Update Content Security Policy of the new realm

echo ""
echo "Updating contentSecurityPolicy of" $KEYCLOAK_REALM_NAME
curl http://localhost:$KEYCLOAK_PORT/admin/realms/$KEYCLOAK_REALM_NAME \
     -X 'PUT' \
     -H "Content-Type: application/json" \
     -H "Authorization: bearer $TOKEN" \
     -d '{
           "realm": "'"$KEYCLOAK_REALM_NAME"'",
           "browserSecurityHeaders": {
             "contentSecurityPolicy": "frame-src '"'self'"'; frame-ancestors '"'self'"' localhost:*; object-src '"'none'"';"
           }
         }'

# (2) Create a new user in the new realm

echo ""
echo "Creating user" $KEYCLOAK_USER_UNAME "in" $KEYCLOAK_REALM_NAME
curl http://localhost:$KEYCLOAK_PORT/admin/realms/$KEYCLOAK_REALM_NAME/users \
     -H "Content-Type: application/json" \
     -H "Authorization: bearer ${TOKEN}" \
     -d '{
           "username": "'"$KEYCLOAK_USER_UNAME"'",
           "email":    "'"$KEYCLOAK_USER_EMAIL"'",
           "enabled":  true
         }'

# (2.1) Set a password for the new user

echo ""
echo "Setting password" $KEYCLOAK_USER_PWD "for user" $KEYCLOAK_USER_UNAME
# Get the id of the created user (it's the only one in the realm)
USER_GUID=$(
    curl http://localhost:$KEYCLOAK_PORT/admin/realms/$KEYCLOAK_REALM_NAME/users \
         -H "Authorization: bearer ${TOKEN}" |
        # striping the id value from the returned json
        sed 's/\[{"id":"//g' |
        sed 's/".*//g'
     )

# Update its password
curl http://localhost:$KEYCLOAK_PORT/admin/realms/$KEYCLOAK_REALM_NAME/users/$USER_GUID/reset-password \
     -X 'PUT' \
     -H "Content-Type: application/json" \
     -H "Authorization: bearer ${TOKEN}" \
     -d '{"temporary":false,"type":"password","value":"'"$KEYCLOAK_USER_PWD"'"}'

# (3) Register a client in the new realm

echo ""
echo "Registering client" $CLIENT_ID "in" $KEYCLOAK_REALM_NAME

# If true, it means the client has a secure back-channel to store secrets.
# The "serviceAccountsEnabled" option can be set to true then, which
# enables the client to request the tokens directly (using the Client credentials grant).
# If false, client is set as public, which means it can't store a secret safely,
# so it can't use it to request tokens directly with no user interaction,
# but it can perform the Implicit Flow (and Authorization Code Flow) just fine.
# See Flow section in README for more details.
IS_CONFIDENTIAL_CLIENT=${USE_API_AUTH}

# "IS_PUBLIC_CLIENT = !IS_CONFIDENTIAL_CLIENT"
${IS_CONFIDENTIAL_CLIENT} == true && IS_PUBLIC_CLIENT=false || IS_PUBLIC_CLIENT=true

curl http://localhost:$KEYCLOAK_PORT/admin/realms/$KEYCLOAK_REALM_NAME/clients \
     -H "Content-Type: application/json" \
     -H "Authorization: bearer ${TOKEN}" \
     -d '{
           "protocol":      "openid-connect",
           "clientId":      "'"$CLIENT_ID"'",
           "secret":        "'"$CLIENT_SECRET"'",
           "publicClient":  "'"$IS_PUBLIC_CLIENT"'",
           "serviceAccountsEnabled":       "'"$IS_CONFIDENTIAL_CLIENT"'",
           "authorizationServicesEnabled": false,
           "implicitFlowEnabled":          true,
           "directAccessGrantsEnabled":    true,
           "standardFlowEnabled":          true,
           "frontchannelLogout":           true,
           "alwaysDisplayInConsole":       false,
           "attributes": {
             "oauth2.device.authorization.grant.enabled": false,
             "oidc.ciba.grant.enabled":                   false,
             "post.logout.redirect.uris":                 "*"
           },
           "webOrigins": ["*"],
           "redirectUris": ["*"]
         }'

# (3.1) Create client role

# Get the (internal) id of the created client
CLIENT_GUID=$(
    curl http://localhost:$KEYCLOAK_PORT/admin/realms/$KEYCLOAK_REALM_NAME/clients \
         -H "Authorization: bearer ${TOKEN}" |
         grep -oP '"id":"[^"]+","clientId":"'"$CLIENT_ID"'"' |
         sed 's/"id":"//g' |
         sed 's/".*//g'
       )

# Create the role for the client
curl http://localhost:$KEYCLOAK_PORT/admin/realms/$KEYCLOAK_REALM_NAME/clients/$CLIENT_GUID/roles \
     -H "Content-Type: application/json" \
     -H "Authorization: bearer $TOKEN" \
     -d '{"name":"'"$CLIENT_ROLE"'"}'

# (3.2) Assign created role to user

# Get the id of the created role (it's the only one for the client)
ROLE_GUID=$(
    curl http://localhost:$KEYCLOAK_PORT/admin/realms/$KEYCLOAK_REALM_NAME/clients/$CLIENT_GUID/roles \
         -H "Authorization: bearer ${TOKEN}" |
        # striping the id value from the returned json
        sed 's/\[{"id":"//g' |
        sed 's/".*//g'
       )

# If using API authorization, fetch the id of, and use the default service-account user
${USE_API_AUTH} == true && \
    USER_GUID=$(
        curl http://localhost:$KEYCLOAK_PORT/admin/realms/$KEYCLOAK_REALM_NAME/clients/$CLIENT_GUID/service-account-user \
             -H "Authorization: bearer ${TOKEN}" |
            # striping the id value from the returned json
            sed 's/{"id":"//g' |
            sed 's/".*//g'
           )

# Create a role mapping for the client role and user
curl http://localhost:$KEYCLOAK_PORT/admin/realms/$KEYCLOAK_REALM_NAME/users/$USER_GUID/role-mappings/clients/$CLIENT_GUID \
     -H "Content-Type: application/json" \
     -H "Authorization: bearer $TOKEN" \
     -d '[{
            "containerId": "'"$CLIENT_GUID"'",
            "clientRole": true,
            "composite": false,
            "name": "'"$CLIENT_ROLE"'",
            "id": "'"$ROLE_GUID"'"
         }]'
