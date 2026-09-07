import 'package:get/get.dart';

/// Avisa a quien esté escuchando (p. ej. HomeScreen, EstadisticasScreen) que
/// los shortcuts o comandos cambiaron en la base de datos, sin que las
/// pantallas necesiten conocerse entre sí. Versión GetX (RxInt como
/// contador de versión) del bus que antes era un ChangeNotifier.
///
/// Es un paso intermedio: cuando Shortcuts/Comandos/Home/Estadísticas
/// tengan sus propios GetxController (tareas siguientes), este bus se
/// retira del todo a favor de llamadas directas entre controladores
/// (p. ej. `Get.find<HomeController>().cargar()` luego de guardar un
/// shortcut), tal como se planteó originalmente.
class CambiosDatos extends GetxController {
  static CambiosDatos get instance => Get.find<CambiosDatos>();

  final RxInt version = 0.obs;

  void avisar() => version.value++;
}
