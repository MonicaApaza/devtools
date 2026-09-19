# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"QuickDev" (package name `devtools_app`) — a Flutter app that stores keyboard shortcuts and CLI commands for developer tools (VS Code, Android Studio, IntelliJ, Git, Terminal, Browser, Flutter), organized by category, with favorites, usage counts, search, statistics and reports. Persistence is **remote**: the app is a GetX client for the .NET backend in `../backend` (`DevTools.Api`, backed by PostgreSQL) — there is no local database (no sqflite/Drift/Hive). Auth is JWT-based; only the session token is cached locally (via `get_storage`).

**All code, identifiers, and UI strings are in Spanish.** Keep new code consistent with this (e.g. `ModeloComando`, `ShortcutRepositorio`, screen/widget names like `ComandosScreen`, `ReportesScreen`).

## Commands

- Install dependencies: `flutter pub get`
- Run the app: `flutter run` (point at a specific backend with `--dart-define=API_BASE_URL=...`; see `lib/data/datasources/api_client.dart`)
- Static analysis / lint: `flutter analyze`
- Run all tests: `flutter test` (there is no `test/` directory yet — add one under `test/` following standard Flutter `flutter_test` conventions when writing tests)
- Run a single test file: `flutter test test/path_to_test.dart`
- Build release APK: `flutter build apk --release`
- Clean build artifacts: `flutter clean`

Lints come from `package:flutter_lints/flutter.yaml` (see `analysis_options.yaml`); no custom lint rules are configured.

## Architecture

Layers follow a Clean-Architecture-ish split: `lib/dominio` (contracts/entities) → `lib/data` (implementations talking to the API) → `lib/presentacion` + `lib/pantallas` (GetX controllers and screens).

### Data layer

- `lib/dominio/repositorios/*.dart` — abstract contracts (`ShortcutRepositorio`, `ComandoRepositorio`, `CategoriaRepositorio`, `AuthRepositorio`). No `existeTitulo`-style client-side pre-checks: the backend rejects duplicates with 409 (see `ApiConflictException`), the client just surfaces that.
- `lib/data/repositorios/*_repositorio_impl.dart` — implementations of the above, each backed by `ApiClient` (never talk to `http` directly from a screen or controller).
- `lib/data/datasources/api_client.dart` — thin `http` wrapper: resolves the base URL (`API_BASE_URL` dart-define, else `10.0.2.2:5262` on Android emulator / `localhost:5262` elsewhere), attaches the JWT bearer token, and maps HTTP failures to typed exceptions (`ApiUnauthorizedException`, `ApiNotFoundException`, `ApiConflictException`, ...).
- `lib/data/datasources/auth_local_datasource.dart` — the *only* local persistence in the app: caches the JWT session (`userId`/`usuario`/`token`/`expiresAt`) as one `get_storage` entry, so login survives app restarts.
- `lib/data/modelos/` — `ModeloShortcut`/`ModeloComando` with `toApiBody()`/`fromApi()` for (de)serializing against the backend's JSON shape (fields prefixed by entity, e.g. `tituloShortcut`, `creadoEnComando`, `usosComando`).
- `lib/data/datos_estaticos/categorias.dart` — just the `Categoria` model and the fixed, client-side catalog of selectable icons (`iconosCategoria`, keyed by string so Flutter's icon tree-shaker keeps working in release builds). Actual category *data* (names, which icon each one uses) comes from the backend via `CategoriaRepositorio` — see `lib/datos/categorias_controlador.dart`.

### State management (GetX)

The app uses `package:get` throughout — no `Provider`/`Bloc`/`ChangeNotifier`-as-state-management (the one exception is `ThemeController`, see below).

- **App-wide singletons**, registered once with `Get.put(..., permanent: true)` in `main()`: `AuthController` (session, login/logout), `CategoriasController` (in-memory cache of shortcut/command categories, reloads on login/logout via `ever(AuthController.instance.sesion, ...)`), `BusquedaController` (search text shared across Inicio/Shortcuts/Comandos tabs).
- **Screen-scoped controllers**, `Get.put()` in `initState()` and `Get.delete<T>()` in `dispose()`: `EstadisticasController`, `ReportesController`, and the per-tab controllers under `lib/presentacion/controladores/`. When a screen needs to react to category changes it listens with `ever(CategoriasController.instance.version, ...)` rather than depending on `CategoriasController` being a screen-scoped controller itself.
- `main()` awaits `AuthController.cargarSesionInicial()` **before** `runApp()` (not left to `onInit()`, which isn't awaited) so the app can pick the initial route (`/` vs `/login`) based on a valid saved JWT — mirroring the web app's guard.

### Theming

- `lib/theme/theme_controller.dart` — the one place still using the older private-constructor + static `instance` + `ChangeNotifier` singleton pattern (predates the GetX migration). Builds Material 3 `ThemeData` from a single seed color (`colorSemilla`) via `ColorScheme.fromSeed`, for both light and dark. `MainApp` (in `main.dart`) rebuilds via `AnimatedBuilder(animation: ThemeController.instance, ...)`. Prefer deriving new visual styles from `Theme.of(context).colorScheme` rather than hardcoding colors, to keep light/dark parity.

### Navigation

Two tiers:
- `lib/pantallas/root_shell.dart` (`RootShell`) is the initial route (`AppRutas.inicio`) and the primary shell: an `IndexedStack` of the four main tabs (Inicio/Shortcuts/Comandos/Más) with a notched `BottomAppBar` + centered `FloatingActionButton`, plus an `AppDrawer`. It holds per-tab UI state (grid vs. list toggles) and uses `GlobalKey`s into the tab screens' `State` (`HomeScreenState`, `ShortcutsScreenState`, `ComandosScreenState`) so the shared FAB can call into whichever tab is active (e.g. `mostrarFormularioNuevo()`).
- Everything else (`Login`, `Registro`, `Ajustes`, `Estadísticas`, `Reportes`, `Categorías`) is a named `GetPage` route — see `lib/rutas/app_rutas.dart` (route name constants) and `lib/rutas/app_paginas.dart` (the `GetPage` table passed to `GetMaterialApp.getPages`). `MasScreen` and `AppDrawer` both link to these via `Navigator.pushNamed`.
- When adding a new secondary screen reachable from "Más" or the drawer, follow the `Estadísticas`/`Reportes` pattern: add a route constant, a `GetPage` entry, and a `ListTile` in both `mas_screen.dart` and `app_drawer.dart`.

### Screens and reports

- Each main entity screen (`ShortcutsScreen`, `ComandosScreen`) supports list/grid view (controlled by the parent `RootShell`), search, and category filtering, and exposes a public `mostrarFormularioNuevo()` (and similarly named edit entry points) on its `State` class for `RootShell`'s FAB to call.
- `lib/widgets/shortcut_form_sheet.dart` / `comando_form_sheet.dart` are bottom-sheet forms for create/edit, shown via `showModalBottomSheet`, validated server-side (409 on conflict) rather than pre-checked client-side.
- `lib/pantallas/estadisticas_screen.dart` (totals, favorites, per-category breakdown via `BarraEstadistica`) and `lib/pantallas/reportes_screen.dart` (top-5 most-used commands, recently-added shortcuts/commands, favorites list) both load their own snapshot of shortcuts/commands through their screen-scoped controller rather than sharing one with the tab screens — reload with pull-to-refresh (`RefreshIndicator`) or by reacting to `CategoriasController.instance.version`.

## Platform targets

The project scaffolding includes Android, iOS, macOS, Linux, Windows, and web (`flutter create` defaults), but active development has focused on mobile (Android/iOS) layouts. Check screen layouts in `lib/pantallas/` for fixed mobile assumptions before assuming desktop/web layouts work well.
