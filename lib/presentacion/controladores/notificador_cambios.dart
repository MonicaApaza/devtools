import 'package:get/get.dart';

import 'estadisticas_controller.dart';
import 'home_controller.dart';

/// Reemplaza al antiguo bus CambiosDatos (ChangeNotifier): cuando
/// Shortcuts o Comandos guardan un cambio, llaman directamente a los
/// controladores que dependen de esos datos (Home, Estadísticas), solo si
/// están registrados en ese momento (Home vive mientras RootShell esté
/// montado; Estadísticas solo mientras esa ruta esté abierta).
Future<void> avisarCambioDeDatos() async {
  if (Get.isRegistered<HomeController>()) {
    await Get.find<HomeController>().cargar();
  }
  if (Get.isRegistered<EstadisticasController>()) {
    await Get.find<EstadisticasController>().cargar();
  }
}
