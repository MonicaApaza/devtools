import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../datos/categorias_controlador.dart';
import '../presentacion/controladores/busqueda_controller.dart';
import '../presentacion/controladores/home_controller.dart';
import '../theme/theme_controller.dart';
import '../utilidades/tiempo.dart';
import '../widgets/fondo_saludo.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onNavegar;

  const HomeScreen({super.key, required this.onNavegar});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late final HomeController controller;
  late final Worker _workerCategorias;

  @override
  void initState() {
    super.initState();
    controller = Get.put(HomeController());
    // Si se crea, edita o elimina una categoría desde CategoriasScreen, esta
    // lista se refresca para mostrar los chips e íconos actualizados.
    _workerCategorias = ever(
      CategoriasController.instance.version,
      (_) => controller.cargar(),
    );
  }

  @override
  void dispose() {
    _workerCategorias.dispose();
    Get.delete<HomeController>();
    super.dispose();
  }

  String _saludo() {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Buenos días';
    if (hora < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.cargando.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final esquema = Theme.of(context).colorScheme;

      return RefreshIndicator(
        onRefresh: controller.cargar,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [oscurecer(colorSemilla, 0.16), colorSemilla],
                ),
              ),
              // ClipRRect recorta el brillo y la curva a las esquinas
              // redondeadas de la tarjeta, para que no se salgan.
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  children: [
                    // Brillo circular difuminado (como un reflejo suave),
                    // arriba a la derecha.
                    Positioned(
                      top: -50,
                      right: -40,
                      child: Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.18),
                              Colors.white.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Onda sutil pegada abajo, para dar textura sin competir
                    // con el saludo ni con el buscador.
                    Positioned.fill(
                      child: CustomPaint(
                        painter: FondoSaludoPainter(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_saludo()} Monica 😃',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Domina los atajos del teclado',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: BusquedaController.instance.textoController,
                            style: TextStyle(color: Colors.white),
                            onChanged: BusquedaController.instance.actualizar,
                            decoration: InputDecoration(
                              hintText: 'Buscar shortcut o comando...',
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 18,
                              ),
                              suffixIcon: BusquedaController.instance.texto.value.isEmpty
                                  ? null
                                  : IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      onPressed: BusquedaController.instance.limpiar,
                                    ),
                              filled: true,
                              fillColor: Colors.white.withValues(
                                alpha: 0.16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Todos'),
                    selected: controller.filtroCategoria.value == 'all',
                    onSelected: (_) => controller.actualizarFiltroCategoria('all'),
                  ),
                  ...controller.categoriasFiltro.map(
                    (cat) => ChoiceChip(
                      label: Text(cat.nombre),
                      selected: controller.filtroCategoria.value == cat.id,
                      onSelected: (_) => controller.actualizarFiltroCategoria(cat.id),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (BusquedaController.instance.texto.value.trim().isNotEmpty) ...[
              Text(
                'RESULTADOS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: esquema.outline,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              if (controller.resultadosBusqueda.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: esquema.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'No hay shortcuts ni comandos que coincidan.',
                  ),
                )
              else
                ...controller.resultadosBusqueda.map(
                  (r) => _FilaReciente(
                    item: r,
                    onTap: () => widget.onNavegar(r.destino),
                  ),
                ),
            ] else ...[
              Text(
                'FAVORITOS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: esquema.outline,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              if (controller.favoritos.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: esquema.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Marca elementos con la estrella para verlos aquí.',
                  ),
                )
              else
                ...controller.favoritos.map(
                  (f) => _FilaReciente(
                    item: f,
                    onTap: () => widget.onNavegar(f.destino),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                'RECIENTES',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: esquema.outline,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              ...controller.recientes.map(
                (r) => _FilaReciente(
                  item: r,
                  mostrarTiempo: true,
                  onTap: () => widget.onNavegar(r.destino),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _FilaReciente extends StatelessWidget {
  final ItemReciente item;
  final bool mostrarTiempo;
  final VoidCallback onTap;

  const _FilaReciente({
    required this.item,
    this.mostrarTiempo = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Icon(item.icono, size: 18)),
      title: Text(
        item.titulo,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        mostrarTiempo
            ? '${item.meta} · ${tiempoRelativo(item.creadoEn)}'
            : item.meta,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: item.favorito
          ? Icon(Icons.star, color: Colors.amber.shade700, size: 20)
          : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
