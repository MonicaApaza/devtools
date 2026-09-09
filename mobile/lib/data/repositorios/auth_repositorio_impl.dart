import '../../dominio/entidades/sesion.dart';
import '../../dominio/repositorios/auth_repositorio.dart';
import '../datasources/api_client.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositorioImpl implements AuthRepositorio {
  final ApiClient _api;
  final AuthLocalDatasource _datasource;

  AuthRepositorioImpl({ApiClient? api, AuthLocalDatasource? datasource})
    : _api = api ?? ApiClient(),
      _datasource = datasource ?? AuthLocalDatasource();

  @override
  Future<Sesion?> obtenerSesionGuardada() async {
    final json = _datasource.leerSesion();
    if (json == null) return null;

    final sesion = Sesion.fromJson(json);
    if (sesion.estaExpirada) {
      await _datasource.borrar();
      return null;
    }
    return sesion;
  }

  @override
  Future<Sesion> iniciarSesion(String usuario, String password) async {
    final respuesta = await _api.post(
      '/auth/login',
      body: {'username': usuario, 'password': password},
    );
    return _guardarDesdeRespuesta(respuesta as Map<String, dynamic>);
  }

  @override
  Future<Sesion> registrar(String usuario, String password) async {
    final respuesta = await _api.post(
      '/auth/register',
      body: {'username': usuario, 'password': password},
    );
    return _guardarDesdeRespuesta(respuesta as Map<String, dynamic>);
  }

  Future<Sesion> _guardarDesdeRespuesta(Map<String, dynamic> respuesta) async {
    final sesion = Sesion.fromJson(respuesta);
    await _datasource.guardarSesion(sesion.toJson());
    return sesion;
  }

  @override
  Future<void> cerrarSesion() => _datasource.borrar();
}
