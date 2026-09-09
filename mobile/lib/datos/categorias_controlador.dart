import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/datos_estaticos/categorias.dart';
import '../data/repositorios/categoria_repositorio_impl.dart';
import '../dominio/repositorios/categoria_repositorio.dart';
import '../presentacion/controladores/auth_controller.dart';

/// Caché en memoria de las categorías (de shortcuts y de comandos), cargada
/// desde la base de datos a través de CategoriaRepositorio. Se registra una
/// sola vez con Get.put(permanent: true) en main(); sus listas son
/// observables (.obs) para que cualquier pantalla reaccione a cambios con
/// Obx, o con `ever()` mientras esa pantalla siga sin ser un GetxController.
class CategoriasController extends GetxController {
  final CategoriaRepositorio _repositorio;

  CategoriasController({CategoriaRepositorio? repositorio})
    : _repositorio = repositorio ?? CategoriaRepositorioImpl();

  static CategoriasController get instance => Get.find<CategoriasController>();

  final RxList<Categoria> categoriasShortcut = <Categoria>[].obs;
  final RxList<Categoria> categoriasComando = <Categoria>[].obs;
  final RxInt version = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // A diferencia de los demás controladores (que se recrean al hacer
    // login/logout junto con RootShell), este vive desde antes del primer
    // login (permanent: true en main()), así que necesita recargar solo
    // cuando cambia la sesión.
    ever(AuthController.instance.sesion, (_) => cargar());
  }

  Future<void> cargar() async {
    if (!AuthController.instance.estaAutenticado) {
      categoriasShortcut.clear();
      categoriasComando.clear();
      version.value++;
      return;
    }
    categoriasShortcut.assignAll(await _repositorio.listar('shortcut'));
    categoriasComando.assignAll(await _repositorio.listar('comando'));
    version.value++;
  }

  Categoria buscarCategoriaShortcut(String id) =>
      _buscar(categoriasShortcut, id);

  Categoria buscarCategoriaComando(String id) => _buscar(categoriasComando, id);

  Categoria _buscar(List<Categoria> lista, String id) {
    return lista.firstWhere(
      (c) => c.id == id,
      orElse: () => lista.isNotEmpty
          ? lista.first
          : const Categoria(
              id: '',
              nombre: 'Sin categoría',
              icono: Icons.category_outlined,
            ),
    );
  }
}
