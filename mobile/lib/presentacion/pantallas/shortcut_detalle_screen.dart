import 'package:flutter/material.dart';

import '../../data/modelos/modelo_shortcut.dart';
import '../controladores/categorias_controller.dart';
import '../widgets/fila_teclas.dart';

/// Pantalla de detalle a pantalla completa, con Hero desde la card del
/// grid de ShortcutsScreen — mismo patrón CardProducto -> Elegido de
/// get_api_grid_ok (sesión 7).
class ShortcutDetalleScreen extends StatelessWidget {
  final ModeloShortcut shortcut;

  const ShortcutDetalleScreen({super.key, required this.shortcut});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final categoria = CategoriasController.instance.buscarCategoriaShortcut(
      shortcut.categoriaShortcut,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del shortcut')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Hero(
              tag: 'shortcut-${shortcut.pkShortcut}',
              child: CircleAvatar(
                radius: 44,
                backgroundColor: esquema.primaryContainer,
                child: Icon(
                  categoria.icono,
                  size: 40,
                  color: esquema.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            shortcut.tituloShortcut,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(categoria.nombre, style: TextStyle(color: esquema.outline)),
          ),
          const SizedBox(height: 24),
          Center(child: FilaTeclas(teclas: shortcut.teclas, grande: true)),
          if (shortcut.descripcionShortcut.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text('Descripción', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(shortcut.descripcionShortcut),
          ],
          if (shortcut.etiquetas.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Etiquetas', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: shortcut.etiquetas
                  .map((t) => Chip(label: Text(t)))
                  .toList(),
            ),
          ],
          if (shortcut.esFavorito) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber.shade700, size: 20),
                const SizedBox(width: 8),
                const Text('Marcado como favorito'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
