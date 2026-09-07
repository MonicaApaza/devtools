import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../datos/cambios_datos.dart';
import '../datos/categorias_controlador.dart';
import '../data/datasources/db_helper.dart';
import '../data/modelos/modelo_comando.dart';
import '../data/modelos/modelo_shortcut.dart';
import '../theme/theme_controller.dart';
import '../widgets/barra_estadistica.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  final _dbHelper = DatabaseHelper();
  bool _cargando = true;
  List<ModeloShortcut> _shortcuts = [];
  List<ModeloComando> _comandos = [];
  late final Worker _workerCambios;
  late final Worker _workerCategorias;

  @override
  void initState() {
    super.initState();
    _cargar();
    _workerCambios = ever(CambiosDatos.instance.version, (_) => _cargar());
    _workerCategorias = ever(CategoriasController.instance.version, (_) => _cargar());
  }

  @override
  void dispose() {
    _workerCambios.dispose();
    _workerCategorias.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final shortcuts = await _dbHelper.getShortcuts();
    final comandos = await _dbHelper.getComandos();
    if (!mounted) return;
    setState(() {
      _shortcuts = shortcuts;
      _comandos = comandos;
      _cargando = false;
    });
  }

  Map<String, int> _contarPorCategoria(Iterable<String> categoriasDeItems) {
    final conteo = <String, int>{};
    for (final id in categoriasDeItems) {
      conteo[id] = (conteo[id] ?? 0) + 1;
    }
    return conteo;
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final esquema = Theme.of(context).colorScheme;

    final favoritos =
        _shortcuts.where((s) => s.esFavorito).length +
        _comandos.where((c) => c.esFavorito).length;

    final conteoShortcuts = _contarPorCategoria(
      _shortcuts.map((s) => s.categoriaShortcut),
    );
    final conteoComandos = _contarPorCategoria(
      _comandos.map((c) => c.categoriaComando),
    );
    final maxShortcuts = conteoShortcuts.values.isEmpty
        ? 0
        : conteoShortcuts.values.reduce((a, b) => a > b ? a : b);
    final maxComandos = conteoComandos.values.isEmpty
        ? 0
        : conteoComandos.values.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // GridView para las 4 tarjetas resumen (Sesión 4: GridView).
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _TarjetaResumen(
                  icono: Icons.keyboard_outlined,
                  etiqueta: 'Shortcuts',
                  valor: _shortcuts.length,
                  color: colorSemilla,
                ),
                _TarjetaResumen(
                  icono: Icons.terminal,
                  etiqueta: 'Comandos',
                  valor: _comandos.length,
                  color: esquema.tertiary,
                ),
                _TarjetaResumen(
                  icono: Icons.star_outline,
                  etiqueta: 'Favoritos',
                  valor: favoritos,
                  color: Colors.amber.shade700,
                ),
                _TarjetaResumen(
                  icono: Icons.dashboard_outlined,
                  etiqueta: 'Total',
                  valor: _shortcuts.length + _comandos.length,
                  color: esquema.secondary,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'SHORTCUTS POR CATEGORÍA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: esquema.outline,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: _shortcuts.isEmpty
                    ? const Text('Aún no hay shortcuts guardados.')
                    : Column(
                        children: CategoriasController.instance.categoriasShortcut
                            .map(
                              (cat) => BarraEstadistica(
                                icono: cat.icono,
                                etiqueta: cat.nombre,
                                valor: conteoShortcuts[cat.id] ?? 0,
                                valorMaximo: maxShortcuts,
                                color: colorSemilla,
                              ),
                            )
                            .toList(),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'COMANDOS POR CATEGORÍA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: esquema.outline,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: _comandos.isEmpty
                    ? const Text('Aún no hay comandos guardados.')
                    : Column(
                        children: CategoriasController.instance.categoriasComando
                            .map(
                              (cat) => BarraEstadistica(
                                icono: cat.icono,
                                etiqueta: cat.nombre,
                                valor: conteoComandos[cat.id] ?? 0,
                                valorMaximo: maxComandos,
                                color: esquema.tertiary,
                              ),
                            )
                            .toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaResumen extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final int valor;
  final Color color;

  const _TarjetaResumen({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icono, size: 16, color: color),
            ),
            Text(
              '$valor',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              etiqueta,
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
