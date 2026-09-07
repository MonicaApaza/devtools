import '../../dominio/repositorios/comando_repositorio.dart';
import '../datasources/db_helper.dart';
import '../modelos/modelo_comando.dart';

class ComandoRepositorioImpl implements ComandoRepositorio {
  final DatabaseHelper _dbHelper;

  ComandoRepositorioImpl({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  @override
  Future<List<ModeloComando>> listar() => _dbHelper.getComandos();

  @override
  Future<int> crear(ModeloComando comando) =>
      _dbHelper.insertarComando(comando);

  @override
  Future<void> actualizar(ModeloComando comando) =>
      _dbHelper.actualizarComando(comando);

  @override
  Future<void> eliminar(int pkComando) => _dbHelper.eliminarComando(pkComando);

  @override
  Future<void> incrementarUso(int pkComando) =>
      _dbHelper.incrementarUsoComando(pkComando);

  @override
  Future<bool> existeTitulo(String titulo, {int? excluirPk}) =>
      _dbHelper.existeTituloComando(titulo, excluirPk: excluirPk);
}
