import '../../dominio/repositorios/categoria_repositorio.dart';
import '../datasources/api_client.dart';
import '../datos_estaticos/categorias.dart';
import '../modelos/modelo_categoria.dart';

class CategoriaRepositorioImpl implements CategoriaRepositorio {
  final ApiClient _api;

  CategoriaRepositorioImpl({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<ModeloCategoria>> _listarDesdeApi(String tipo) async {
    final respuesta = await _api.get(
      '/categories',
      query: {'type': tipoCategoriaAApi(tipo)},
    );
    return (respuesta as List)
        .map((json) => ModeloCategoria.fromApi(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ModeloCategoria>> listarModelo(String tipo) =>
      _listarDesdeApi(tipo);

  @override
  Future<List<Categoria>> listar(String tipo) async {
    final categorias = await _listarDesdeApi(tipo);
    return categorias
        .map(
          (c) => Categoria(
            id: c.pkCategoria!,
            nombre: c.nombreCategoria,
            icono: iconoPorClave(c.iconoCategoria),
          ),
        )
        .toList();
  }

  @override
  Future<ModeloCategoria> crear({
    required String tipo,
    required String nombre,
    required String iconoClave,
  }) async {
    final respuesta = await _api.post(
      '/categories',
      body: {
        'name': nombre,
        'icon': iconoClave,
        'type': tipoCategoriaAApi(tipo),
      },
    );
    return ModeloCategoria.fromApi(respuesta as Map<String, dynamic>);
  }

  @override
  Future<ModeloCategoria> actualizar(ModeloCategoria categoria) async {
    final respuesta = await _api.put(
      '/categories/${categoria.pkCategoria}',
      body: categoria.toApiBody(),
    );
    return ModeloCategoria.fromApi(respuesta as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String pkCategoria) =>
      _api.delete('/categories/$pkCategoria');
}
