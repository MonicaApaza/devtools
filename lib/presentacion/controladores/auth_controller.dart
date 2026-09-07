import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/repositorios/auth_repositorio_impl.dart';
import '../../dominio/entidades/sesion.dart';
import '../../dominio/repositorios/auth_repositorio.dart';
import '../../rutas/app_rutas.dart';

/// Autenticación local, sin backend: igual que en el ejemplo de clase
/// `get_storage_login`, no valida usuario/password contra nada, solo los
/// guarda como "sesión activa" en el dispositivo (vía AuthRepositorio ->
/// GetStorage). Sirve como "recordar sesión", no como login real.
class AuthController extends GetxController {
  final AuthRepositorio _repositorio;

  AuthController({AuthRepositorio? repositorio})
    : _repositorio = repositorio ?? AuthRepositorioImpl();

  static AuthController get instance => Get.find<AuthController>();

  final tecUsuario = TextEditingController();
  final tecPassword = TextEditingController();

  final Rxn<Sesion> sesion = Rxn<Sesion>();
  final mostrarContrasena = false.obs;

  // Cadena vacía cuando no hay sesión: no matchea ningún usuario guardado
  // en la base, así que shortcuts/comandos/categorías simplemente se ven
  // como listas vacías en vez de fallar.
  String get usuarioActual => sesion.value?.usuario ?? '';

  void alternarVisibilidadContrasena() {
    mostrarContrasena.toggle();
  }

  @override
  void onInit() {
    super.onInit();
    _revisarSesionGuardada();
  }

  Future<void> _revisarSesionGuardada() async {
    sesion.value = await _repositorio.obtenerSesionGuardada();
  }

  Future<void> iniciarSesion() async {
    final usuario = tecUsuario.text.trim();
    final password = tecPassword.text.trim();
    if (usuario.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Ingresa usuario y contraseña',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade300,
      );
      return;
    }

    sesion.value = await _repositorio.guardarSesion(usuario, password);
    tecUsuario.clear();
    tecPassword.clear();

    Get.snackbar(
      'Bienvenido',
      'Sesión iniciada como ${sesion.value!.usuario}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade300,
      duration: const Duration(milliseconds: 2000),
    );
    Get.offAllNamed(AppRutas.inicio);
  }

  void continuarConSesionGuardada() {
    if (sesion.value == null) return;
    Get.offAllNamed(AppRutas.inicio);
  }

  Future<void> cerrarSesion() async {
    await _repositorio.cerrarSesion();
    sesion.value = null;
  }

  @override
  void onClose() {
    tecUsuario.dispose();
    tecPassword.dispose();
    super.onClose();
  }
}
