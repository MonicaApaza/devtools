import 'package:flutter/material.dart';

import '../datos/categorias.dart';
import '../datos/categorias_controlador.dart';
import '../helpers/db_helper.dart';
import '../modelos/modelo_categoria.dart';

/// Formulario de alta/edición de una Categoría (nombre + ícono). El tipo
/// ('shortcut' o 'comando') se fija al abrir el formulario y no se puede
/// cambiar al editar, para no dejar huérfanos los shortcuts/comandos que
/// ya usan esa categoría.
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
  bool _guardando = false;

  bool get _esEdicion => widget.existente != null;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.existente?.nombreCategoria ?? '');
    _iconoSeleccionado = widget.existente?.iconoCategoria ?? iconosCategoria.keys.first;
  }

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final nombre = _nombre.text.trim();
    final existeDuplicado = await _dbHelper.existeNombreCategoria(
      widget.tipo,
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
        ..iconoCategoria = _iconoSeleccionado;
      await _dbHelper.actualizarCategoria(actualizada);
    } else {
      await _dbHelper.insertarCategoria(
        tipo: widget.tipo,
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
