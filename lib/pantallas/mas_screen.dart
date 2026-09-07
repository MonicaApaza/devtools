import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/repositorios/comando_repositorio_impl.dart';
import '../data/repositorios/shortcut_repositorio_impl.dart';
import '../presentacion/controladores/auth_controller.dart';
import '../presentacion/pantallas/comando_detalle_screen.dart';
import '../presentacion/pantallas/shortcut_detalle_screen.dart';
import '../rutas/app_rutas.dart';
import '../theme/theme_controller.dart';

class MasScreen extends StatelessWidget {
  const MasScreen({super.key});

  void _mostrarProximamente(BuildContext context, String seccion) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Próximamente: $seccion')));
  }

  Future<void> _abrirDetalleShortcutDeMuestra() async {
    final lista = await ShortcutRepositorioImpl().listar(
      AuthController.instance.usuarioActual,
    );
    if (lista.isEmpty) {
      Get.snackbar('Sin datos', 'Todavía no hay shortcuts guardados.');
      return;
    }
    Get.to(() => ShortcutDetalleScreen(shortcut: lista.first));
  }

  Future<void> _abrirDetalleComandoDeMuestra() async {
    final lista = await ComandoRepositorioImpl().listar(
      AuthController.instance.usuarioActual,
    );
    if (lista.isEmpty) {
      Get.snackbar('Sin datos', 'Todavía no hay comandos guardados.');
      return;
    }
    Get.to(() => ComandoDetalleScreen(comando: lista.first));
  }

  Future<void> _cerrarSesion() async {
    await AuthController.instance.cerrarSesion();
    Get.offAllNamed(AppRutas.login);
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
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
          child: AnimatedBuilder(
            animation: ThemeController.instance,
            builder: (context, _) {
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
        Text(
          'SECCIONES (PRÓXIMAMENTE)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: esquema.outline,
            letterSpacing: 1,
          ),
        ),
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
        Text(
          'GENERAL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: esquema.outline,
            letterSpacing: 1,
          ),
        ),
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
                leading: const Icon(Icons.category_outlined),
                title: const Text('Categorías'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/categorias'),
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
        const SizedBox(height: 20),
        Text(
          'VER TODAS LAS PANTALLAS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: esquema.outline,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.login_outlined),
                title: const Text('Login'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Get.toNamed(AppRutas.login),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.keyboard_outlined),
                title: const Text('Detalle de shortcut (muestra)'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _abrirDetalleShortcutDeMuestra,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.terminal),
                title: const Text('Detalle de comando (muestra)'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _abrirDetalleComandoDeMuestra,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: Icon(Icons.logout, color: esquema.error),
            title: Text(
              'Cerrar sesión',
              style: TextStyle(color: esquema.error),
            ),
            onTap: _cerrarSesion,
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
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: esquema.outline,
          letterSpacing: .5,
        ),
      ),
    );
  }
}
