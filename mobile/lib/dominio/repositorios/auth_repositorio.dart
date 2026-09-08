import '../entidades/sesion.dart';

/// Contrato de autenticación local (sin backend). La implementación de hoy
/// guarda la sesión en el dispositivo (GetStorage); una futura integración
/// con un backend (p. ej. Supabase Auth) solo requeriría una nueva
/// implementación de esta misma interfaz.
abstract class AuthRepositorio {
  Future<Sesion?> obtenerSesionGuardada();
  Future<Sesion> guardarSesion(String usuario, String password);
  Future<void> cerrarSesion();
}
