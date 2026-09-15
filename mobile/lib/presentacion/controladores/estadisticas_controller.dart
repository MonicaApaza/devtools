import 'package:get/get.dart';

import '../../data/modelos/modelo_comando.dart';
import '../../data/modelos/modelo_shortcut.dart';
import '../../data/repositorios/comando_repositorio_impl.dart';
import '../../data/repositorios/shortcut_repositorio_impl.dart';
import '../../dominio/repositorios/comando_repositorio.dart';
import '../../dominio/repositorios/shortcut_repositorio.dart';

/// Estado y lógica de la pantalla Estadísticas: totales, favoritos y
/// conteo por categoría, calculados sobre los shortcuts/comandos actuales.
class EstadisticasController extends GetxController {
  final ShortcutRepositorio _shortcutRepositorio;
  final ComandoRepositorio _comandoRepositorio;

  EstadisticasController({
    ShortcutRepositorio? shortcutRepositorio,
    ComandoRepositorio? comandoRepositorio,
  }) : _shortcutRepositorio = shortcutRepositorio ?? ShortcutRepositorioImpl(),
       _comandoRepositorio = comandoRepositorio ?? ComandoRepositorioImpl();

  final RxList<ModeloShortcut> shortcuts = <ModeloShortcut>[].obs;
  final RxList<ModeloComando> comandos = <ModeloComando>[].obs;
  final RxBool cargando = true.obs;

  @override
  void onInit() {
    super.onInit();
    cargar();
  }

  Future<void> cargar() async {
    shortcuts.assignAll(await _shortcutRepositorio.listar());
    comandos.assignAll(await _comandoRepositorio.listar());
    cargando.value = false;
  }

  int get favoritos =>
      shortcuts.where((s) => s.esFavorito).length +
      comandos.where((c) => c.esFavorito).length;

  Map<String, int> contarPorCategoria(Iterable<String> categoriasDeItems) {
    final conteo = <String, int>{};
    for (final id in categoriasDeItems) {
      conteo[id] = (conteo[id] ?? 0) + 1;
    }
    return conteo;
  }
}
