# DevTools (QuickDev)

Gestor de shortcuts de teclado y comandos de CLI por usuario, organizados por categoría. Este repo contiene **dos implementaciones de la misma app**, como ejercicio de aprendizaje sobre dos stacks distintos:

```
devtools/
  mobile/    App original en Flutter + SQLite (offline, un solo dispositivo)
  web/       Frontend Angular
  backend/   API ASP.NET Core + PostgreSQL (usada por web/)
```

Esta guía cubre el flujo `web/` + `backend/`. Para `mobile/`, ver [mobile/README.md](mobile/README.md) si existe, o simplemente `flutter run` dentro de esa carpeta.

## Arquitectura

- **Backend**: ASP.NET Core Web API (.NET 10) con Clean Architecture (`Domain` → `Application` → `Infrastructure` → `Api`), Entity Framework Core + PostgreSQL, autenticación JWT (BCrypt + tokens de 7 días).
- **Frontend**: Angular (standalone, signals, Signal Forms, Tailwind CSS + Angular Material), consumiendo la API vía `HttpClient` con interceptores de auth.
- **Base de datos**: PostgreSQL 16 vía Docker Compose.

## Requisitos previos

| Herramienta | Versión usada en este proyecto |
|---|---|
| Docker + Docker Compose | cualquiera reciente |
| .NET SDK | 10.0.203 (`dotnet --version`) |
| Node.js | 24.x |
| npm | 11.x |

No hace falta instalar Angular CLI globalmente ni PostgreSQL en el sistema — `npx`/`npm` y Docker se encargan de todo.

## Puesta en marcha (happy path)

### 1. Levantar PostgreSQL

Desde la raíz del repo:

```bash
docker compose up -d
```

Esto crea el contenedor `devtools_postgres` (Postgres 16) con la base `devtools` / usuario `devtools` / password `devtools`, persistida en un volumen Docker (`devtools_postgres_data`) que sobrevive a reinicios.

### 2. Levantar el backend

```bash
cd backend/DevTools.Api
dotnet run
```

Al arrancar, `Program.cs` **aplica las migraciones pendientes automáticamente** (`db.Database.Migrate()`) y **siembra datos demo** si la base está vacía (`DbSeeder`, guardado tras el primer `AnyAsync()` — no vuelve a sembrar en arranques posteriores). No es necesario correr `dotnet ef database update` a mano.

La API queda en `http://localhost:5262` (perfil `http` de `launchSettings.json`). En modo Development, la documentación interactiva (Scalar, reemplazo moderno de Swagger UI) está en:

```
http://localhost:5262/scalar/v1
```

**Usuario demo sembrado automáticamente:** `monica` / `monica123`.

> Si ya tenías una base de datos de una sesión anterior con otros datos (o cambiaste la contraseña de `monica` manualmente), el seed no se vuelve a ejecutar — solo corre la primera vez que la tabla `users` está vacía.

### 3. Levantar el frontend

En otra terminal:

```bash
cd web
npm install
npm start
```

Esto corre `ng serve`, disponible en `http://localhost:4200`. El frontend apunta a `http://localhost:5262/api` (ver `web/src/app/core/config/api-config.ts`); el backend permite CORS desde `http://localhost:4200`.

### 4. Probar la app

Abre `http://localhost:4200`, inicia sesión con `monica` / `monica123` (o regístrate con un usuario nuevo), y prueba las secciones: Inicio, Shortcuts, Comandos, Categorías, Estadísticas, Ajustes (incluye el toggle de tema oscuro).

## Probar la API directamente (sin el frontend)

Hay una colección de Postman lista en [`backend/postman/`](backend/postman/):

- `DevTools.postman_collection.json`
- `DevTools.postman_environment.json`
- `postman/README.md` — referencia completa de los 15 endpoints, con `Login` guardando el token JWT automáticamente para encadenar el resto de requests.

También puedes usar la UI de Scalar (`/scalar/v1`) para explorar y probar cada endpoint desde el navegador.

## Verificar que los datos persisten en Postgres

```bash
docker exec -it devtools_postgres psql -U devtools -d devtools -c "\dt"
docker exec -it devtools_postgres psql -U devtools -d devtools -c \
  "SELECT username FROM users; SELECT name, type FROM categories; SELECT title FROM shortcuts; SELECT title, usage_count FROM commands;"
```

Los datos sobreviven a `docker compose down` (sin `-v`) y a reinicios del backend, ya que viven en el volumen `devtools_postgres_data`.

## Verificación responsive (móvil)

El layout (`shell`) usa Angular CDK `BreakpointObserver` para colapsar el menú lateral en anchos de pantalla angostos (`mode="over"`): el hamburger button abre el drawer como overlay, y este se cierra solo al navegar a una sección. Puedes probarlo achicando la ventana del navegador o con las herramientas de emulación de dispositivo.

## Comandos útiles

```bash
# Backend
cd backend/DevTools.Api
dotnet run                       # levanta la API (migra + siembra automáticamente)
dotnet ef migrations add <Name> --project ../DevTools.Infrastructure --startup-project .
dotnet ef database update --project ../DevTools.Infrastructure --startup-project .

# Frontend
cd web
npm start                        # ng serve (http://localhost:4200)
npm run build                    # build de producción
npm test                         # tests unitarios (Vitest)

# Base de datos
docker compose up -d             # levantar Postgres
docker compose down              # detener (mantiene el volumen/datos)
docker compose down -v           # detener y borrar todos los datos
```

## Detener todo

```bash
# Ctrl+C en las terminales de `dotnet run` y `npm start`
docker compose down
```
