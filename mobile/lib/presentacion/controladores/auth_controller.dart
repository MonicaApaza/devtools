import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/datasources/api_client.dart';
import '../../data/repositorios/auth_repositorio_impl.dart';
import '../../dominio/entidades/sesion.dart';
import '../../dominio/repositorios/auth_repositorio.dart';
import '../../rutas/app_rutas.dart';

/// Autenticación real contra el backend (JWT): usuario/contraseña se
/// validan en el servidor vía [AuthRepositorio].
class AuthController extends GetxController {
  final AuthRepositorio _repositorio;

  AuthController({AuthRepositorio? repositorio})
    : _repositorio = repositorio ?? AuthRepositorioImpl();

  static AuthController get instance => Get.find<AuthController>();

  final tecUsuario = TextEditingController();
  final tecPassword = TextEditingController();

  final Rxn<Sesion> sesion = Rxn<Sesion>();
  final mostrarContrasena = false.obs;
  final cargando = false.obs;

  bool get estaAutenticado => sesion.value != null;

  // Cadena vacía cuando no hay sesión: no matchea ningún usuario guardado
  // en la base, así que shortcuts/comandos/categorías simplemente se ven
  // como listas vacías en vez de fallar.
  String get usuarioActual => sesion.value?.usuario ?? '';

  void alternarVisibilidadContrasena() {
    mostrarContrasena.toggle();
  }

  /// Se llama explícitamente y con `await` desde `main()` antes de decidir
  /// la ruta inicial (login vs. inicio) — no basta con dejarlo correr solo
  /// en `onInit()`, ya que esa llamada no se espera antes de construir
  /// `GetMaterialApp`.
  Future<void> cargarSesionInicial() async {
    sesion.value = await _repositorio.obtenerSesionGuardada();
    ApiClient.instancia.tokenProvider = () => sesion.value?.token;
  }

  Future<void> iniciarSesion() async {
    final usuario = tecUsuario.text.trim();
    final password = tecPassword.text.trim();
    if (usuario.isEmpty || password.isEmpty) {
      _mostrarError('Ingresa usuario y contraseña');
      return;
    }

    cargando.value = true;
    try {
      sesion.value = await _repositorio.iniciarSesion(usuario, password);
      tecUsuario.clear();
      tecPassword.clear();
      Get.offAllNamed(AppRutas.inicio);
    } on ApiUnauthorizedException {
      _mostrarError('Usuario o contraseña incorrectos');
    } on ApiException catch (e) {
      _mostrarError(e.message);
    } finally {
      cargando.value = false;
    }
  }

  Future<void> registrar() async {
    final usuario = tecUsuario.text.trim();
    final password = tecPassword.text.trim();
    if (usuario.length < 3 || usuario.length > 50) {
      _mostrarError('El usuario debe tener entre 3 y 50 caracteres');
      return;
    }
    if (password.length < 6 || password.length > 100) {
      _mostrarError('La contraseña debe tener entre 6 y 100 caracteres');
      return;
    }

    cargando.value = true;
    try {
      sesion.value = await _repositorio.registrar(usuario, password);
      tecUsuario.clear();
      tecPassword.clear();
      Get.offAllNamed(AppRutas.inicio);
    } on ApiConflictException {
      _mostrarError('Ese usuario ya existe');
    } on ApiException catch (e) {
      _mostrarError(e.message);
    } finally {
      cargando.value = false;
    }
  }

  void _mostrarError(String mensaje) {
    Get.snackbar(
      'Error',
      mensaje,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade300,
    );
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
