import '../../dominio/entidades/sesion.dart';
import '../../dominio/repositorios/auth_repositorio.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositorioImpl implements AuthRepositorio {
  final AuthLocalDatasource _datasource;

  AuthRepositorioImpl({AuthLocalDatasource? datasource})
    : _datasource = datasource ?? AuthLocalDatasource();

  @override
  Future<Sesion?> obtenerSesionGuardada() async {
    final usuario = _datasource.leerUsuario();
    final iniciadaEn = _datasource.leerIniciadaEn();
    if (usuario == null || usuario.isEmpty || iniciadaEn == null) return null;
    return Sesion(usuario: usuario, iniciadaEn: iniciadaEn);
  }

  @override
  Future<Sesion> guardarSesion(String usuario, String password) async {
    final iniciadaEn = DateTime.now().millisecondsSinceEpoch;
    await _datasource.guardar(usuario, password, iniciadaEn);
    return Sesion(usuario: usuario, iniciadaEn: iniciadaEn);
  }

  @override
  Future<void> cerrarSesion() => _datasource.borrar();
}
