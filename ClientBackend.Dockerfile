# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env
WORKDIR /app

# Copy main and referenced csproj files and restore as distinct layers
COPY ./client-backend/*.csproj .
COPY ./libs/keycloak-dotnet-client/AmbevTech.Keycloak.Client/*.csproj \
    ../libs/keycloak-dotnet-client/AmbevTech.Keycloak.Client/
RUN dotnet restore

# Copy everything else and build
WORKDIR /libs/keycloak-dotnet-client
COPY ./libs/keycloak-dotnet-client/ .
RUN dotnet build -c Release -o out ./AmbevTech.Keycloak.Client/AmbevTech.Keycloak.Client.csproj

WORKDIR /app
COPY ./client-backend/ .
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "ClientApi.dll"]

EXPOSE 80
