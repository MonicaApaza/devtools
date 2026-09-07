import 'package:get/get.dart';

import '../../data/modelos/modelo_comando.dart';
import '../../data/repositorios/comando_repositorio_impl.dart';
import '../../dominio/repositorios/comando_repositorio.dart';
import 'auth_controller.dart';
import 'busqueda_controller.dart';
import 'notificador_cambios.dart';

/// Estado y lógica de la pestaña Comandos: carga, búsqueda, filtro por
/// categoría, favoritos, contador de usos y alta/baja. La UI (ComandosScreen)
/// solo lee estos Rx y llama a estos métodos.
class ComandosController extends GetxController {
  final ComandoRepositorio _repositorio;

  ComandosController({ComandoRepositorio? repositorio})
    : _repositorio = repositorio ?? ComandoRepositorioImpl();

  final RxList<ModeloComando> comandos = <ModeloComando>[].obs;
  final RxBool cargando = true.obs;
  final RxString filtroCategoria = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    cargar();
  }

  Future<void> cargar() async {
    cargando.value = true;
    comandos.assignAll(
      await _repositorio.listar(AuthController.instance.usuarioActual),
    );
    cargando.value = false;
    await avisarCambioDeDatos();
  }

  List<ModeloComando> get filtrados {
    final q = BusquedaController.instance.texto.value.trim().toLowerCase();
    return comandos.where((c) {
      if (filtroCategoria.value != 'all' &&
          c.categoriaComando != filtroCategoria.value) {
        return false;
      }
      if (q.isEmpty) return true;
      return c.tituloComando.toLowerCase().contains(q) ||
          c.textoComando.toLowerCase().contains(q) ||
          c.etiquetasComando.toLowerCase().contains(q);
    }).toList();
  }

  void actualizarFiltroCategoria(String id) => filtroCategoria.value = id;

  Future<void> alternarFavorito(ModeloComando comando) async {
    comando.favoritoComando = comando.esFavorito ? 0 : 1;
    await _repositorio.actualizar(comando);
    await cargar();
  }

  Future<void> incrementarUso(ModeloComando comando) async {
    await _repositorio.incrementarUso(comando.pkComando!);
    comando.usosComando++;
    comandos.refresh();
  }

  Future<void> eliminar(ModeloComando comando) async {
    await _repositorio.eliminar(comando.pkComando!);
    await cargar();
  }

  /// Reinserta un comando eliminado (botón DESHACER del SnackBar).
  Future<void> restaurar(ModeloComando respaldo) async {
    await _repositorio.crear(respaldo);
    await cargar();
  }
}
