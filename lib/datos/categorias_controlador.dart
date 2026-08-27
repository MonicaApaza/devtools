import 'package:flutter/material.dart';

import '../helpers/db_helper.dart';
import 'categorias.dart';

/// Caché en memoria de las categorías (de shortcuts y de comandos), cargada
/// desde la base de datos. Mismo patrón que ThemeController/CambiosDatos:
/// singleton + ChangeNotifier, para que cualquier pantalla se refresque
/// cuando se crea, edita o elimina una categoría en CategoriasScreen.
class CategoriasController extends ChangeNotifier {
  CategoriasController._internal();
  static final CategoriasController instance = CategoriasController._internal();
  factory CategoriasController() => instance;

  final _dbHelper = DatabaseHelper();

  List<Categoria> _shortcuts = [];
  List<Categoria> _comandos = [];

  List<Categoria> get categoriasShortcut => _shortcuts;
  List<Categoria> get categoriasComando => _comandos;

  Future<void> cargar() async {
    _shortcuts = await _dbHelper.getCategorias('shortcut');
    _comandos = await _dbHelper.getCategorias('comando');
    notifyListeners();
  }

  Categoria buscarCategoriaShortcut(String id) => _buscar(_shortcuts, id);

  Categoria buscarCategoriaComando(String id) => _buscar(_comandos, id);

  Categoria _buscar(List<Categoria> lista, String id) {
    return lista.firstWhere(
      (c) => c.id == id,
      orElse: () => lista.isNotEmpty
          ? lista.first
          : const Categoria(id: '', nombre: 'Sin categoría', icono: Icons.category_outlined),
    );
  }
}
