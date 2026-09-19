import '../entidades/modelo_shortcut.dart';

/// Contrato de acceso a datos para shortcuts (backend real vía API; ver
/// CategoriaRepositorio para el razonamiento del diseño). El usuario no es
/// un parámetro: el backend lo infiere del token de la sesión.
///
/// No hay `existeTitulo` como pre-chequeo: el backend rechaza duplicados
/// devolviendo 409 desde `crear`/`actualizar` (ver [ApiConflictException]).
abstract class ShortcutRepositorio {
  Future<List<ModeloShortcut>> listar();
  Future<ModeloShortcut> crear(ModeloShortcut shortcut);
  Future<ModeloShortcut> actualizar(ModeloShortcut shortcut);
  Future<ModeloShortcut> alternarFavorito(String pkShortcut, bool favorito);
  Future<void> eliminar(String pkShortcut);
}
