import 'package:flutter/material.dart';

import '../data/datasources/api_client.dart';
import '../data/datos_estaticos/categorias.dart';
import '../data/modelos/modelo_categoria.dart';
import '../data/repositorios/categoria_repositorio_impl.dart';
import '../datos/categorias_controlador.dart';
import '../dominio/repositorios/categoria_repositorio.dart';

/// Formulario de alta/edición de una Categoría (nombre + ícono + tipo). El
/// tipo puede ser 'shortcut', 'comando' o 'ambos' (visible en las dos
/// secciones).
///
/// El backend no expone un endpoint para "verificar antes de intentar", así
/// que duplicados se detectan intentando guardar y capturando el 409 que
/// devuelve `crear`/`actualizar` (igual que en la app web). Tampoco valida
/// que un tipo más angosto no deje shortcuts/comandos huérfanos — ese
/// chequeo era solo local y no tiene equivalente en el backend compartido,
/// así que se retira para no reinventar una regla que la app web tampoco
/// aplica.
class CategoriaFormSheet extends StatefulWidget {
  final String tipo;
  final ModeloCategoria? existente;

  const CategoriaFormSheet({super.key, required this.tipo, this.existente});

  @override
  State<CategoriaFormSheet> createState() => _CategoriaFormSheetState();
}

class _CategoriaFormSheetState extends State<CategoriaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final CategoriaRepositorio _repositorio = CategoriaRepositorioImpl();

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
    _nombre = TextEditingController(
      text: widget.existente?.nombreCategoria ?? '',
    );
    _iconoSeleccionado =
        widget.existente?.iconoCategoria ?? iconosCategoria.keys.first;
    // Al crear, se sugiere 'ambos' por defecto (independiente de la pestaña
    // desde la que se abrió el formulario); al editar se respeta el tipo
    // guardado.
    _tipoSeleccionado = widget.existente?.tipoCategoria ?? 'ambos';
  }

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final nombre = _nombre.text.trim();
    setState(() => _guardando = true);

    try {
      if (_esEdicion) {
        final actualizada = widget.existente!
          ..nombreCategoria = nombre
          ..iconoCategoria = _iconoSeleccionado
          ..tipoCategoria = _tipoSeleccionado;
        await _repositorio.actualizar(actualizada);
      } else {
        await _repositorio.crear(
          tipo: _tipoSeleccionado,
          nombre: nombre,
          iconoClave: _iconoSeleccionado,
        );
      }
      await CategoriasController.instance.cargar();

      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiConflictException catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message)));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message)));
    }
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Disponible para',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: _opcionesTipo
                    .map(
                      (o) => ButtonSegment(
                        value: o.valor,
                        label: Text(o.etiqueta),
                      ),
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
                      color: seleccionado
                          ? esquema.onPrimary
                          : esquema.onSurfaceVariant,
                    ),
                    selected: seleccionado,
                    onSelected: (_) =>
                        setState(() => _iconoSeleccionado = entrada.key),
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
