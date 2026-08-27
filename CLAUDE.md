# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"QuickDev" (package name `devtools_app`) — a Flutter app that stores keyboard shortcuts and CLI commands for developer tools (VS Code, Android Studio, IntelliJ, Git, Terminal, Browser, Flutter), organized by category, with favorites and search. Local persistence only, via SQLite.

**All code, identifiers, and UI strings are in Spanish.** Keep new code consistent with this (e.g. `ModeloComando`, `insertarShortcut`, screen/widget names like `ComandosScreen`, `FormularioNuevo`).

## Commands

- Install dependencies: `flutter pub get`
- Run the app: `flutter run`
- Static analysis / lint: `flutter analyze`
- Run all tests: `flutter test` (there is no `test/` directory yet — add one under `test/` following standard Flutter `flutter_test` conventions when writing tests)
- Run a single test file: `flutter test test/path_to_test.dart`
- Build release APK: `flutter build apk --release`
- Clean build artifacts: `flutter clean`

Lints come from `package:flutter_lints/flutter.yaml` (see `analysis_options.yaml`); no custom lint rules are configured.

## Architecture

### Data layer

- `lib/helpers/db_helper.dart` — `DatabaseHelper` is a singleton wrapping `sqflite`. It owns the single `Database` instance (`quickdev.db`), creates the `shortcut` and `comando` tables on first run, and seeds demo data via `_sembrarDatos`. All persistence (CRUD for shortcuts and commands, plus `existeTitulo*` uniqueness checks) goes through this class — there is no repository/DAO split per entity.
- `lib/modelos/` — plain model classes (`ModeloShortcut`, `ModeloComando`) with `toMap()`/`fromMap()` for SQLite (de)serialization. Fields are prefixed by entity (e.g. `tituloShortcut`, `tituloComando`) to match the DB column names directly — there is no separate mapping layer.
- `lib/datos/categorias.dart` — static category definitions (id, display name, icon) for shortcuts and commands, plus `buscarCategoriaShortcut`/`buscarCategoriaComando` lookup helpers. Add new categories here, not inline in screens.
- `lib/datos/cambios_datos.dart` — `CambiosDatos` is a `ChangeNotifier` singleton used purely as a cross-screen event bus: any screen that mutates shortcuts/comandos calls `.avisar()`, and `HomeScreen` (and others) listen to refresh derived data (e.g. stats) without the screens knowing about each other directly.

### App-wide singletons (ChangeNotifier pattern)

Both `ThemeController` (`lib/theme/theme_controller.dart`) and `CambiosDatos` follow the same pattern: private constructor + static `instance`, extends `ChangeNotifier`, and widgets rebuild via `AnimatedBuilder` (see `MainApp` in `lib/main.dart`) or `listenable`/manual `addListener`. When adding new global, cross-screen state, follow this same singleton-ChangeNotifier shape rather than introducing a new state management dependency.

### Navigation / shell

- `lib/main.dart` defines named routes (`/`, `/ajustes`, `/estadisticas`) but the primary navigation is tab-based, not route-based.
- `lib/pantallas/root_shell.dart` (`RootShell`) is the real app shell: an `IndexedStack` of the four main tabs (Inicio/Home, Shortcuts, Comandos, Más) with a notched `BottomAppBar` + centered `FloatingActionButton`, plus an `AppDrawer`. It holds per-tab UI state (e.g. grid vs. list view toggles) and uses `GlobalKey`s into the tab screens' `State` (`HomeScreenState`, `ShortcutsScreenState`, `ComandosScreenState`) so the shared FAB can call into whichever tab is active (e.g. `mostrarFormularioNuevo()`). When adding a new tab-level action triggered from the shell (FAB, app bar action), wire it the same way: expose a public method on the screen's `State` and call it via its `GlobalKey` from `RootShell`.
- `lib/pantallas/ajustes_screen.dart` and `estadisticas_screen.dart` are reached via named routes instead, since they're not part of the bottom-tab set.

### Screens and forms

- Each main entity screen (`ShortcutsScreen`, `ComandosScreen`) supports list/grid view (controlled by the parent `RootShell`), search, and category filtering, and exposes a public `mostrarFormularioNuevo()` (and similarly named edit entry points) on its `State` class for `RootShell`'s FAB to call.
- `lib/widgets/shortcut_form_sheet.dart` / `comando_form_sheet.dart` are bottom-sheet forms for create/edit, shown via `showModalBottomSheet`. They validate against `existeTitulo*` in `DatabaseHelper` and call `CambiosDatos.instance.avisar()` after a successful mutation.

### Theming

- `lib/theme/theme_controller.dart` builds Material 3 `ThemeData` from a single seed color (`colorSemilla`) via `ColorScheme.fromSeed`, for both light and dark. Prefer deriving new visual styles from the existing `ColorScheme` (e.g. `Theme.of(context).colorScheme`) rather than hardcoding colors, to keep light/dark parity.

## Platform targets

The project scaffolding includes Android, iOS, macOS, Linux, Windows, and web (`flutter create` defaults), but active development has focused on mobile (Android/iOS) layouts. Check screen layouts in `lib/pantallas/` for fixed mobile assumptions before assuming desktop/web layouts work well.
