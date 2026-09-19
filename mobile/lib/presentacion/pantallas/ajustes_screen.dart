import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../theme/theme_controller.dart';

/// Pantalla de detalle a la que se llega mediante una ruta nombrada
/// (Navigator.pushNamed(context, '/ajustes')), tal como se explicó en la
/// sesión de "Rutas Nombradas".
class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes y acerca de')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: esquema.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'app-icon',
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: esquema.primary,
                    child: Icon(Icons.bolt, color: esquema.onPrimary),
                  ),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QuickDev',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text('Versión 1.0.0'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'APARIENCIA',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: esquema.outline,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Obx(
              () {
                final controlador = ThemeController.instance;
                return SwitchListTile(
                  secondary: Icon(
                    controlador.esOscuro
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                  ),
                  title: Text(
                    'Tema ${controlador.esOscuro ? "oscuro" : "claro"}',
                  ),
                  value: controlador.esOscuro,
                  onChanged: (_) => controlador.alternar(),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: esquema.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(
                  const ClipboardData(text: 'QuickDev v1.0.0'),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(const SnackBar(content: Text('Copiado')));
                }
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copiar versión'),
            ),
          ),
        ],
      ),
    );
  }
}
