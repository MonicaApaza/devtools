import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../datos/categorias_controlador.dart';
import '../data/modelos/modelo_comando.dart';
import '../presentacion/controladores/comandos_controller.dart';
import '../widgets/comando_form_sheet.dart';

class ComandosScreen extends StatefulWidget {
  final bool vistaGrid;

  const ComandosScreen({super.key, required this.vistaGrid});

  @override
  State<ComandosScreen> createState() => ComandosScreenState();
}

class ComandosScreenState extends State<ComandosScreen> {
  late final ComandosController controller;
  late final Worker _workerCategorias;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ComandosController());
    _workerCategorias = ever(
      CategoriasController.instance.version,
      (_) => controller.cargar(),
    );
  }

  @override
  void dispose() {
    _workerCategorias.dispose();
    Get.delete<ComandosController>();
    super.dispose();
  }

  Future<void> mostrarFormularioNuevo() async {
    final creado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const ComandoFormSheet(),
    );
    if (creado == true) controller.cargar();
  }

  Future<void> _mostrarFormularioEditar(ModeloComando comando) async {
    final editado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ComandoFormSheet(existente: comando),
    );
    if (editado == true) controller.cargar();
  }

  Future<void> _copiar(ModeloComando comando) async {
    await Clipboard.setData(ClipboardData(text: comando.textoComando));
    await controller.incrementarUso(comando);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
      const SnackBar(content: Text('Comando copiado al portapapeles')),
    );
  }

  Future<void> _eliminar(ModeloComando comando) async {
    final respaldo = ModeloComando(
      tituloComando: comando.tituloComando,
      textoComando: comando.textoComando,
      descripcionComando: comando.descripcionComando,
      categoriaComando: comando.categoriaComando,
      etiquetasComando: comando.etiquetasComando,
      favoritoComando: comando.favoritoComando,
      usosComando: comando.usosComando,
    );
    await controller.eliminar(comando);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        // Ver shortcuts_screen.dart: un SnackBar con `action` es "persist"
        // por defecto en Flutter e ignora `duration`. Lo forzamos a false.
        persist: false,
        content: const Text('Comando eliminado'),
        action: SnackBarAction(
          label: 'DESHACER',
          onPressed: () => controller.restaurar(respaldo),
        ),
      ),
    );
  }

  Future<bool> _confirmarEliminar(ModeloComando comando) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar comando?'),
        content: Text(comando.tituloComando),
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

  Future<void> _confirmarYEliminar(ModeloComando comando) async {
    if (await _confirmarEliminar(comando)) _eliminar(comando);
  }

  PopupMenuButton<String> _menuAcciones(ModeloComando comando) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (valor) {
        switch (valor) {
          case 'copiar':
            _copiar(comando);
            break;
          case 'editar':
            _mostrarFormularioEditar(comando);
            break;
          case 'favorito':
            controller.alternarFavorito(comando);
            break;
          case 'eliminar':
            _confirmarYEliminar(comando);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'copiar',
          child: ListTile(
            leading: Icon(Icons.copy_outlined),
            title: Text('Copiar'),
          ),
        ),
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
            leading: Icon(comando.esFavorito ? Icons.star : Icons.star_border),
            title: Text(
              comando.esFavorito
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

  void _mostrarAcciones(ModeloComando comando) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Copiar'),
              onTap: () {
                Navigator.pop(context);
                _copiar(comando);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                _mostrarFormularioEditar(comando);
              },
            ),
            ListTile(
              leading: Icon(
                comando.esFavorito ? Icons.star : Icons.star_border,
              ),
              title: Text(
                comando.esFavorito
                    ? 'Quitar de favoritos'
                    : 'Agregar a favoritos',
              ),
              onTap: () {
                Navigator.pop(context);
                controller.alternarFavorito(comando);
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
                if (await _confirmarEliminar(comando)) {
                  _eliminar(comando);
                }
              },
            ),
          ],
        ),
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
              controller: controller.busquedaController,
              decoration: InputDecoration(
                hintText: 'Buscar comando...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.busqueda.value.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: controller.limpiarBusqueda,
                      ),
              ),
              onChanged: controller.actualizarBusqueda,
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
                  ...CategoriasController.instance.categoriasComando.map(
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
                      'No hay comandos que coincidan',
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

  Widget _construirLista(List<ModeloComando> lista) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final c = lista[index];
        final categoria = CategoriasController.instance.buscarCategoriaComando(c.categoriaComando);

        return Dismissible(
          key: ValueKey(c.pkComando),
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
          confirmDismiss: (_) => _confirmarEliminar(c),
          onDismissed: (_) => _eliminar(c),
          child: Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onLongPress: () => _mostrarAcciones(c),
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
                                c.tituloComando,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                children: [
                                  Chip(
                                    label: Text(
                                      categoria.nombre,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            c.esFavorito ? Icons.star : Icons.star_border,
                            color: c.esFavorito ? Colors.amber.shade700 : null,
                          ),
                          onPressed: () => controller.alternarFavorito(c),
                        ),
                        _menuAcciones(c),
                      ],
                    ),
                    if (c.descripcionComando.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 52),
                        child: Text(
                          c.descripcionComando,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 52),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: r'$ ',
                                      style: TextStyle(
                                        color: Colors.greenAccent,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    TextSpan(
                                      text: c.textoComando,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.copy,
                                color: Colors.white70,
                                size: 18,
                              ),
                              onPressed: () => _copiar(c),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (c.usosComando > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 52, top: 6),
                        child: Text(
                          c.usosComando == 1
                              ? 'Copiado 1 vez'
                              : 'Copiado ${c.usosComando} veces',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 11.5,
                          ),
                        ),
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

  Widget _construirGrid(List<ModeloComando> lista) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final c = lista[index];
        final categoria = CategoriasController.instance.buscarCategoriaComando(c.categoriaComando);
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _copiar(c),
            onLongPress: () => _mostrarAcciones(c),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(child: Icon(categoria.icono, size: 18)),
                      const SizedBox(height: 10),
                      Text(
                        c.tituloComando,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          c.textoComando,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                        ),
                      ),
                      if (c.usosComando > 0) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.repeat,
                              size: 12,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${c.usosComando}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
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
                            c.esFavorito ? Icons.star : Icons.star_border,
                            size: 20,
                            color: c.esFavorito ? Colors.amber.shade700 : null,
                          ),
                          onPressed: () => controller.alternarFavorito(c),
                        ),
                        _menuAcciones(c),
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
