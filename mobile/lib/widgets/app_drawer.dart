import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../presentacion/controladores/auth_controller.dart';
import '../rutas/app_rutas.dart';
import '../theme/theme_controller.dart';

/// Drawer lateral: navegación alternativa a la barra inferior.
class AppDrawer extends StatelessWidget {
  final int indiceActual;
  final ValueChanged<int> onSeleccionar;

  const AppDrawer({
    super.key,
    required this.indiceActual,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    Widget item({
      required int indice,
      required IconData icono,
      required String titulo,
    }) {
      final activo = indice == indiceActual;
      return ListTile(
        leading: Icon(icono, color: activo ? esquema.primary : null),
        title: Text(
          titulo,
          style: TextStyle(
            fontWeight: activo ? FontWeight.bold : FontWeight.normal,
            color: activo ? esquema.primary : null,
          ),
        ),
        selected: activo,
        selectedTileColor: esquema.primaryContainer.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          Navigator.pop(context);
          onSeleccionar(indice);
        },
      );
    }

    Future<void> cerrarSesion() async {
      Navigator.pop(context);
      await AuthController.instance.cerrarSesion();
      Get.offAllNamed(AppRutas.login);
    }

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [esquema.primary, esquema.primaryContainer],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Hero(
                    tag: 'app-icon',
                    child: CircleAvatar(
                      backgroundColor: esquema.onPrimary,
                      child: Icon(Icons.bolt, color: esquema.primary),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'QuickDev',
                    style: TextStyle(
                      color: esquema.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tu referencia rápida',
                    style: TextStyle(
                      color: esquema.onPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            item(indice: 0, icono: Icons.home_outlined, titulo: 'Inicio'),
            item(
              indice: 1,
              icono: Icons.keyboard_outlined,
              titulo: 'Shortcuts',
            ),
            item(indice: 2, icono: Icons.terminal, titulo: 'Comandos'),
            item(indice: 3, icono: Icons.more_horiz, titulo: 'Más'),
            const Divider(),
            ListTile(
              leading: const Hero(
                tag: 'icon-estadisticas',
                child: Icon(Icons.bar_chart_outlined),
              ),
              title: const Text('Estadísticas'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/estadisticas');
              },
            ),
            ListTile(
              leading: const Hero(
                tag: 'icon-categorias',
                child: Icon(Icons.category_outlined),
              ),
              title: const Text('Categorías'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/categorias');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Ajustes y acerca de'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/ajustes');
              },
            ),
            AnimatedBuilder(
              animation: ThemeController.instance,
              builder: (context, _) {
                final controlador = ThemeController.instance;
                return SwitchListTile(
                  secondary: Icon(
                    controlador.esOscuro
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                  ),
                  title: const Text('Tema oscuro'),
                  value: controlador.esOscuro,
                  onChanged: (_) => controlador.alternar(),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: esquema.error),
              title: Text(
                'Cerrar sesión',
                style: TextStyle(color: esquema.error),
              ),
              onTap: cerrarSesion,
            ),
          ],
        ),
      ),
    );
  }
}
