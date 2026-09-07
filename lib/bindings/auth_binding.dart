import 'package:get/get.dart';

import '../presentacion/controladores/auth_controller.dart';

/// Inyección de dependencias de la ruta /login (Sesión 7: GetPage +
/// bindings). AuthController se instancia solo cuando se visita esta ruta.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
