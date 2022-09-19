# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env
WORKDIR /app

# Copy main and referenced csproj files and restore as distinct layers
COPY ./resource-server/*.csproj .
COPY ./libs/keycloak-dotnet-jwt/AmbevTech.Keycloak.JWT/*.csproj \
    ../libs/keycloak-dotnet-jwt/AmbevTech.Keycloak.JWT/
RUN dotnet restore

# Copy everything else and build
WORKDIR /libs/keycloak-dotnet-jwt
COPY ./libs/keycloak-dotnet-jwt/ .
RUN dotnet build -c Release -o out ./AmbevTech.Keycloak.JWT/AmbevTech.Keycloak.JWT.csproj

WORKDIR /app
COPY ./resource-server/ .
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "ResourceServer.dll"]

EXPOSE 80
