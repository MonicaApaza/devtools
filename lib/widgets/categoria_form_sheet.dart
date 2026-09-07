import 'package:flutter/material.dart';

import '../data/datos_estaticos/categorias.dart';
import '../datos/categorias_controlador.dart';
import '../data/datasources/db_helper.dart';
import '../data/modelos/modelo_categoria.dart';

/// Formulario de alta/edición de una Categoría (nombre + ícono + tipo). El
/// tipo puede ser 'shortcut', 'comando' o 'ambos' (visible en las dos
/// secciones). Al editar, si se quita cobertura de un lado (p.ej. de
/// 'ambos' a 'shortcut') y ese lado todavía tiene shortcuts/comandos
/// apuntando a esta categoría, se bloquea el guardado para no dejarlos
/// huérfanos.
class CategoriaFormSheet extends StatefulWidget {
  final String tipo;
  final ModeloCategoria? existente;

  const CategoriaFormSheet({super.key, required this.tipo, this.existente});

  @override
  State<CategoriaFormSheet> createState() => _CategoriaFormSheetState();
}

class _CategoriaFormSheetState extends State<CategoriaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();

  late final TextEditingController _nombre;
  late String _iconoSeleccionado;
  late String _tipoSeleccionado;
  bool _guardando = false;

  bool get _esEdicion => widget.existente != null;

  static const _opcionesTipo = [
    (valor: 'shortcut', etiqueta: 'Shortcut'),
    (valor: 'comando', etiqueta: 'Comando'),
    (valor: 'ambos', etiqueta: 'Ambos'),
  ];

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.existente?.nombreCategoria ?? '');
    _iconoSeleccionado = widget.existente?.iconoCategoria ?? iconosCategoria.keys.first;
    _tipoSeleccionado = widget.existente?.tipoCategoria ?? widget.tipo;
  }

  List<String> _ladosDe(String tipo) =>
      tipo == 'ambos' ? const ['shortcut', 'comando'] : [tipo];

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final nombre = _nombre.text.trim();

    if (_esEdicion) {
      final ladosAntes = _ladosDe(widget.existente!.tipoCategoria).toSet();
      final ladosDespues = _ladosDe(_tipoSeleccionado).toSet();
      final ladosPerdidos = ladosAntes.difference(ladosDespues);
      for (final lado in ladosPerdidos) {
        final enUso = await _dbHelper.contarUsoCategoria(
          lado,
          widget.existente!.idCategoria,
        );
        if (enUso > 0) {
          if (!mounted) return;
          final ladoLabel = lado == 'shortcut' ? 'shortcut(s)' : 'comando(s)';
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
            SnackBar(
              content: Text(
                'No se puede quitar "$lado": $enUso $ladoLabel todavía usan esta categoría',
              ),
            ),
          );
          return;
        }
      }
    }

    final existeDuplicado = await _dbHelper.existeNombreCategoria(
      _tipoSeleccionado,
      nombre,
      excluirPk: widget.existente?.pkCategoria,
    );
    if (existeDuplicado) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
        const SnackBar(content: Text('Ya existe una categoría con ese nombre')),
      );
      return;
    }

    setState(() => _guardando = true);

    if (_esEdicion) {
      final actualizada = widget.existente!
        ..nombreCategoria = nombre
        ..iconoCategoria = _iconoSeleccionado
        ..tipoCategoria = _tipoSeleccionado;
      await _dbHelper.actualizarCategoria(actualizada);
    } else {
      await _dbHelper.insertarCategoria(
        tipo: _tipoSeleccionado,
        nombre: nombre,
        iconoClave: _iconoSeleccionado,
      );
    }
    await CategoriasController.instance.cargar();

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: esquema.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Text(
                _esEdicion ? 'Editar categoría' : 'Nueva categoría',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Disponible para', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: _opcionesTipo
                    .map(
                      (o) => ButtonSegment(value: o.valor, label: Text(o.etiqueta)),
                    )
                    .toList(),
                selected: {_tipoSeleccionado},
                onSelectionChanged: (seleccion) =>
                    setState(() => _tipoSeleccionado = seleccion.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Text('Ícono', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: iconosCategoria.entries.map((entrada) {
                  final seleccionado = entrada.key == _iconoSeleccionado;
                  return ChoiceChip(
                    label: Icon(
                      entrada.value,
                      size: 20,
                      color: seleccionado ? esquema.onPrimary : esquema.onSurfaceVariant,
                    ),
                    selected: seleccionado,
                    onSelected: (_) => setState(() => _iconoSeleccionado = entrada.key),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _guardando ? null : _guardar,
                      child: _guardando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
