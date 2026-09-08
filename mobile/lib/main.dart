import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'datos/categorias_controlador.dart';
import 'presentacion/controladores/auth_controller.dart';
import 'presentacion/controladores/busqueda_controller.dart';
import 'rutas/app_paginas.dart';
import 'rutas/app_rutas.dart';
import 'theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(BusquedaController(), permanent: true);
  // Permanente (no ligado a la ruta /login) para que la sesión sobreviva a
  // la navegación: Get.offAllNamed al iniciar sesión elimina la ruta de
  // Login por completo, y con ella cualquier dependencia que solo viviera
  // ligada a esa ruta.
  Get.put(AuthController(), permanent: true);
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
          initialRoute: AppRutas.login,
          getPages: AppPaginas.paginas,
        );
      },
    );
  }
}
