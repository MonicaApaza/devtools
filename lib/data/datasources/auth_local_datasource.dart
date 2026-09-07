import 'package:get_storage/get_storage.dart';

/// Envuelve GetStorage con las mismas claves que usa el ejemplo de clase
/// `get_storage_login` ('username_activo' / 'password_activo'), sin ninguna
/// verificación real de credenciales: solo persiste "quién quedó activo".
class AuthLocalDatasource {
  final GetStorage _storage;

  AuthLocalDatasource({GetStorage? storage}) : _storage = storage ?? GetStorage();

  static const _claveUsuario = 'username_activo';
  static const _clavePassword = 'password_activo';
  static const _claveIniciadaEn = 'sesion_iniciada_en';

  String? leerUsuario() => _storage.read(_claveUsuario);

  int? leerIniciadaEn() => _storage.read(_claveIniciadaEn);

  Future<void> guardar(String usuario, String password, int iniciadaEn) async {
    await _storage.write(_claveUsuario, usuario);
    await _storage.write(_clavePassword, password);
    await _storage.write(_claveIniciadaEn, iniciadaEn);
  }

  Future<void> borrar() async {
    await _storage.remove(_claveUsuario);
    await _storage.remove(_clavePassword);
    await _storage.remove(_claveIniciadaEn);
  }
}
