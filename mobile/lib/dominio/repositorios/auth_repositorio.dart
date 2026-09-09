import '../entidades/sesion.dart';

/// Contrato de autenticación contra el backend real (JWT). La sesión se
/// guarda en el dispositivo (GetStorage) solo para no pedir login en cada
/// arranque, pero usuario/contraseña sí se validan contra el servidor.
abstract class AuthRepositorio {
  /// Sesión guardada localmente, o `null` si no hay ninguna o ya expiró.
  Future<Sesion?> obtenerSesionGuardada();

  /// Llama a `POST /auth/login`. Lanza [ApiUnauthorizedException] si las
  /// credenciales son inválidas.
  Future<Sesion> iniciarSesion(String usuario, String password);

  /// Llama a `POST /auth/register`. Lanza [ApiConflictException] si el
  /// usuario ya existe.
  Future<Sesion> registrar(String usuario, String password);

  Future<void> cerrarSesion();
}
