import '../../dominio/repositorios/categoria_repositorio.dart';
import '../datasources/db_helper.dart';
import '../datos_estaticos/categorias.dart';
import '../modelos/modelo_categoria.dart';

class CategoriaRepositorioImpl implements CategoriaRepositorio {
  final DatabaseHelper _dbHelper;

  CategoriaRepositorioImpl({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  @override
  Future<List<ModeloCategoria>> listarModelo(String tipo) =>
      _dbHelper.getCategoriasModelo(tipo);

  @override
  Future<List<Categoria>> listar(String tipo) => _dbHelper.getCategorias(tipo);

  @override
  Future<bool> existeNombre(String tipo, String nombre, {int? excluirPk}) =>
      _dbHelper.existeNombreCategoria(tipo, nombre, excluirPk: excluirPk);

  @override
  Future<void> crear({
    required String tipo,
    required String nombre,
    required String iconoClave,
  }) => _dbHelper.insertarCategoria(
    tipo: tipo,
    nombre: nombre,
    iconoClave: iconoClave,
  );

  @override
  Future<void> actualizar(ModeloCategoria categoria) =>
      _dbHelper.actualizarCategoria(categoria);

  @override
  Future<void> eliminar(int pkCategoria) =>
      _dbHelper.eliminarCategoria(pkCategoria);

  @override
  Future<int> contarUso(String tipo, String idCategoria) =>
      _dbHelper.contarUsoCategoria(tipo, idCategoria);
}
