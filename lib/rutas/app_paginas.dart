import 'package:get/get.dart';

import '../pantallas/ajustes_screen.dart';
import '../pantallas/categorias_screen.dart';
import '../pantallas/estadisticas_screen.dart';
import '../pantallas/root_shell.dart';
import 'app_rutas.dart';

/// Tabla de rutas nombradas (Sesión 7: GetPage). Reproduce exactamente las
/// rutas que antes vivían en el `routes:` de MaterialApp, sin cambiar
/// pantallas todavía.
class AppPaginas {
  AppPaginas._();

  static final paginas = [
    GetPage(name: AppRutas.inicio, page: () => const RootShell()),
    GetPage(name: AppRutas.ajustes, page: () => const AjustesScreen()),
    GetPage(
      name: AppRutas.estadisticas,
      page: () => const EstadisticasScreen(),
    ),
    GetPage(name: AppRutas.categorias, page: () => const CategoriasScreen()),
  ];
}
