import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../presentacion/controladores/categorias_controller.dart';
import '../presentacion/controladores/estadisticas_controller.dart';
import '../theme/theme_controller.dart';
import '../widgets/barra_estadistica.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  late final EstadisticasController controller;
  late final Worker _workerCategorias;

  @override
  void initState() {
    super.initState();
    controller = Get.put(EstadisticasController());
    _workerCategorias = ever(
      CategoriasController.instance.version,
      (_) => controller.cargar(),
    );
  }

  @override
  void dispose() {
    _workerCategorias.dispose();
    Get.delete<EstadisticasController>();
    super.dispose();
  }

  Map<String, int> _contarPorCategoria(Iterable<String> categoriasDeItems) =>
      controller.contarPorCategoria(categoriasDeItems);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.cargando.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final esquema = Theme.of(context).colorScheme;
      final shortcuts = controller.shortcuts;
      final comandos = controller.comandos;

      final conteoShortcuts = _contarPorCategoria(
        shortcuts.map((s) => s.categoriaShortcut),
      );
      final conteoComandos = _contarPorCategoria(
        comandos.map((c) => c.categoriaComando),
      );
      final maxShortcuts = conteoShortcuts.values.isEmpty
          ? 0
          : conteoShortcuts.values.reduce((a, b) => a > b ? a : b);
      final maxComandos = conteoComandos.values.isEmpty
          ? 0
          : conteoComandos.values.reduce((a, b) => a > b ? a : b);

      return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Hero(
                tag: 'icon-estadisticas',
                child: Icon(Icons.bar_chart_outlined),
              ),
              SizedBox(width: 12),
              Text('Estadísticas'),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: controller.cargar,
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
                    valor: shortcuts.length,
                    color: colorSemilla,
                  ),
                  _TarjetaResumen(
                    icono: Icons.terminal,
                    etiqueta: 'Comandos',
                    valor: comandos.length,
                    color: esquema.tertiary,
                  ),
                  _TarjetaResumen(
                    icono: Icons.star_outline,
                    etiqueta: 'Favoritos',
                    valor: controller.favoritos,
                    color: Colors.amber.shade700,
                  ),
                  _TarjetaResumen(
                    icono: Icons.dashboard_outlined,
                    etiqueta: 'Total',
                    valor: shortcuts.length + comandos.length,
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
                  child: shortcuts.isEmpty
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
                  child: comandos.isEmpty
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
    });
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
