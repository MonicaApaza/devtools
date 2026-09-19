import 'package:flutter/material.dart';

import '../presentacion/controladores/categorias_controller.dart';
import '../data/datasources/api_client.dart';
import '../data/modelos/modelo_comando.dart';
import '../data/repositorios/comando_repositorio_impl.dart';

/// Formulario de alta/edición de un Comando. Misma estructura `Form` +
/// `TextFormField` + `GlobalKey<FormState>` que ShortcutFormSheet.
class ComandoFormSheet extends StatefulWidget {
  final ModeloComando? existente;

  const ComandoFormSheet({super.key, this.existente});

  @override
  State<ComandoFormSheet> createState() => _ComandoFormSheetState();
}

class _ComandoFormSheetState extends State<ComandoFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _repositorio = ComandoRepositorioImpl();

  late final TextEditingController _titulo;
  late final TextEditingController _comando;
  late final TextEditingController _descripcion;
  late final TextEditingController _etiquetas;

  String? _categoriaSeleccionada;
  bool _categoriaConError = false;
  bool _favorito = false;
  bool _guardando = false;

  bool get _esEdicion => widget.existente != null;

  @override
  void initState() {
    super.initState();
    final existente = widget.existente;
    _titulo = TextEditingController(text: existente?.tituloComando ?? '');
    _comando = TextEditingController(text: existente?.textoComando ?? '');
    _descripcion = TextEditingController(
      text: existente?.descripcionComando ?? '',
    );
    _etiquetas = TextEditingController(text: existente?.etiquetasComando ?? '');
    _categoriaSeleccionada = existente?.categoriaComando;
    _favorito = existente?.esFavorito ?? false;
  }

  @override
  void dispose() {
    _titulo.dispose();
    _comando.dispose();
    _descripcion.dispose();
    _etiquetas.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final formValido = _formKey.currentState!.validate();
    final categoriaValida = _categoriaSeleccionada != null;
    setState(() => _categoriaConError = !categoriaValida);
    if (!formValido || !categoriaValida) return;

    setState(() => _guardando = true);

    final modelo = ModeloComando(
      pkComando: widget.existente?.pkComando,
      tituloComando: _titulo.text.trim(),
      textoComando: _comando.text.trim(),
      descripcionComando: _descripcion.text.trim(),
      categoriaComando: _categoriaSeleccionada!,
      etiquetasComando: _etiquetas.text.trim(),
      creadoEnComando: widget.existente?.creadoEnComando,
      usosComando: widget.existente?.usosComando ?? 0,
    );

    try {
      final guardado = _esEdicion
          ? await _repositorio.actualizar(modelo)
          : await _repositorio.crear(modelo);

      // El backend no acepta isFavorite en crear/actualizar (ver
      // CommandRequest) — es un endpoint aparte, así que solo se llama si
      // el valor realmente cambió.
      final favoritoOriginal = widget.existente?.esFavorito ?? false;
      if (_favorito != favoritoOriginal) {
        await _repositorio.alternarFavorito(guardado.pkComando!, _favorito);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiConflictException {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Ya existe un comando con ese título')),
        );
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
                _esEdicion ? 'Editar comando' : 'Nuevo comando',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titulo,
                decoration: const InputDecoration(labelText: 'Título o acción'),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _comando,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: const InputDecoration(
                  labelText: 'Comando',
                  hintText: 'Ej. git status',
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingresa el comando';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Text('Categoría', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CategoriasController.instance.categoriasComando.map((
                  cat,
                ) {
                  final seleccionada = cat.id == _categoriaSeleccionada;
                  return ChoiceChip(
                    label: Text(cat.nombre),
                    avatar: Icon(cat.icono, size: 18),
                    selected: seleccionada,
                    onSelected: (_) => setState(() {
                      _categoriaSeleccionada = cat.id;
                      _categoriaConError = false;
                    }),
                  );
                }).toList(),
              ),
              if (_categoriaConError)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    'Selecciona una categoría',
                    style: TextStyle(color: esquema.error, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descripcion,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _etiquetas,
                decoration: const InputDecoration(
                  labelText: 'Etiquetas',
                  hintText: 'básico, build',
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _favorito,
                onChanged: (valor) =>
                    setState(() => _favorito = valor ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('Marcar como favorito'),
              ),
              const SizedBox(height: 8),
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
