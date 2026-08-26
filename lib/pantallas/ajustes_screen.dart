import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart';

import '../theme/theme_controller.dart';

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
                CircleAvatar(
                  radius: 22,
                  backgroundColor: esquema.primary,
                  child: Icon(Icons.bolt, color: esquema.onPrimary),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('QuickDev', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Versión 1.0.0'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('APARIENCIA', style: TextStyle(fontWeight: FontWeight.bold, color: esquema.outline, letterSpacing: 1)),
          const SizedBox(height: 8),
          Card(
            child: AnimatedBuilder(
              animation: ThemeController.instance,
              builder: (context, _) {
                final controlador = ThemeController.instance;
                return SwitchListTile(
                  secondary: Icon(controlador.esOscuro ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
                  title: Text('Tema ${controlador.esOscuro ? "oscuro" : "claro"}'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Conceptos de Flutter aplicados', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const _ConceptoItem(
                  titulo: 'Navegación',
                  detalle: 'Barra inferior, Drawer lateral y rutas nombradas (/ajustes).',
                ),
                const _ConceptoItem(
                  titulo: 'Gestos',
                  detalle: 'Deslizar para eliminar (Dismissible), mantener presionado (long-press) y tocar para expandir.',
                ),
                const _ConceptoItem(
                  titulo: 'Temas',
                  detalle: 'ColorScheme.fromSeed con modo claro/oscuro global.',
                ),
                const _ConceptoItem(
                  titulo: 'ListView y GridView',
                  detalle: 'Listas y cuadrícula con alternador de vista.',
                ),
                const _ConceptoItem(
                  titulo: 'Diseño con curvas',
                  detalle: 'BottomAppBar con muesca circular para el FAB y esquinas redondeadas.',
                ),
                const _ConceptoItem(
                  titulo: 'Animaciones',
                  detalle: 'AnimatedSize para el acordeón y transiciones del Material implícitas.',
                ),
                const _ConceptoItem(
                  titulo: 'Formularios',
                  detalle: 'Form + TextFormField + validator para altas y ediciones.',
                ),
                _ConceptoItem(
                  titulo: 'Persistencia local',
                  detalle: 'SQLite (sqflite) — ${kDebugMode ? 'modo debug' : 'modo release'}.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(const ClipboardData(text: 'QuickDev v1.0.0'));
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                    const SnackBar(content: Text('Copiado')),
                  );
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

class _ConceptoItem extends StatelessWidget {
  final String titulo;
  final String detalle;
  const _ConceptoItem({required this.titulo, required this.detalle});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 9,
            backgroundColor: esquema.primary,
            child: Icon(Icons.check, size: 12, color: esquema.onPrimary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style.copyWith(fontSize: 12.5, color: esquema.outline),
                children: [
                  TextSpan(text: '$titulo: ', style: TextStyle(fontWeight: FontWeight.bold, color: esquema.onSurface)),
                  TextSpan(text: detalle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
