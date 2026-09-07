import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Búsqueda compartida entre Inicio, Shortcuts y Comandos: un único texto
/// (y un único TextEditingController) para que escribir en cualquiera de
/// esas tres pantallas se refleje en las otras al cambiar de pestaña, en
/// vez de que cada una tenga su propio cuadro de búsqueda independiente.
/// Se registra una sola vez con Get.put(permanent: true) en main().
class BusquedaController extends GetxController {
  static BusquedaController get instance => Get.find<BusquedaController>();

  final textoController = TextEditingController();
  final RxString texto = ''.obs;

  void actualizar(String valor) => texto.value = valor;

  void limpiar() {
    texto.value = '';
    textoController.clear();
  }

  @override
  void onClose() {
    textoController.dispose();
    super.onClose();
  }
}
