import 'package:flutter/material.dart';

import '../datos/cambios_datos.dart';
import '../datos/categorias.dart';
import '../helpers/db_helper.dart';
import '../modelos/modelo_shortcut.dart';
import '../widgets/shortcut_form_sheet.dart';

class ShortcutsScreen extends StatefulWidget {
  final bool vistaGrid;

  const ShortcutsScreen({super.key, required this.vistaGrid});

  @override
  State<ShortcutsScreen> createState() => ShortcutsScreenState();
}

class ShortcutsScreenState extends State<ShortcutsScreen> {
  final _dbHelper = DatabaseHelper();
  List<ModeloShortcut> _shortcuts = [];
  bool _cargando = true;
  String _busqueda = '';
  String _filtroCategoria = 'all';
  int? _expandidoPk;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final datos = await _dbHelper.getShortcuts();
    if (!mounted) return;
    setState(() {
      _shortcuts = datos;
      _cargando = false;
    });
    CambiosDatos.instance.avisar();
  }

  List<ModeloShortcut> get _filtrados {
    final q = _busqueda.trim().toLowerCase();
    return _shortcuts.where((s) {
      if (_filtroCategoria != 'all' &&
          s.categoriaShortcut != _filtroCategoria) {
        return false;
      }
      if (q.isEmpty) return true;
      return s.tituloShortcut.toLowerCase().contains(q) ||
          s.teclasShortcut.toLowerCase().contains(q) ||
          s.etiquetasShortcut.toLowerCase().contains(q);
    }).toList();
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
    if (creado == true) _cargar();
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
    if (editado == true) _cargar();
  }

  Future<void> _alternarFavorito(ModeloShortcut shortcut) async {
    shortcut.favoritoShortcut = shortcut.esFavorito ? 0 : 1;
    await _dbHelper.actualizarShortcut(shortcut);
    _cargar();
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
    await _dbHelper.eliminarShortcut(shortcut.pkShortcut!);
    await _cargar();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: const Text('Shortcut eliminado'),
        action: SnackBarAction(
          label: 'DESHACER',
          onPressed: () async {
            await _dbHelper.insertarShortcut(respaldo);
            _cargar();
          },
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
            _alternarFavorito(shortcut);
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
                _alternarFavorito(shortcut);
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

  void _mostrarDetalle(ModeloShortcut shortcut) {
    final categoria = buscarCategoriaShortcut(shortcut.categoriaShortcut);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(child: Icon(categoria.icono)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shortcut.tituloShortcut,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        categoria.nombre,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _FilaTeclas(teclas: shortcut.teclas),
            if (shortcut.descripcionShortcut.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(shortcut.descripcionShortcut),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    final esquema = Theme.of(context).colorScheme;
    final lista = _filtrados;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar shortcut...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (valor) => setState(() => _busqueda = valor),
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
                  selected: _filtroCategoria == 'all',
                  onSelected: (_) => setState(() => _filtroCategoria = 'all'),
                ),
                ...categoriasShortcut.map(
                  (cat) => ChoiceChip(
                    label: Text(cat.nombre),
                    selected: _filtroCategoria == cat.id,
                    onSelected: (_) =>
                        setState(() => _filtroCategoria = cat.id),
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
  }

  Widget _construirLista(List<ModeloShortcut> lista) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final s = lista[index];
        final categoria = buscarCategoriaShortcut(s.categoriaShortcut);
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
                              _FilaTeclas(teclas: s.teclas),
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
                          onPressed: () => _alternarFavorito(s),
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
        final categoria = buscarCategoriaShortcut(s.categoriaShortcut);
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _mostrarDetalle(s),
            onLongPress: () => _mostrarAcciones(s),
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
                        s.tituloShortcut,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _FilaTeclas(teclas: s.teclas.take(2).toList()),
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
                          onPressed: () => _alternarFavorito(s),
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

class _FilaTeclas extends StatelessWidget {
  final List<String> teclas;
  const _FilaTeclas({required this.teclas});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < teclas.length; i++) ...[
          if (i > 0)
            Text('+', style: TextStyle(color: esquema.outline, fontSize: 11)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: esquema.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: esquema.outlineVariant),
            ),
            child: Text(
              teclas[i],
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
