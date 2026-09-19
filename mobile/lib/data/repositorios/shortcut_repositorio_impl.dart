import '../../dominio/repositorios/shortcut_repositorio.dart';
import '../datasources/api_client.dart';
import '../../dominio/entidades/modelo_shortcut.dart';

class ShortcutRepositorioImpl implements ShortcutRepositorio {
  final ApiClient _api;

  ShortcutRepositorioImpl({ApiClient? api}) : _api = api ?? ApiClient();

  @override
  Future<List<ModeloShortcut>> listar() async {
    final respuesta = await _api.get('/shortcuts');
    return (respuesta as List)
        .map((json) => ModeloShortcut.fromApi(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ModeloShortcut> crear(ModeloShortcut shortcut) async {
    final respuesta = await _api.post('/shortcuts', body: shortcut.toApiBody());
    return ModeloShortcut.fromApi(respuesta as Map<String, dynamic>);
  }

  @override
  Future<ModeloShortcut> actualizar(ModeloShortcut shortcut) async {
    final respuesta = await _api.put(
      '/shortcuts/${shortcut.pkShortcut}',
      body: shortcut.toApiBody(),
    );
    return ModeloShortcut.fromApi(respuesta as Map<String, dynamic>);
  }

  @override
  Future<ModeloShortcut> alternarFavorito(
    String pkShortcut,
    bool favorito,
  ) async {
    final respuesta = await _api.patch(
      '/shortcuts/$pkShortcut/favorite',
      body: {'isFavorite': favorito},
    );
    return ModeloShortcut.fromApi(respuesta as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String pkShortcut) =>
      _api.delete('/shortcuts/$pkShortcut');
}
