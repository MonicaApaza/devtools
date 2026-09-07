import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../datos/categorias_controlador.dart';
import '../data/modelos/modelo_shortcut.dart';
import '../presentacion/controladores/busqueda_controller.dart';
import '../presentacion/controladores/shortcuts_controller.dart';
import '../presentacion/pantallas/shortcut_detalle_screen.dart';
import '../presentacion/widgets/fila_teclas.dart';
import '../widgets/shortcut_form_sheet.dart';

class ShortcutsScreen extends StatefulWidget {
  final bool vistaGrid;

  const ShortcutsScreen({super.key, required this.vistaGrid});

  @override
  State<ShortcutsScreen> createState() => ShortcutsScreenState();
}

class ShortcutsScreenState extends State<ShortcutsScreen> {
  late final ShortcutsController controller;
  int? _expandidoPk;
  late final Worker _workerCategorias;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ShortcutsController());
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
    Get.delete<ShortcutsController>();
    super.dispose();
  }

  Future<void> mostrarFormularioNuevo() async {
    final creado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const ShortcutFormSheet(),
    );
    if (creado == true) controller.cargar();
  }

  Future<void> _mostrarFormularioEditar(ModeloShortcut shortcut) async {
    final editado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ShortcutFormSheet(existente: shortcut),
    );
    if (editado == true) controller.cargar();
  }

  Future<void> _eliminar(ModeloShortcut shortcut) async {
    final respaldo = ModeloShortcut(
      tituloShortcut: shortcut.tituloShortcut,
      teclasShortcut: shortcut.teclasShortcut,
      descripcionShortcut: shortcut.descripcionShortcut,
      categoriaShortcut: shortcut.categoriaShortcut,
      etiquetasShortcut: shortcut.etiquetasShortcut,
      favoritoShortcut: shortcut.favoritoShortcut,
    );
    await controller.eliminar(shortcut);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        // Un SnackBar con `action` se marca "persist" por defecto en Flutter
        // y entonces ignora `duration` (para que el usuario alcance a tocar
        // DESHACER). Lo forzamos a false para que sí se cierre solo.
        persist: false,
        content: const Text('Shortcut eliminado'),
        action: SnackBarAction(
          label: 'DESHACER',
          onPressed: () => controller.restaurar(respaldo),
        ),
      ),
    );
  }

  Future<bool> _confirmarEliminar(ModeloShortcut shortcut) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar shortcut?'),
        content: Text(shortcut.tituloShortcut),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    return confirmado ?? false;
  }

  Future<void> _confirmarYEliminar(ModeloShortcut shortcut) async {
    if (await _confirmarEliminar(shortcut)) _eliminar(shortcut);
  }

  PopupMenuButton<String> _menuAcciones(ModeloShortcut shortcut) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (valor) {
        switch (valor) {
          case 'editar':
            _mostrarFormularioEditar(shortcut);
            break;
          case 'favorito':
            controller.alternarFavorito(shortcut);
            break;
          case 'eliminar':
            _confirmarYEliminar(shortcut);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'editar',
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Editar'),
          ),
        ),
        PopupMenuItem(
          value: 'favorito',
          child: ListTile(
            leading: Icon(shortcut.esFavorito ? Icons.star : Icons.star_border),
            title: Text(
              shortcut.esFavorito
                  ? 'Quitar de favoritos'
                  : 'Agregar a favoritos',
            ),
          ),
        ),
        const PopupMenuItem(
          value: 'eliminar',
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.red),
            title: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ),
      ],
    );
  }

  void _mostrarAcciones(ModeloShortcut shortcut) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                _mostrarFormularioEditar(shortcut);
              },
            ),
            ListTile(
              leading: Icon(
                shortcut.esFavorito ? Icons.star : Icons.star_border,
              ),
              title: Text(
                shortcut.esFavorito
                    ? 'Quitar de favoritos'
                    : 'Agregar a favoritos',
              ),
              onTap: () {
                Navigator.pop(context);
                controller.alternarFavorito(shortcut);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                if (await _confirmarEliminar(shortcut)) {
                  _eliminar(shortcut);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _abrirDetalle(ModeloShortcut shortcut) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShortcutDetalleScreen(shortcut: shortcut),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.cargando.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final esquema = Theme.of(context).colorScheme;
      final lista = controller.filtrados;

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: BusquedaController.instance.textoController,
              decoration: InputDecoration(
                hintText: 'Buscar shortcut...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: BusquedaController.instance.texto.value.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: BusquedaController.instance.limpiar,
                      ),
              ),
              onChanged: BusquedaController.instance.actualizar,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
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
                  ...CategoriasController.instance.categoriasShortcut.map(
                    (cat) => ChoiceChip(
                      label: Text(cat.nombre),
                      selected: controller.filtroCategoria.value == cat.id,
                      onSelected: (_) => controller.actualizarFiltroCategoria(cat.id),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: lista.isEmpty
                ? Center(
                    child: Text(
                      'No hay shortcuts que coincidan',
                      style: TextStyle(color: esquema.outline),
                    ),
                  )
                : widget.vistaGrid
                ? _construirGrid(lista)
                : _construirLista(lista),
          ),
        ],
      );
    });
  }

  Widget _construirLista(List<ModeloShortcut> lista) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final s = lista[index];
        final categoria = CategoriasController.instance.buscarCategoriaShortcut(s.categoriaShortcut);
        final expandido = _expandidoPk == s.pkShortcut;

        return Dismissible(
          key: ValueKey(s.pkShortcut),
          direction: DismissDirection.endToStart,
          background: Container(),
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) => _confirmarEliminar(s),
          onDismissed: (_) => _eliminar(s),
          child: Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => setState(
                () => _expandidoPk = expandido ? null : s.pkShortcut,
              ),
              onLongPress: () => _mostrarAcciones(s),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(child: Icon(categoria.icono, size: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.tituloShortcut,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              FilaTeclas(teclas: s.teclas),
                              if (s.etiquetas.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  children: s.etiquetas
                                      .map(
                                        (t) => Chip(
                                          label: Text(
                                            t,
                                            style: const TextStyle(
                                              fontSize: 11,
                                            ),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            s.esFavorito ? Icons.star : Icons.star_border,
                            color: s.esFavorito ? Colors.amber.shade700 : null,
                          ),
                          onPressed: () => controller.alternarFavorito(s),
                        ),
                        _menuAcciones(s),
                      ],
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      child: expandido && s.descripcionShortcut.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 10, left: 52),
                              child: Text(
                                s.descripcionShortcut,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontSize: 13,
                                ),
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _construirGrid(List<ModeloShortcut> lista) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.05,
      ),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final s = lista[index];
        final categoria = CategoriasController.instance.buscarCategoriaShortcut(s.categoriaShortcut);
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _abrirDetalle(s),
            onLongPress: () => _mostrarAcciones(s),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'shortcut-${s.pkShortcut}',
                        child: CircleAvatar(child: Icon(categoria.icono, size: 18)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        s.tituloShortcut,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilaTeclas(teclas: s.teclas.take(2).toList()),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            s.esFavorito ? Icons.star : Icons.star_border,
                            size: 20,
                            color: s.esFavorito ? Colors.amber.shade700 : null,
                          ),
                          onPressed: () => controller.alternarFavorito(s),
                        ),
                        _menuAcciones(s),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
