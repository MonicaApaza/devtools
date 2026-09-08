import 'package:flutter/material.dart';

class Categoria {
  final String id;
  final String nombre;
  final IconData icono;

  const Categoria({required this.id, required this.nombre, required this.icono});
}

// Catálogo fijo de íconos seleccionables al crear/editar una categoría.
// Se guarda la clave (String) en la base de datos en vez del IconData: así
// el "tree shaker" de íconos de Flutter puede seguir viendo referencias
// const directas a Icons.* y no falla en los builds de release.
const Map<String, IconData> iconosCategoria = {
  'code': Icons.code,
  'developer_mode': Icons.developer_mode,
  'diamond': Icons.diamond_outlined,
  'git': Icons.account_tree_outlined,
  'terminal': Icons.terminal,
  'browser': Icons.public,
  'flutter': Icons.smartphone,
  'pub': Icons.inventory_2_outlined,
  'star': Icons.star_outline,
  'bug': Icons.bug_report_outlined,
  'cloud': Icons.cloud_outlined,
  'settings': Icons.settings_outlined,
  'extension': Icons.extension_outlined,
  'build': Icons.build_outlined,
  'folder': Icons.folder_outlined,
  'category': Icons.category_outlined,
};

IconData iconoPorClave(String clave) =>
    iconosCategoria[clave] ?? Icons.category_outlined;
