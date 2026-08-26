import 'package:flutter/material.dart';

/// Color semilla del tema (equivalente al "accentHue" del prototipo de diseño).
const Color colorSemilla = Color(0xFF0F9D77);

/// Controla el ThemeMode de toda la app (claro/oscuro) mediante ChangeNotifier,
/// el equivalente en tiempo de ejecución al patrón Theme + InheritedWidget:
/// cualquier widget que escuche este controlador se reconstruye cuando cambia.
class ThemeController extends ChangeNotifier {
  ThemeController._internal();
  static final ThemeController instance = ThemeController._internal();
  factory ThemeController() => instance;

  ThemeMode _modo = ThemeMode.light;
  ThemeMode get modo => _modo;
  bool get esOscuro => _modo == ThemeMode.dark;

  void alternar() {
    _modo = esOscuro ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  ThemeData get temaClaro => _construirTema(Brightness.light);
  ThemeData get temaOscuro => _construirTema(Brightness.dark);

  ThemeData _construirTema(Brightness brillo) {
    final esquema = ColorScheme.fromSeed(
      seedColor: colorSemilla,
      brightness: brillo,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: esquema.surface,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: esquema.surface,
        foregroundColor: esquema.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: esquema.outlineVariant),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: esquema.outlineVariant),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: esquema.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: esquema.primary,
        foregroundColor: esquema.onPrimary,
        shape: const CircleBorder(),
      ),
    );
  }
}
