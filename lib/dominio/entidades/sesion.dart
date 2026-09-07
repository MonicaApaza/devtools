/// Entidad de dominio para la sesión local (sin backend). Igual que en el
/// ejemplo de clase `get_storage_login`, no valida credenciales contra un
/// servidor: solo representa "quién quedó activo" en este dispositivo.
class Sesion {
  final String usuario;
  final int iniciadaEn;

  const Sesion({required this.usuario, required this.iniciadaEn});
}
