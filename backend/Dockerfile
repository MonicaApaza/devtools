FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY DevTools.Api/DevTools.Api.csproj DevTools.Api/
COPY DevTools.Application/DevTools.Application.csproj DevTools.Application/
COPY DevTools.Domain/DevTools.Domain.csproj DevTools.Domain/
COPY DevTools.Infrastructure/DevTools.Infrastructure.csproj DevTools.Infrastructure/
RUN dotnet restore DevTools.Api/DevTools.Api.csproj

COPY . .
RUN dotnet publish DevTools.Api/DevTools.Api.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "DevTools.Api.dll"]
