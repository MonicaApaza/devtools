import '../../dominio/repositorios/shortcut_repositorio.dart';
import '../datasources/db_helper.dart';
import '../modelos/modelo_shortcut.dart';

class ShortcutRepositorioImpl implements ShortcutRepositorio {
  final DatabaseHelper _dbHelper;

  ShortcutRepositorioImpl({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  @override
  Future<List<ModeloShortcut>> listar() => _dbHelper.getShortcuts();

  @override
  Future<int> crear(ModeloShortcut shortcut) =>
      _dbHelper.insertarShortcut(shortcut);

  @override
  Future<void> actualizar(ModeloShortcut shortcut) =>
      _dbHelper.actualizarShortcut(shortcut);

  @override
  Future<void> eliminar(int pkShortcut) =>
      _dbHelper.eliminarShortcut(pkShortcut);

  @override
  Future<bool> existeTitulo(String titulo, {int? excluirPk}) =>
      _dbHelper.existeTituloShortcut(titulo, excluirPk: excluirPk);
}
