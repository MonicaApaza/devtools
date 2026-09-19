import '../entidades/categorias.dart';
import '../entidades/modelo_categoria.dart';

/// Contrato de acceso a datos para categorías (compartidas entre shortcuts
/// y comandos, incluyendo el tipo especial 'ambos'). El usuario ya no es un
/// parámetro: el backend lo infiere del token de la sesión.
///
/// No hay `existeNombre`/`contarUso` como pre-chequeos: el backend no
/// expone endpoints para "consultar antes de intentar" — enforce
/// duplicados y uso-en-categoría devolviendo 409 desde `crear`/`actualizar`/
/// `eliminar` directamente (ver [ApiConflictException]).
abstract class CategoriaRepositorio {
  Future<List<ModeloCategoria>> listarModelo(String tipo);
  Future<List<Categoria>> listar(String tipo);
  Future<ModeloCategoria> crear({
    required String tipo,
    required String nombre,
    required String iconoClave,
  });
  Future<ModeloCategoria> actualizar(ModeloCategoria categoria);
  Future<void> eliminar(String pkCategoria);
}
