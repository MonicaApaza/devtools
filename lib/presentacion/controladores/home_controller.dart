import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/repositorios/comando_repositorio_impl.dart';
import '../../data/repositorios/shortcut_repositorio_impl.dart';
import '../../datos/categorias_controlador.dart';
import '../../dominio/repositorios/comando_repositorio.dart';
import '../../dominio/repositorios/shortcut_repositorio.dart';
import 'auth_controller.dart';
import 'busqueda_controller.dart';

class ItemReciente {
  final String titulo;
  final String meta;
  final IconData icono;
  final int creadoEn;
  final int destino; // 1 = shortcuts, 2 = comandos
  final bool favorito;
  final String categoriaId;
  ItemReciente(
    this.titulo,
    this.meta,
    this.icono,
    this.creadoEn,
    this.destino,
    this.favorito,
    this.categoriaId,
  );
}

class CategoriaFiltro {
  final String id;
  final String nombre;
  const CategoriaFiltro(this.id, this.nombre);
}

/// Estado y lógica de la pestaña Inicio: combina shortcuts y comandos en
/// una sola lista reciente/favoritos, con búsqueda y filtro por categoría.
class HomeController extends GetxController {
  final ShortcutRepositorio _shortcutRepositorio;
  final ComandoRepositorio _comandoRepositorio;

  HomeController({
    ShortcutRepositorio? shortcutRepositorio,
    ComandoRepositorio? comandoRepositorio,
  }) : _shortcutRepositorio = shortcutRepositorio ?? ShortcutRepositorioImpl(),
       _comandoRepositorio = comandoRepositorio ?? ComandoRepositorioImpl();

  final RxList<ItemReciente> todos = <ItemReciente>[].obs;
  final RxBool cargando = true.obs;
  final RxString filtroCategoria = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    cargar();
  }

  Future<void> cargar() async {
    final usuario = AuthController.instance.usuarioActual;
    final shortcuts = await _shortcutRepositorio.listar(usuario);
    final comandos = await _comandoRepositorio.listar(usuario);

    final items = <ItemReciente>[
      ...shortcuts.map(
        (s) => ItemReciente(
          s.tituloShortcut,
          s.teclas.join(' + '),
          CategoriasController.instance
              .buscarCategoriaShortcut(s.categoriaShortcut)
              .icono,
          s.creadoEnShortcut,
          1,
          s.esFavorito,
          s.categoriaShortcut,
        ),
      ),
      ...comandos.map(
        (c) => ItemReciente(
          c.tituloComando,
          c.textoComando,
          CategoriasController.instance
              .buscarCategoriaComando(c.categoriaComando)
              .icono,
          c.creadoEnComando,
          2,
          c.esFavorito,
          c.categoriaComando,
        ),
      ),
    ];
    items.sort((a, b) => b.creadoEn.compareTo(a.creadoEn));

    todos.assignAll(items);
    cargando.value = false;
  }

  List<ItemReciente> get itemsFiltrados {
    if (filtroCategoria.value == 'all') return todos;
    return todos.where((i) => i.categoriaId == filtroCategoria.value).toList();
  }

  List<ItemReciente> get favoritos =>
      itemsFiltrados.where((i) => i.favorito).toList();

  List<ItemReciente> get recientes => itemsFiltrados.take(5).toList();

  List<ItemReciente> get resultadosBusqueda {
    final q = BusquedaController.instance.texto.value.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return itemsFiltrados
        .where(
          (i) =>
              i.titulo.toLowerCase().contains(q) ||
              i.meta.toLowerCase().contains(q),
        )
        .toList();
  }

  // Unión de las categorías de shortcuts y comandos (sin duplicados), para
  // poder filtrar ambos tipos de elementos con un solo set de chips.
  List<CategoriaFiltro> get categoriasFiltro {
    final controlador = CategoriasController.instance;
    final vistas = <String>{};
    final resultado = <CategoriaFiltro>[];
    for (final cat in [
      ...controlador.categoriasShortcut,
      ...controlador.categoriasComando,
    ]) {
      if (vistas.add(cat.id)) {
        resultado.add(CategoriaFiltro(cat.id, cat.nombre));
      }
    }
    return resultado;
  }

  void actualizarFiltroCategoria(String id) => filtroCategoria.value = id;
}
