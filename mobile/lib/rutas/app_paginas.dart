import 'package:get/get.dart';

import '../pantallas/ajustes_screen.dart';
import '../pantallas/categorias_screen.dart';
import '../pantallas/estadisticas_screen.dart';
import '../pantallas/reportes_screen.dart';
import '../pantallas/root_shell.dart';
import '../presentacion/pantallas/login_screen.dart';
import '../presentacion/pantallas/register_screen.dart';
import 'app_rutas.dart';

/// Tabla de rutas nombradas (Sesión 7: GetPage). Reproduce las rutas que
/// antes vivían en el `routes:` de MaterialApp y suma /login como ruta
/// navegable de forma independiente (todavía sin gate: RootShell sigue
/// siendo initialRoute).
class AppPaginas {
  AppPaginas._();

  static final paginas = [
    GetPage(name: AppRutas.inicio, page: () => const RootShell()),
    GetPage(name: AppRutas.login, page: () => const LoginScreen()),
    GetPage(name: AppRutas.registro, page: () => const RegisterScreen()),
    GetPage(name: AppRutas.ajustes, page: () => const AjustesScreen()),
    GetPage(
      name: AppRutas.estadisticas,
      page: () => const EstadisticasScreen(),
    ),
    GetPage(name: AppRutas.reportes, page: () => const ReportesScreen()),
    GetPage(name: AppRutas.categorias, page: () => const CategoriasScreen()),
  ];
}
