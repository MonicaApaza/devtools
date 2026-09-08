import '../../data/datos_estaticos/categorias.dart';
import '../../data/modelos/modelo_categoria.dart';

/// Contrato de acceso a datos para categorías (compartidas entre shortcuts
/// y comandos, incluyendo el tipo especial 'ambos'). Cada categoría
/// pertenece a un usuario, igual que shortcuts y comandos.
abstract class CategoriaRepositorio {
  Future<List<ModeloCategoria>> listarModelo(String tipo, String usuario);
  Future<List<Categoria>> listar(String tipo, String usuario);
  Future<bool> existeNombre(
    String tipo,
    String nombre,
    String usuario, {
    int? excluirPk,
  });
  Future<void> crear({
    required String tipo,
    required String nombre,
    required String iconoClave,
    required String usuario,
  });
  Future<void> actualizar(ModeloCategoria categoria);
  Future<void> eliminar(int pkCategoria);
  Future<int> contarUso(String tipo, String idCategoria, String usuario);
}
