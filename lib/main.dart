import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'datos/categorias_controlador.dart';
import 'rutas/app_paginas.dart';
import 'rutas/app_rutas.dart';
import 'theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final categorias = Get.put(CategoriasController(), permanent: true);
  await categorias.cargar();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        return GetMaterialApp(
          title: 'QuickDev',
          debugShowCheckedModeBanner: false,
          theme: ThemeController.instance.temaClaro,
          darkTheme: ThemeController.instance.temaOscuro,
          themeMode: ThemeController.instance.modo,
          // Rutas nombradas vía GetPage (Sesión 7: Vistas y Componentes UI).
          initialRoute: AppRutas.inicio,
          getPages: AppPaginas.paginas,
        );
      },
    );
  }
}
