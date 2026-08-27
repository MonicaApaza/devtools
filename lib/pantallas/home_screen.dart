import 'package:flutter/material.dart';

import '../datos/cambios_datos.dart';
import '../datos/categorias.dart';
import '../helpers/db_helper.dart';
import '../theme/theme_controller.dart';
import '../utilidades/tiempo.dart';
import '../widgets/fondo_saludo.dart';

class _ItemReciente {
  final String titulo;
  final String meta;
  final IconData icono;
  final int creadoEn;
  final int destino; // 1 = shortcuts, 2 = comandos
  final bool favorito;
  final String categoriaId;
  _ItemReciente(
    this.titulo,
    this.meta,
    this.icono,
    this.creadoEn,
    this.destino,
    this.favorito,
    this.categoriaId,
  );
}

class _CategoriaFiltro {
  final String id;
  final String nombre;
  const _CategoriaFiltro(this.id, this.nombre);
}

// Unión de las categorías de shortcuts y comandos (sin duplicados), para
// poder filtrar ambos tipos de elementos con un solo set de chips.
final List<_CategoriaFiltro> _categoriasHome = () {
  final vistas = <String>{};
  final resultado = <_CategoriaFiltro>[];
  for (final cat in [...categoriasShortcut, ...categoriasComando]) {
    if (vistas.add(cat.id)) resultado.add(_CategoriaFiltro(cat.id, cat.nombre));
  }
  return resultado;
}();

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
  String _filtroCategoria = 'all';
  List<_ItemReciente> _todos = [];

  @override
  void initState() {
    super.initState();
    cargar();
    // Shortcuts y Comandos avisan aquí cuando algo cambia (favorito, alta,
    // edición, borrado) para que Inicio se refresque sin que nadie más
    // tenga que acordarse de llamarlo a mano.
    CambiosDatos.instance.addListener(cargar);
  }

  @override
  void dispose() {
    CambiosDatos.instance.removeListener(cargar);
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
          s.categoriaShortcut,
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
          c.categoriaComando,
        ),
      ),
    ];

    items.sort((a, b) => b.creadoEn.compareTo(a.creadoEn));

    if (!mounted) return;
    setState(() {
      _todos = items;
      _cargando = false;
    });
  }

  List<_ItemReciente> get _itemsFiltrados {
    if (_filtroCategoria == 'all') return _todos;
    return _todos.where((i) => i.categoriaId == _filtroCategoria).toList();
  }

  List<_ItemReciente> get _favoritos =>
      _itemsFiltrados.where((i) => i.favorito).toList();

  List<_ItemReciente> get _recientes => _itemsFiltrados.take(5).toList();

  List<_ItemReciente> get _resultadosBusqueda {
    final q = _busqueda.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _itemsFiltrados
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
                          controller: _busquedaController,
                          style: TextStyle(color: Colors.white),
                          onChanged: (valor) =>
                              setState(() => _busqueda = valor),
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
                            suffixIcon: _busqueda.isEmpty
                                ? null
                                : IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    onPressed: () => setState(() {
                                      _busqueda = '';
                                      _busquedaController.clear();
                                    }),
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
                  selected: _filtroCategoria == 'all',
                  onSelected: (_) => setState(() => _filtroCategoria = 'all'),
                ),
                ..._categoriasHome.map(
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
          const SizedBox(height: 16),
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
