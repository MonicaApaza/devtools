import '../../data/modelos/modelo_comando.dart';

/// Contrato de acceso a datos para comandos. Ver ShortcutRepositorio para
/// el razonamiento de por qué la presentación no habla con `DatabaseHelper`
/// directamente.
abstract class ComandoRepositorio {
  Future<List<ModeloComando>> listar(String usuario);
  Future<int> crear(ModeloComando comando);
  Future<void> actualizar(ModeloComando comando);
  Future<void> eliminar(int pkComando);
  Future<void> incrementarUso(int pkComando);
  Future<bool> existeTitulo(String titulo, String usuario, {int? excluirPk});
}
