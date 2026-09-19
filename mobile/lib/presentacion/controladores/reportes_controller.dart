import 'package:get/get.dart';

import '../../dominio/entidades/modelo_comando.dart';
import '../../dominio/entidades/modelo_shortcut.dart';
import '../../data/repositorios/comando_repositorio_impl.dart';
import '../../data/repositorios/shortcut_repositorio_impl.dart';
import '../../dominio/repositorios/comando_repositorio.dart';
import '../../dominio/repositorios/shortcut_repositorio.dart';
import 'auth_controller.dart';

/// Fila unificada de shortcut o comando, para las listas de "recientes" y
/// "favoritos" que mezclan ambos tipos ordenados por fecha.
class ItemReciente {
  final String titulo;
  final String categoriaId;
  final bool esComando;
  final int creadoEn;
  final bool esFavorito;

  const ItemReciente({
    required this.titulo,
    required this.categoriaId,
    required this.esComando,
    required this.creadoEn,
    required this.esFavorito,
  });
}

/// Estado y lógica de la pantalla Reportes: comandos más usados, altas
/// recientes y favoritos, calculados sobre los shortcuts/comandos actuales.
class ReportesController extends GetxController {
  final ShortcutRepositorio _shortcutRepositorio;
  final ComandoRepositorio _comandoRepositorio;

  ReportesController({
    ShortcutRepositorio? shortcutRepositorio,
    ComandoRepositorio? comandoRepositorio,
  }) : _shortcutRepositorio = shortcutRepositorio ?? ShortcutRepositorioImpl(),
       _comandoRepositorio = comandoRepositorio ?? ComandoRepositorioImpl();

  final RxList<ModeloShortcut> _shortcuts = <ModeloShortcut>[].obs;
  final RxList<ModeloComando> _comandos = <ModeloComando>[].obs;
  final RxBool cargando = true.obs;

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
    // Ambas peticiones se lanzan antes de esperar cualquiera, para que
    // corran en paralelo en vez de una tras otra.
    final futureShortcuts = _shortcutRepositorio.listar();
    final futureComandos = _comandoRepositorio.listar();
    _shortcuts.assignAll(await futureShortcuts);
    _comandos.assignAll(await futureComandos);
    cargando.value = false;
  }

  List<ModeloComando> get comandosMasUsados {
    final lista = _comandos.where((c) => c.usosComando > 0).toList()
      ..sort((a, b) => b.usosComando.compareTo(a.usosComando));
    return lista.take(5).toList();
  }

  List<ItemReciente> get _unificados => [
    ..._shortcuts.map(
      (s) => ItemReciente(
        titulo: s.tituloShortcut,
        categoriaId: s.categoriaShortcut,
        esComando: false,
        creadoEn: s.creadoEnShortcut,
        esFavorito: s.esFavorito,
      ),
    ),
    ..._comandos.map(
      (c) => ItemReciente(
        titulo: c.tituloComando,
        categoriaId: c.categoriaComando,
        esComando: true,
        creadoEn: c.creadoEnComando,
        esFavorito: c.esFavorito,
      ),
    ),
  ]..sort((a, b) => b.creadoEn.compareTo(a.creadoEn));

  List<ItemReciente> get agregadosRecientemente => _unificados.take(8).toList();

  List<ItemReciente> get favoritos =>
      _unificados.where((i) => i.esFavorito).toList();
}
