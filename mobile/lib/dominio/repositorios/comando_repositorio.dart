import '../entidades/modelo_comando.dart';

/// Contrato de acceso a datos para comandos. Ver ShortcutRepositorio para
/// el razonamiento de por qué la presentación no habla con la API
/// directamente ni valida duplicados en el cliente.
abstract class ComandoRepositorio {
  Future<List<ModeloComando>> listar();
  Future<ModeloComando> crear(ModeloComando comando);
  Future<ModeloComando> actualizar(ModeloComando comando);
  Future<ModeloComando> alternarFavorito(String pkComando, bool favorito);
  Future<int> incrementarUso(String pkComando);
  Future<void> eliminar(String pkComando);
}
