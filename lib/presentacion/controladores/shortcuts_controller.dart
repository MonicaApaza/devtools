import 'package:get/get.dart';

import '../../data/modelos/modelo_shortcut.dart';
import '../../data/repositorios/shortcut_repositorio_impl.dart';
import '../../dominio/repositorios/shortcut_repositorio.dart';
import 'busqueda_controller.dart';
import 'notificador_cambios.dart';

/// Estado y lógica de la pestaña Shortcuts: carga, búsqueda, filtro por
/// categoría, favoritos y alta/baja. La UI (ShortcutsScreen) solo lee estos
/// Rx y llama a estos métodos; ya no habla con el repositorio directamente.
class ShortcutsController extends GetxController {
  final ShortcutRepositorio _repositorio;

  ShortcutsController({ShortcutRepositorio? repositorio})
    : _repositorio = repositorio ?? ShortcutRepositorioImpl();

  final RxList<ModeloShortcut> shortcuts = <ModeloShortcut>[].obs;
  final RxBool cargando = true.obs;
  final RxString filtroCategoria = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    cargar();
  }

  Future<void> cargar() async {
    cargando.value = true;
    shortcuts.assignAll(await _repositorio.listar());
    cargando.value = false;
    await avisarCambioDeDatos();
  }

  List<ModeloShortcut> get filtrados {
    final q = BusquedaController.instance.texto.value.trim().toLowerCase();
    return shortcuts.where((s) {
      if (filtroCategoria.value != 'all' &&
          s.categoriaShortcut != filtroCategoria.value) {
        return false;
      }
      if (q.isEmpty) return true;
      return s.tituloShortcut.toLowerCase().contains(q) ||
          s.teclasShortcut.toLowerCase().contains(q) ||
          s.etiquetasShortcut.toLowerCase().contains(q);
    }).toList();
  }

  void actualizarFiltroCategoria(String id) => filtroCategoria.value = id;

  Future<void> alternarFavorito(ModeloShortcut shortcut) async {
    shortcut.favoritoShortcut = shortcut.esFavorito ? 0 : 1;
    await _repositorio.actualizar(shortcut);
    await cargar();
  }

  Future<void> eliminar(ModeloShortcut shortcut) async {
    await _repositorio.eliminar(shortcut.pkShortcut!);
    await cargar();
  }

  /// Reinserta un shortcut eliminado (botón DESHACER del SnackBar).
  Future<void> restaurar(ModeloShortcut respaldo) async {
    await _repositorio.crear(respaldo);
    await cargar();
  }
}
