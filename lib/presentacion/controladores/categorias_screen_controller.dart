import 'package:get/get.dart';

import '../../data/modelos/modelo_categoria.dart';
import '../../data/repositorios/categoria_repositorio_impl.dart';
import '../../datos/categorias_controlador.dart';
import '../../dominio/repositorios/categoria_repositorio.dart';

/// Estado de CategoriasScreen: las dos listas (shortcut/comando) que se
/// administran ahí. Distinto de CategoriasController (el caché compartido
/// que usan el resto de pantallas para chips/íconos) — este SÍ se refresca
/// después de cada mutación para mantenerlo sincronizado.
class CategoriasScreenController extends GetxController {
  final CategoriaRepositorio _repositorio;

  CategoriasScreenController({CategoriaRepositorio? repositorio})
    : _repositorio = repositorio ?? CategoriaRepositorioImpl();

  final RxList<ModeloCategoria> shortcuts = <ModeloCategoria>[].obs;
  final RxList<ModeloCategoria> comandos = <ModeloCategoria>[].obs;
  final RxBool cargando = true.obs;

  @override
  void onInit() {
    super.onInit();
    cargar();
  }

  Future<void> cargar() async {
    shortcuts.assignAll(await _repositorio.listarModelo('shortcut'));
    comandos.assignAll(await _repositorio.listarModelo('comando'));
    cargando.value = false;
    await CategoriasController.instance.cargar();
  }

  Future<int> contarUso(String tipo, String idCategoria) =>
      _repositorio.contarUso(tipo, idCategoria);

  Future<void> eliminar(int pkCategoria) async {
    await _repositorio.eliminar(pkCategoria);
    await cargar();
  }
}
