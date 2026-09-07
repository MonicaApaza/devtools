import 'package:flutter/material.dart';

import '../data/datos_estaticos/categorias.dart';
import '../datos/categorias_controlador.dart';
import '../data/datasources/db_helper.dart';
import '../data/modelos/modelo_categoria.dart';
import '../widgets/categoria_form_sheet.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen>
    with SingleTickerProviderStateMixin {
  final _dbHelper = DatabaseHelper();
  late final TabController _tabController;
  List<ModeloCategoria> _shortcuts = [];
  List<ModeloCategoria> _comandos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargar();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final shortcuts = await _dbHelper.getCategoriasModelo('shortcut');
    final comandos = await _dbHelper.getCategoriasModelo('comando');
    if (!mounted) return;
    setState(() {
      _shortcuts = shortcuts;
      _comandos = comandos;
      _cargando = false;
    });
    await CategoriasController.instance.cargar();
  }

  String get _tipoActual => _tabController.index == 0 ? 'shortcut' : 'comando';

  Future<void> _mostrarFormularioNuevo() async {
    final creado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CategoriaFormSheet(tipo: _tipoActual),
    );
    if (creado == true) _cargar();
  }

  Future<void> _mostrarFormularioEditar(ModeloCategoria categoria) async {
    final editado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CategoriaFormSheet(tipo: categoria.tipoCategoria, existente: categoria),
    );
    if (editado == true) _cargar();
  }

  Future<void> _eliminar(ModeloCategoria categoria) async {
    final enUso = await _dbHelper.contarUsoCategoria(
      categoria.tipoCategoria,
      categoria.idCategoria,
    );
    if (enUso > 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
        SnackBar(
          content: Text(
            'No se puede eliminar: $enUso elemento(s) usan "${categoria.nombreCategoria}"',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar categoría?'),
        content: Text(categoria.nombreCategoria),
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
    if (confirmado != true) return;

    await _dbHelper.eliminarCategoria(categoria.pkCategoria!);
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          tabs: const [
            Tab(text: 'Shortcuts'),
            Tab(text: 'Comandos'),
          ],
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _ListaCategorias(
                  categorias: _shortcuts,
                  onEditar: _mostrarFormularioEditar,
                  onEliminar: _eliminar,
                ),
                _ListaCategorias(
                  categorias: _comandos,
                  onEditar: _mostrarFormularioEditar,
                  onEliminar: _eliminar,
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormularioNuevo,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ListaCategorias extends StatelessWidget {
  final List<ModeloCategoria> categorias;
  final ValueChanged<ModeloCategoria> onEditar;
  final ValueChanged<ModeloCategoria> onEliminar;

  const _ListaCategorias({
    required this.categorias,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    if (categorias.isEmpty) {
      return const Center(child: Text('No hay categorías todavía.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: categorias.length,
      itemBuilder: (context, index) {
        final cat = categorias[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(child: Icon(iconoPorClave(cat.iconoCategoria))),
            title: Text(cat.nombreCategoria),
            subtitle: cat.tipoCategoria == 'ambos'
                ? const Text('Shortcuts y comandos')
                : null,
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (valor) {
                if (valor == 'editar') onEditar(cat);
                if (valor == 'eliminar') onEliminar(cat);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'editar',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Editar'),
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
            ),
          ),
        );
      },
    );
  }
}
