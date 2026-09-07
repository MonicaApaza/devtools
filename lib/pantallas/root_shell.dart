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

  // No es un Hero (cambiar de pestaña no es una navegación de rutas, así
  // que Hero no puede animar ahí): es un fundido rápido de
  // salida-cambio-entrada alrededor del IndexedStack para suavizar el
  // cambio, sin destruir ni recrear ninguna pantalla (los GlobalKey y el
  // estado de cada tab se conservan igual que antes).
  bool _visible = true;
  static const _duracionFundido = Duration(milliseconds: 150);

  final _homeKey = GlobalKey<HomeScreenState>();
  final _shortcutsKey = GlobalKey<ShortcutsScreenState>();
  final _comandosKey = GlobalKey<ComandosScreenState>();

  static const _titulos = ['Inicio', 'Shortcuts', 'Comandos', 'Más'];

  Future<void> _irA(int indice) async {
    if (indice == _indice) return;
    setState(() => _visible = false);
    await Future.delayed(_duracionFundido);
    if (!mounted) return;
    setState(() {
      _indice = indice;
      _visible = true;
    });
  }

  Future<void> _presionarFab() async {
    if (_indice == 1) {
      await _shortcutsKey.currentState?.mostrarFormularioNuevo();
      return;
    }
    if (_indice == 2) {
      await _comandosKey.currentState?.mostrarFormularioNuevo();
      return;
    }
    // En Inicio y Más no hay una lista propia que agregar, así que se
    // pregunta primero qué se quiere crear.
    final tipo = await _elegirTipoNuevo();
    if (tipo == 1) {
      await _shortcutsKey.currentState?.mostrarFormularioNuevo();
    } else if (tipo == 2) {
      await _comandosKey.currentState?.mostrarFormularioNuevo();
    }
  }

  Future<int?> _elegirTipoNuevo() {
    return showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '¿Qué deseas crear?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.keyboard_outlined),
              title: const Text('Shortcut'),
              onTap: () => Navigator.of(context).pop(1),
            ),
            ListTile(
              leading: const Icon(Icons.terminal),
              title: const Text('Comando'),
              onTap: () => Navigator.of(context).pop(2),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_indice]),
        actions: [
          if (_indice == 1)
            IconButton(
              icon: Icon(
                _vistaGridShortcuts ? Icons.view_list : Icons.grid_view,
              ),
              tooltip: _vistaGridShortcuts
                  ? 'Ver como lista'
                  : 'Ver como cuadrícula',
              onPressed: () =>
                  setState(() => _vistaGridShortcuts = !_vistaGridShortcuts),
            ),
          if (_indice == 2)
            IconButton(
              icon: Icon(
                _vistaGridComandos ? Icons.view_list : Icons.grid_view,
              ),
              tooltip: _vistaGridComandos
                  ? 'Ver como lista'
                  : 'Ver como cuadrícula',
              onPressed: () =>
                  setState(() => _vistaGridComandos = !_vistaGridComandos),
            ),
        ],
      ),
      drawer: AppDrawer(indiceActual: _indice, onSeleccionar: _irA),
      body: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: _duracionFundido,
        child: IndexedStack(
          index: _indice,
          children: [
            HomeScreen(key: _homeKey, onNavegar: _irA),
            ShortcutsScreen(key: _shortcutsKey, vistaGrid: _vistaGridShortcuts),
            ComandosScreen(key: _comandosKey, vistaGrid: _vistaGridComandos),
            const MasScreen(),
          ],
        ),
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
            _BotonNav(
              icono: Icons.home_outlined,
              etiqueta: 'Inicio',
              activo: _indice == 0,
              onTap: () => _irA(0),
            ),
            _BotonNav(
              icono: Icons.keyboard_outlined,
              etiqueta: 'Shortcuts',
              activo: _indice == 1,
              onTap: () => _irA(1),
            ),
            const SizedBox(width: 40),
            _BotonNav(
              icono: Icons.terminal,
              etiqueta: 'Comandos',
              activo: _indice == 2,
              onTap: () => _irA(2),
            ),
            _BotonNav(
              icono: Icons.more_horiz,
              etiqueta: 'Más',
              activo: _indice == 3,
              onTap: () => _irA(3),
            ),
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
