import 'package:flutter/material.dart';

import '../datos/categorias.dart';
import '../helpers/db_helper.dart';
import '../utilidades/tiempo.dart';

class _ItemReciente {
  final String titulo;
  final String meta;
  final IconData icono;
  final int creadoEn;
  final int destino; // 1 = shortcuts, 2 = comandos
  final bool favorito;
  _ItemReciente(
    this.titulo,
    this.meta,
    this.icono,
    this.creadoEn,
    this.destino,
    this.favorito,
  );
}

class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onNavegar;

  const HomeScreen({super.key, required this.onNavegar});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _dbHelper = DatabaseHelper();
  final _busquedaController = TextEditingController();
  bool _cargando = true;
  String _busqueda = '';
  List<_ItemReciente> _todos = [];
  List<_ItemReciente> _favoritos = [];
  List<_ItemReciente> _recientes = [];

  @override
  void initState() {
    super.initState();
    cargar();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> cargar() async {
    final shortcuts = await _dbHelper.getShortcuts();
    final comandos = await _dbHelper.getComandos();

    final items = <_ItemReciente>[
      ...shortcuts.map(
        (s) => _ItemReciente(
          s.tituloShortcut,
          s.teclas.join(' + '),
          buscarCategoriaShortcut(s.categoriaShortcut).icono,
          s.creadoEnShortcut,
          1,
          s.esFavorito,
        ),
      ),
      ...comandos.map(
        (c) => _ItemReciente(
          c.tituloComando,
          c.textoComando,
          buscarCategoriaComando(c.categoriaComando).icono,
          c.creadoEnComando,
          2,
          c.esFavorito,
        ),
      ),
    ];

    items.sort((a, b) => b.creadoEn.compareTo(a.creadoEn));

    if (!mounted) return;
    setState(() {
      _todos = items;
      _favoritos = items.where((i) => i.favorito).toList();
      _recientes = items.take(5).toList();
      _cargando = false;
    });
  }

  List<_ItemReciente> get _resultadosBusqueda {
    final q = _busqueda.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _todos
        .where(
          (i) =>
              i.titulo.toLowerCase().contains(q) ||
              i.meta.toLowerCase().contains(q),
        )
        .toList();
  }

  String _saludo() {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Buenos días';
    if (hora < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    final esquema = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: cargar,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [esquema.primary, esquema.primaryContainer],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_saludo()} Monica 😃',
                  style: TextStyle(
                    color: esquema.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Domina los atajos del teclado',
                  style: TextStyle(
                    color: esquema.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _busquedaController,
                  style: TextStyle(color: esquema.onPrimary),
                  onChanged: (valor) => setState(() => _busqueda = valor),
                  decoration: InputDecoration(
                    hintText: 'Buscar shortcut o comando...',
                    hintStyle: TextStyle(
                      color: esquema.onPrimary.withValues(alpha: 0.85),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: esquema.onPrimary,
                      size: 18,
                    ),
                    suffixIcon: _busqueda.isEmpty
                        ? null
                        : IconButton(
                            icon: Icon(
                              Icons.close,
                              color: esquema.onPrimary,
                              size: 18,
                            ),
                            onPressed: () => setState(() {
                              _busqueda = '';
                              _busquedaController.clear();
                            }),
                          ),
                    filled: true,
                    fillColor: esquema.onPrimary.withValues(alpha: 0.16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: esquema.onPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: esquema.onPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: esquema.onPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_busqueda.trim().isNotEmpty) ...[
            Text(
              'RESULTADOS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: esquema.outline,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            if (_resultadosBusqueda.isEmpty)
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
              ..._resultadosBusqueda.map(
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
            if (_favoritos.isEmpty)
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
              ..._favoritos.map(
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
            ..._recientes.map(
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
  }
}

class _FilaReciente extends StatelessWidget {
  final _ItemReciente item;
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
