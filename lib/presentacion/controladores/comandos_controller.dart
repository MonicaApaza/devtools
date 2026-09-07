import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/modelos/modelo_comando.dart';
import '../../data/repositorios/comando_repositorio_impl.dart';
import '../../datos/cambios_datos.dart';
import '../../dominio/repositorios/comando_repositorio.dart';

/// Estado y lógica de la pestaña Comandos: carga, búsqueda, filtro por
/// categoría, favoritos, contador de usos y alta/baja. La UI (ComandosScreen)
/// solo lee estos Rx y llama a estos métodos.
class ComandosController extends GetxController {
  final ComandoRepositorio _repositorio;

  ComandosController({ComandoRepositorio? repositorio})
    : _repositorio = repositorio ?? ComandoRepositorioImpl();

  final busquedaController = TextEditingController();

  final RxList<ModeloComando> comandos = <ModeloComando>[].obs;
  final RxBool cargando = true.obs;
  final RxString busqueda = ''.obs;
  final RxString filtroCategoria = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    cargar();
  }

  @override
  void onClose() {
    busquedaController.dispose();
    super.onClose();
  }

  Future<void> cargar() async {
    cargando.value = true;
    comandos.assignAll(await _repositorio.listar());
    cargando.value = false;
    CambiosDatos.instance.avisar();
  }

  List<ModeloComando> get filtrados {
    final q = busqueda.value.trim().toLowerCase();
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

  void actualizarBusqueda(String valor) => busqueda.value = valor;

  void limpiarBusqueda() {
    busqueda.value = '';
    busquedaController.clear();
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
