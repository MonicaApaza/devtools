import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Color semilla del tema (equivalente al "accentHue" del prototipo de diseño).
const Color colorSemilla = Color(0xFF0F9D77);

/// Controla el ThemeMode de toda la app (claro/oscuro) mediante GetX, el
/// equivalente en tiempo de ejecución al patrón Theme + InheritedWidget:
/// cualquier widget que lo lea dentro de un Obx se reconstruye cuando cambia.
/// Registrado con Get.put(permanent: true) en main() (igual que
/// AuthController/CategoriasController), y accedido en cualquier parte con
/// ThemeController.instance.
class ThemeController extends GetxController {
  static ThemeController get instance => Get.find<ThemeController>();

  final Rx<ThemeMode> _modo = ThemeMode.light.obs;
  ThemeMode get modo => _modo.value;
  bool get esOscuro => _modo.value == ThemeMode.dark;

  void alternar() {
    _modo.value = esOscuro ? ThemeMode.light : ThemeMode.dark;
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
