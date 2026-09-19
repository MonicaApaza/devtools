import 'package:get/get.dart';

import '../../dominio/entidades/modelo_shortcut.dart';
import '../../data/repositorios/shortcut_repositorio_impl.dart';
import '../../dominio/repositorios/shortcut_repositorio.dart';
import 'auth_controller.dart';
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
    // Evita disparar peticiones autenticadas cuando este cargar() se activa
    // por el bump de versión que CategoriasController emite al cerrar
    // sesión: para ese momento ya no hay token y el backend respondería 401.
    if (!AuthController.instance.estaAutenticado) return;
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
    await _repositorio.alternarFavorito(
      shortcut.pkShortcut!,
      !shortcut.esFavorito,
    );
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
