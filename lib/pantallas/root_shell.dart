import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';
import 'comandos_screen.dart';
import 'home_screen.dart';
import 'mas_screen.dart';
import 'shortcuts_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _indice = 0;
  bool _vistaGridShortcuts = false;
  bool _vistaGridComandos = false;

  final _homeKey = GlobalKey<HomeScreenState>();
  final _shortcutsKey = GlobalKey<ShortcutsScreenState>();
  final _comandosKey = GlobalKey<ComandosScreenState>();

  static const _titulos = ['Inicio', 'Shortcuts', 'Comandos', 'Más'];

  void _irA(int indice) {
    setState(() => _indice = indice);
  }

  Future<void> _presionarFab() async {
    // En Inicio y Más no hay una lista propia que agregar, así que por
    // defecto se ofrece un nuevo shortcut (igual que en el diseño).
    if (_indice == 2) {
      await _comandosKey.currentState?.mostrarFormularioNuevo();
    } else {
      await _shortcutsKey.currentState?.mostrarFormularioNuevo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_indice]),
        actions: [
          if (_indice == 1)
            IconButton(
              icon: Icon(_vistaGridShortcuts ? Icons.view_list : Icons.grid_view),
              tooltip: _vistaGridShortcuts ? 'Ver como lista' : 'Ver como cuadrícula',
              onPressed: () => setState(() => _vistaGridShortcuts = !_vistaGridShortcuts),
            ),
          if (_indice == 2)
            IconButton(
              icon: Icon(_vistaGridComandos ? Icons.view_list : Icons.grid_view),
              tooltip: _vistaGridComandos ? 'Ver como lista' : 'Ver como cuadrícula',
              onPressed: () => setState(() => _vistaGridComandos = !_vistaGridComandos),
            ),
        ],
      ),
      drawer: AppDrawer(indiceActual: _indice, onSeleccionar: _irA),
      body: IndexedStack(
        index: _indice,
        children: [
          HomeScreen(key: _homeKey, onNavegar: _irA),
          ShortcutsScreen(
            key: _shortcutsKey,
            vistaGrid: _vistaGridShortcuts,
          ),
          ComandosScreen(
            key: _comandosKey,
            vistaGrid: _vistaGridComandos,
          ),
          const MasScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _presionarFab,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BotonNav(icono: Icons.home_outlined, etiqueta: 'Inicio', activo: _indice == 0, onTap: () => _irA(0)),
            _BotonNav(icono: Icons.keyboard_outlined, etiqueta: 'Shortcuts', activo: _indice == 1, onTap: () => _irA(1)),
            const SizedBox(width: 40),
            _BotonNav(icono: Icons.terminal, etiqueta: 'Comandos', activo: _indice == 2, onTap: () => _irA(2)),
            _BotonNav(icono: Icons.more_horiz, etiqueta: 'Más', activo: _indice == 3, onTap: () => _irA(3)),
          ],
        ),
      ),
    );
  }
}

class _BotonNav extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final bool activo;
  final VoidCallback onTap;

  const _BotonNav({
    required this.icono,
    required this.etiqueta,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final color = activo ? esquema.primary : esquema.outline;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: activo ? 1.1 : 1.0,
              child: Icon(icono, color: color, size: 22),
            ),
            const SizedBox(height: 2),
            Text(
              etiqueta,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: activo ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
