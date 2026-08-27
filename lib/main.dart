import 'package:flutter/material.dart';

import 'datos/categorias_controlador.dart';
import 'pantallas/ajustes_screen.dart';
import 'pantallas/categorias_screen.dart';
import 'pantallas/estadisticas_screen.dart';
import 'pantallas/root_shell.dart';
import 'theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CategoriasController.instance.cargar();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'QuickDev',
          debugShowCheckedModeBanner: false,
          theme: ThemeController.instance.temaClaro,
          darkTheme: ThemeController.instance.temaOscuro,
          themeMode: ThemeController.instance.modo,
          // Ruta inicial + tabla de rutas nombradas (Sesión 5: Rutas Nombradas).
          initialRoute: '/',
          routes: {
            '/': (context) => const RootShell(),
            '/ajustes': (context) => const AjustesScreen(),
            '/estadisticas': (context) => const EstadisticasScreen(),
            '/categorias': (context) => const CategoriasScreen(),
          },
        );
      },
    );
  }
}
