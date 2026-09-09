import 'package:get_storage/get_storage.dart';

/// Persiste la sesión JWT (userId/usuario/token/expiresAt) como un único
/// mapa en GetStorage — el mismo mecanismo local de antes, pero ahora
/// guardando una sesión real emitida por el backend en vez de datos
/// inventados.
class AuthLocalDatasource {
  final GetStorage _storage;

  AuthLocalDatasource({GetStorage? storage}) : _storage = storage ?? GetStorage();

  static const _claveSesion = 'sesion';

  Map<String, dynamic>? leerSesion() {
    final datos = _storage.read(_claveSesion);
    if (datos == null) return null;
    return Map<String, dynamic>.from(datos as Map);
  }

  Future<void> guardarSesion(Map<String, dynamic> sesionJson) =>
      _storage.write(_claveSesion, sesionJson);

  Future<void> borrar() => _storage.remove(_claveSesion);
}
