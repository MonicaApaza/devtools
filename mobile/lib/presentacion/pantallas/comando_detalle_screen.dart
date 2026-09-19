import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../dominio/entidades/modelo_comando.dart';
import '../controladores/categorias_controller.dart';
import '../controladores/comandos_controller.dart';

/// Pantalla de detalle a pantalla completa, con Hero desde la card del
/// grid de ComandosScreen — mismo patrón CardProducto -> Elegido de
/// get_api_grid_ok (sesión 7).
class ComandoDetalleScreen extends StatelessWidget {
  final ModeloComando comando;

  const ComandoDetalleScreen({super.key, required this.comando});

  Future<void> _copiar() async {
    await Clipboard.setData(ClipboardData(text: comando.textoComando));
    if (Get.isRegistered<ComandosController>()) {
      await Get.find<ComandosController>().incrementarUso(comando);
    }
    Get.snackbar(
      'Copiado',
      'Comando copiado al portapapeles',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final categoria = CategoriasController.instance.buscarCategoriaComando(
      comando.categoriaComando,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del comando')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Hero(
              tag: 'comando-${comando.pkComando}',
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
            comando.tituloComando,
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: r'$ ',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'monospace',
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: comando.textoComando,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _copiar,
            icon: const Icon(Icons.copy),
            label: const Text('Copiar comando'),
          ),
          if (comando.descripcionComando.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text('Descripción', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(comando.descripcionComando),
          ],
          if (comando.etiquetas.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Etiquetas', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: comando.etiquetas.map((t) => Chip(label: Text(t))).toList(),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              if (comando.esFavorito) ...[
                Icon(Icons.star, color: Colors.amber.shade700, size: 20),
                const SizedBox(width: 6),
                const Text('Favorito'),
                const SizedBox(width: 20),
              ],
              Icon(Icons.repeat, size: 18, color: esquema.outline),
              const SizedBox(width: 6),
              Text(
                comando.usosComando == 1
                    ? 'Copiado 1 vez'
                    : 'Copiado ${comando.usosComando} veces',
                style: TextStyle(color: esquema.outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
