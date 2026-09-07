import '../../data/datos_estaticos/categorias.dart';
import '../../data/modelos/modelo_categoria.dart';

/// Contrato de acceso a datos para categorías (compartidas entre shortcuts
/// y comandos, incluyendo el tipo especial 'ambos').
abstract class CategoriaRepositorio {
  Future<List<ModeloCategoria>> listarModelo(String tipo);
  Future<List<Categoria>> listar(String tipo);
  Future<bool> existeNombre(String tipo, String nombre, {int? excluirPk});
  Future<void> crear({
    required String tipo,
    required String nombre,
    required String iconoClave,
  });
  Future<void> actualizar(ModeloCategoria categoria);
  Future<void> eliminar(int pkCategoria);
  Future<int> contarUso(String tipo, String idCategoria);
}
