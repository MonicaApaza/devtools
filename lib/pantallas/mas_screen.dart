import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';

class MasScreen extends StatelessWidget {
  const MasScreen({super.key});

  void _mostrarProximamente(BuildContext context, String seccion) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
      SnackBar(content: Text('Próximamente: $seccion')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
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
        Text('SECCIONES (PRÓXIMAMENTE)', style: TextStyle(fontWeight: FontWeight.bold, color: esquema.outline, letterSpacing: 1)),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.edit_note_outlined),
                title: const Text('Notas rápidas'),
                trailing: const _PillProximamente(),
                onTap: () => _mostrarProximamente(context, 'Notas rápidas'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.link_outlined),
                title: const Text('Enlaces útiles'),
                trailing: const _PillProximamente(),
                onTap: () => _mostrarProximamente(context, 'Enlaces útiles'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Contraseñas'),
                trailing: const _PillProximamente(),
                onTap: () => _mostrarProximamente(context, 'Contraseñas'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('GENERAL', style: TextStyle(fontWeight: FontWeight.bold, color: esquema.outline, letterSpacing: 1)),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.bar_chart_outlined),
                title: const Text('Estadísticas'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/estadisticas'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Ajustes y acerca de'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/ajustes'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PillProximamente extends StatelessWidget {
  const _PillProximamente();

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: esquema.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        'PRONTO',
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: esquema.outline, letterSpacing: .5),
      ),
    );
  }
}
