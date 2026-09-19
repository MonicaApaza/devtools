import '../../dominio/repositorios/comando_repositorio.dart';
import '../datasources/api_client.dart';
import '../../dominio/entidades/modelo_comando.dart';

class ComandoRepositorioImpl implements ComandoRepositorio {
  final ApiClient _api;

  ComandoRepositorioImpl({ApiClient? api}) : _api = api ?? ApiClient();

  @override
  Future<List<ModeloComando>> listar() async {
    final respuesta = await _api.get('/commands');
    return (respuesta as List)
        .map((json) => ModeloComando.fromApi(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ModeloComando> crear(ModeloComando comando) async {
    final respuesta = await _api.post('/commands', body: comando.toApiBody());
    return ModeloComando.fromApi(respuesta as Map<String, dynamic>);
  }

  @override
  Future<ModeloComando> actualizar(ModeloComando comando) async {
    final respuesta = await _api.put(
      '/commands/${comando.pkComando}',
      body: comando.toApiBody(),
    );
    return ModeloComando.fromApi(respuesta as Map<String, dynamic>);
  }

  @override
  Future<ModeloComando> alternarFavorito(
    String pkComando,
    bool favorito,
  ) async {
    final respuesta = await _api.patch(
      '/commands/$pkComando/favorite',
      body: {'isFavorite': favorito},
    );
    return ModeloComando.fromApi(respuesta as Map<String, dynamic>);
  }

  @override
  Future<int> incrementarUso(String pkComando) async {
    final respuesta = await _api.post('/commands/$pkComando/use');
    return (respuesta as Map<String, dynamic>)['usageCount'] as int;
  }

  @override
  Future<void> eliminar(String pkComando) => _api.delete('/commands/$pkComando');
}
