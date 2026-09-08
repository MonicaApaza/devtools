import '../../dominio/repositorios/categoria_repositorio.dart';
import '../datasources/db_helper.dart';
import '../datos_estaticos/categorias.dart';
import '../modelos/modelo_categoria.dart';

class CategoriaRepositorioImpl implements CategoriaRepositorio {
  final DatabaseHelper _dbHelper;

  CategoriaRepositorioImpl({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  @override
  Future<List<ModeloCategoria>> listarModelo(String tipo, String usuario) =>
      _dbHelper.getCategoriasModelo(tipo, usuario);

  @override
  Future<List<Categoria>> listar(String tipo, String usuario) =>
      _dbHelper.getCategorias(tipo, usuario);

  @override
  Future<bool> existeNombre(
    String tipo,
    String nombre,
    String usuario, {
    int? excluirPk,
  }) => _dbHelper.existeNombreCategoria(
    tipo,
    nombre,
    usuario,
    excluirPk: excluirPk,
  );

  @override
  Future<void> crear({
    required String tipo,
    required String nombre,
    required String iconoClave,
    required String usuario,
  }) => _dbHelper.insertarCategoria(
    tipo: tipo,
    nombre: nombre,
    iconoClave: iconoClave,
    usuario: usuario,
  );

  @override
  Future<void> actualizar(ModeloCategoria categoria) =>
      _dbHelper.actualizarCategoria(categoria);

  @override
  Future<void> eliminar(int pkCategoria) =>
      _dbHelper.eliminarCategoria(pkCategoria);

  @override
  Future<int> contarUso(String tipo, String idCategoria, String usuario) =>
      _dbHelper.contarUsoCategoria(tipo, idCategoria, usuario);
}
