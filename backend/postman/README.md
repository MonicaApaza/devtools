# DevTools API — Postman

Colección para probar manualmente la API de DevTools (`backend/DevTools.Api`).

## Importar en Postman

1. Abre Postman → **Import** → arrastra los dos archivos:
   - `DevTools.postman_collection.json`
   - `DevTools.postman_environment.json`
2. Selecciona el environment **"DevTools Local"** (arriba a la derecha).
3. Levanta la base de datos y el backend:
   ```bash
   docker compose up -d
   cd backend/DevTools.Api
   dotnet run
   ```
   La API queda en `http://localhost:5262` (variable `baseUrl` = `http://localhost:5262/api`).
4. Ejecuta **Auth → Login** con el usuario semilla (`monica` / `monica123`, creado automáticamente por el `DbSeeder` al iniciar). El token JWT se guarda solo en la variable `token`.
5. Todas las demás requests ya usan `Bearer {{token}}` (heredado a nivel de colección) — no hace falta copiar el token a mano.
6. Ejecuta **Categories → Create Category** para crear una categoría de prueba; su `id` se guarda en `categoryId` y se reutiliza automáticamente en los requests de Shortcuts/Commands.

## Sobre las variables (Environment vs. Collection)

El **Environment** ("DevTools Local") solo define `baseUrl`. El **token JWT** y los ids (`userId`, `categoryId`, `shortcutId`, `commandId`) viven como **Collection Variables**, porque los scripts de test los escriben con `pm.collectionVariables.set(...)`.

⚠️ No declares esas mismas variables en el Environment: si una variable existe en ambos scopes, Postman resuelve `{{variable}}` usando el Environment primero (mayor prioridad que Collection) — si ahí está vacía, `{{token}}` se resuelve vacío aunque la Collection tenga el valor real, y todas las requests autenticadas fallarán con 401.

## Base URL

```
http://localhost:5262/api
```

Todas las rutas están bajo `/api`. Todas excepto `Auth` requieren el header `Authorization: Bearer <token>`.

## Endpoints disponibles

### Auth (`/api/auth`) — sin autenticación

| Método | Ruta | Body | Respuesta |
|---|---|---|---|
| POST | `/auth/register` | `{ username, password }` | 201 `{ userId, username, token, expiresAt }` / 409 si el usuario ya existe |
| POST | `/auth/login` | `{ username, password }` | 200 `{ userId, username, token, expiresAt }` / 401 si las credenciales son inválidas |

- `username`: 3–50 caracteres. `password`: 6–100 caracteres (solo en registro; login no valida longitud, solo credenciales).
- Usuario semilla ya creado: **`monica` / `monica123`**.

### Categories (`/api/categories`) — requiere token

| Método | Ruta | Body | Respuesta |
|---|---|---|---|
| GET | `/categories?type=Shortcut\|Command\|Both` | — | 200 `CategoryDto[]` (incluye tipo pedido + `Both`) |
| POST | `/categories` | `{ name, icon, type? }` | 201 `CategoryDto` / 409 si ya existe `(nombre, tipo)` para el usuario |
| PUT | `/categories/{id}` | `{ name, icon, type? }` | 200 `CategoryDto` / 404 si no existe |
| DELETE | `/categories/{id}` | — | 204 / 409 `{ message, shortcutCount, commandCount }` si está en uso |

`CategoryDto`: `{ id, name, icon, type, createdAt }`. `type` es opcional en el body (por defecto `Both`).

### Shortcuts (`/api/shortcuts`) — requiere token

| Método | Ruta | Body | Respuesta |
|---|---|---|---|
| GET | `/shortcuts` | — | 200 `ShortcutDto[]` |
| POST | `/shortcuts` | `{ title, keys, description?, categoryId, tags? }` | 201 `ShortcutDto` |
| PUT | `/shortcuts/{id}` | `{ title, keys, description?, categoryId, tags? }` | 200 `ShortcutDto` |
| PATCH | `/shortcuts/{id}/favorite` | `{ isFavorite }` | 200 `ShortcutDto` |
| DELETE | `/shortcuts/{id}` | — | 204 |

`ShortcutDto`: `{ id, title, keys, description, categoryId, tags[], isFavorite, createdAt }`. `categoryId` debe pertenecer a una categoría propia de tipo `Shortcut` o `Both` (si no, 404).

### Commands (`/api/commands`) — requiere token

| Método | Ruta | Body | Respuesta |
|---|---|---|---|
| GET | `/commands` | — | 200 `CommandDto[]` |
| POST | `/commands` | `{ title, commandText, description?, categoryId, tags? }` | 201 `CommandDto` |
| PUT | `/commands/{id}` | `{ title, commandText, description?, categoryId, tags? }` | 200 `CommandDto` |
| PATCH | `/commands/{id}/favorite` | `{ isFavorite }` | 200 `CommandDto` |
| POST | `/commands/{id}/use` | — | 200 `{ id, usageCount }` (incrementa el contador) |
| DELETE | `/commands/{id}` | — | 204 |

`CommandDto`: `{ id, title, commandText, description, categoryId, tags[], isFavorite, usageCount, createdAt }`. `categoryId` debe pertenecer a una categoría propia de tipo `Command` o `Both` (si no, 404).

## Errores comunes

Todos los errores de dominio se devuelven como JSON con `status`/`title`/`detail` (formato `ProblemDetails`), excepto el 409 de categoría en uso que además incluye los conteos:

| Código | Cuándo |
|---|---|
| 400 | Validación fallida (campos requeridos/longitud) |
| 401 | Token ausente/inválido, o credenciales de login incorrectas |
| 404 | Categoría/Shortcut/Comando no encontrado o no pertenece al usuario |
| 409 | Usuario/categoría duplicados, o categoría con shortcuts/comandos asociados al borrarla |
| 500 | Error no controlado |
