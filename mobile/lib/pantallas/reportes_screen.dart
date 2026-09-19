import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../datos/categorias_controlador.dart';
import '../data/modelos/modelo_comando.dart';
import '../presentacion/controladores/reportes_controller.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  late final ReportesController controller;
  late final Worker _workerCategorias;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ReportesController());
    _workerCategorias = ever(
      CategoriasController.instance.version,
      (_) => controller.cargar(),
    );
  }

  @override
  void dispose() {
    _workerCategorias.dispose();
    Get.delete<ReportesController>();
    super.dispose();
  }

  String _formatearFecha(int creadoEn) {
    final fecha = DateTime.fromMillisecondsSinceEpoch(creadoEn);
    final diferencia = DateTime.now().difference(fecha);
    if (diferencia.inDays <= 0) return 'Hoy';
    if (diferencia.inDays == 1) return 'Ayer';
    if (diferencia.inDays < 7) return 'Hace ${diferencia.inDays} días';
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.cargando.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final esquema = Theme.of(context).colorScheme;
      final categorias = CategoriasController.instance;

      return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Hero(
                tag: 'icon-reportes',
                child: Icon(Icons.summarize_outlined),
              ),
              SizedBox(width: 12),
              Text('Reportes'),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: controller.cargar,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Text(
                'COMANDOS MÁS USADOS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: esquema.outline,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: controller.comandosMasUsados.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Aún no hay comandos con usos registrados.'),
                      )
                    : Column(
                        children: [
                          for (final (indice, comando)
                              in controller.comandosMasUsados.indexed) ...[
                            if (indice > 0) const Divider(height: 1),
                            _FilaComandoUsado(
                              posicion: indice + 1,
                              comando: comando,
                              categoriaNombre: categorias
                                  .buscarCategoriaComando(
                                    comando.categoriaComando,
                                  )
                                  .nombre,
                            ),
                          ],
                        ],
                      ),
              ),
              const SizedBox(height: 20),
              Text(
                'AGREGADOS RECIENTEMENTE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: esquema.outline,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: controller.agregadosRecientemente.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Aún no hay shortcuts ni comandos guardados.'),
                      )
                    : Column(
                        children: [
                          for (final (indice, item)
                              in controller.agregadosRecientemente.indexed) ...[
                            if (indice > 0) const Divider(height: 1),
                            _FilaItemReciente(
                              item: item,
                              categoriaNombre: item.esComando
                                  ? categorias
                                        .buscarCategoriaComando(
                                          item.categoriaId,
                                        )
                                        .nombre
                                  : categorias
                                        .buscarCategoriaShortcut(
                                          item.categoriaId,
                                        )
                                        .nombre,
                              fecha: _formatearFecha(item.creadoEn),
                            ),
                          ],
                        ],
                      ),
              ),
              const SizedBox(height: 20),
              Text(
                'FAVORITOS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: esquema.outline,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: controller.favoritos.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Aún no marcaste shortcuts ni comandos como favoritos.'),
                      )
                    : Column(
                        children: [
                          for (final (indice, item)
                              in controller.favoritos.indexed) ...[
                            if (indice > 0) const Divider(height: 1),
                            _FilaItemReciente(
                              item: item,
                              categoriaNombre: item.esComando
                                  ? categorias
                                        .buscarCategoriaComando(
                                          item.categoriaId,
                                        )
                                        .nombre
                                  : categorias
                                        .buscarCategoriaShortcut(
                                          item.categoriaId,
                                        )
                                        .nombre,
                              fecha: _formatearFecha(item.creadoEn),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _FilaComandoUsado extends StatelessWidget {
  final int posicion;
  final ModeloComando comando;
  final String categoriaNombre;

  const _FilaComandoUsado({
    required this.posicion,
    required this.comando,
    required this.categoriaNombre,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: esquema.primaryContainer,
        child: Text(
          '$posicion',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: esquema.onPrimaryContainer,
          ),
        ),
      ),
      title: Text(comando.tituloComando),
      subtitle: Text(categoriaNombre),
      trailing: Chip(
        label: Text('${comando.usosComando} usos'),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _FilaItemReciente extends StatelessWidget {
  final ItemReciente item;
  final String categoriaNombre;
  final String fecha;

  const _FilaItemReciente({
    required this.item,
    required this.categoriaNombre,
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(item.esComando ? Icons.terminal : Icons.keyboard_outlined),
      title: Text(item.titulo),
      subtitle: Text(categoriaNombre),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (item.esFavorito)
            Icon(Icons.star, size: 16, color: Colors.amber.shade700),
          Text(fecha, style: TextStyle(color: esquema.outline, fontSize: 12)),
        ],
      ),
    );
  }
}
