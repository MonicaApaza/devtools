import '../../data/modelos/modelo_shortcut.dart';

/// Contrato de acceso a datos para shortcuts. La presentación depende de
/// esta interfaz, nunca de `DatabaseHelper` directamente, para que el
/// origen de datos (hoy SQLite, mañana quizá Supabase) sea intercambiable
/// sin tocar controladores ni pantallas.
abstract class ShortcutRepositorio {
  Future<List<ModeloShortcut>> listar();
  Future<int> crear(ModeloShortcut shortcut);
  Future<void> actualizar(ModeloShortcut shortcut);
  Future<void> eliminar(int pkShortcut);
  Future<bool> existeTitulo(String titulo, {int? excluirPk});
}
