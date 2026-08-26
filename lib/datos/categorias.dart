import 'package:flutter/material.dart';

class Categoria {
  final String id;
  final String nombre;
  final IconData icono;

  const Categoria({required this.id, required this.nombre, required this.icono});
}

const List<Categoria> categoriasShortcut = [
  Categoria(id: 'vscode', nombre: 'VS Code', icono: Icons.code),
  Categoria(id: 'android', nombre: 'Android Studio', icono: Icons.developer_mode),
  Categoria(id: 'intellij', nombre: 'IntelliJ', icono: Icons.diamond_outlined),
  Categoria(id: 'git', nombre: 'Git', icono: Icons.account_tree_outlined),
  Categoria(id: 'terminal', nombre: 'Terminal', icono: Icons.terminal),
  Categoria(id: 'browser', nombre: 'Navegador', icono: Icons.public),
  Categoria(id: 'flutter', nombre: 'Flutter', icono: Icons.smartphone),
];

const List<Categoria> categoriasComando = [
  Categoria(id: 'git', nombre: 'Git', icono: Icons.account_tree_outlined),
  Categoria(id: 'flutter', nombre: 'Flutter', icono: Icons.smartphone),
  Categoria(id: 'terminal', nombre: 'Terminal', icono: Icons.terminal),
  Categoria(id: 'pub', nombre: 'Pub', icono: Icons.inventory_2_outlined),
];

Categoria buscarCategoriaShortcut(String id) {
  return categoriasShortcut.firstWhere(
    (c) => c.id == id,
    orElse: () => categoriasShortcut.first,
  );
}

Categoria buscarCategoriaComando(String id) {
  return categoriasComando.firstWhere(
    (c) => c.id == id,
    orElse: () => categoriasComando.first,
  );
}
