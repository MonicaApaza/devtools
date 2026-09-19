import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../presentacion/controladores/categorias_controller.dart';
import '../data/datasources/api_client.dart';
import '../data/modelos/modelo_shortcut.dart';
import '../data/repositorios/shortcut_repositorio_impl.dart';

/// Formulario de alta/edición de un Shortcut.
/// Usa `Form` + `TextFormField` + `GlobalKey<FormState>` (validación estándar
/// de Flutter), igual que el proyecto modelo_sqlite.
class ShortcutFormSheet extends StatefulWidget {
  final ModeloShortcut? existente;

  const ShortcutFormSheet({super.key, this.existente});

  @override
  State<ShortcutFormSheet> createState() => _ShortcutFormSheetState();
}

class _ShortcutFormSheetState extends State<ShortcutFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _repositorio = ShortcutRepositorioImpl();
  final _focusCaptura = FocusNode(debugLabel: 'captura-teclas');

  late final TextEditingController _titulo;
  late final TextEditingController _teclas;
  late final TextEditingController _descripcion;
  late final TextEditingController _etiquetas;

  String? _categoriaSeleccionada;
  bool _categoriaConError = false;
  bool _favorito = false;
  bool _guardando = false;
  bool _capturandoTeclas = false;
  final Set<LogicalKeyboardKey> _teclasPresionadas = {};

  static final Set<LogicalKeyboardKey> _modificadores = {
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.controlRight,
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight,
    LogicalKeyboardKey.alt,
    LogicalKeyboardKey.altLeft,
    LogicalKeyboardKey.altRight,
    LogicalKeyboardKey.meta,
    LogicalKeyboardKey.metaLeft,
    LogicalKeyboardKey.metaRight,
  };

  static final Map<LogicalKeyboardKey, String> _etiquetasEspeciales = {
    LogicalKeyboardKey.arrowUp: 'Arriba',
    LogicalKeyboardKey.arrowDown: 'Abajo',
    LogicalKeyboardKey.arrowLeft: 'Izquierda',
    LogicalKeyboardKey.arrowRight: 'Derecha',
    LogicalKeyboardKey.space: 'Space',
    LogicalKeyboardKey.enter: 'Enter',
    LogicalKeyboardKey.escape: 'Esc',
    LogicalKeyboardKey.tab: 'Tab',
    LogicalKeyboardKey.backspace: 'Backspace',
    LogicalKeyboardKey.delete: 'Delete',
  };

  bool get _esEdicion => widget.existente != null;

  @override
  void initState() {
    super.initState();
    final existente = widget.existente;
    _titulo = TextEditingController(text: existente?.tituloShortcut ?? '');
    _teclas = TextEditingController(text: existente?.teclasShortcut ?? '');
    _descripcion = TextEditingController(
      text: existente?.descripcionShortcut ?? '',
    );
    _etiquetas = TextEditingController(
      text: existente?.etiquetasShortcut ?? '',
    );
    _categoriaSeleccionada = existente?.categoriaShortcut;
    _favorito = existente?.esFavorito ?? false;
  }

  @override
  void dispose() {
    _titulo.dispose();
    _teclas.dispose();
    _descripcion.dispose();
    _etiquetas.dispose();
    _focusCaptura.dispose();
    super.dispose();
  }

  void _alternarCaptura() {
    setState(() {
      _capturandoTeclas = !_capturandoTeclas;
      _teclasPresionadas.clear();
    });
    if (_capturandoTeclas) {
      _focusCaptura.requestFocus();
    } else {
      _focusCaptura.unfocus();
    }
  }

  void _detenerCaptura() {
    setState(() => _capturandoTeclas = false);
    _teclasPresionadas.clear();
    _focusCaptura.unfocus();
  }

  String _etiquetaTecla(LogicalKeyboardKey tecla) {
    final especial = _etiquetasEspeciales[tecla];
    if (especial != null) return especial;
    final etiqueta = tecla.keyLabel;
    if (etiqueta.isEmpty) return '?';
    return etiqueta.length == 1 ? etiqueta.toUpperCase() : etiqueta;
  }

  String _construirCombinacion() {
    final partes = <String>[];
    if (HardwareKeyboard.instance.isControlPressed) partes.add('Ctrl');
    if (HardwareKeyboard.instance.isAltPressed) partes.add('Alt');
    if (HardwareKeyboard.instance.isShiftPressed) partes.add('Shift');
    if (HardwareKeyboard.instance.isMetaPressed) partes.add('Cmd');
    for (final tecla in _teclasPresionadas) {
      if (_modificadores.contains(tecla)) continue;
      final etiqueta = _etiquetaTecla(tecla);
      if (!partes.contains(etiqueta)) partes.add(etiqueta);
    }
    return partes.join('+');
  }

  void _onKeyEvent(KeyEvent evento) {
    if (!_capturandoTeclas) return;

    if (evento is KeyDownEvent) {
      if (evento.logicalKey == LogicalKeyboardKey.escape) {
        _detenerCaptura();
        return;
      }
      _teclasPresionadas.add(evento.logicalKey);
      setState(() => _teclas.text = _construirCombinacion());

      final tieneTeclaPrincipal = _teclasPresionadas.any(
        (t) => !_modificadores.contains(t),
      );
      if (tieneTeclaPrincipal) {
        _detenerCaptura();
      }
    } else if (evento is KeyUpEvent) {
      _teclasPresionadas.remove(evento.logicalKey);
    }
  }

  Future<void> _guardar() async {
    final formValido = _formKey.currentState!.validate();
    final categoriaValida = _categoriaSeleccionada != null;
    setState(() => _categoriaConError = !categoriaValida);
    if (!formValido || !categoriaValida) return;

    setState(() => _guardando = true);

    final modelo = ModeloShortcut(
      pkShortcut: widget.existente?.pkShortcut,
      tituloShortcut: _titulo.text.trim(),
      teclasShortcut: _teclas.text.trim(),
      descripcionShortcut: _descripcion.text.trim(),
      categoriaShortcut: _categoriaSeleccionada!,
      etiquetasShortcut: _etiquetas.text.trim(),
      creadoEnShortcut: widget.existente?.creadoEnShortcut,
    );

    try {
      final guardado = _esEdicion
          ? await _repositorio.actualizar(modelo)
          : await _repositorio.crear(modelo);

      // El backend no acepta isFavorite en crear/actualizar (ver
      // ShortcutRequest) — es un endpoint aparte, así que solo se llama si
      // el valor realmente cambió.
      final favoritoOriginal = widget.existente?.esFavorito ?? false;
      if (_favorito != favoritoOriginal) {
        await _repositorio.alternarFavorito(guardado.pkShortcut!, _favorito);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiConflictException {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Ya existe un shortcut con ese título')),
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
                _esEdicion ? 'Editar shortcut' : 'Nuevo shortcut',
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
              KeyboardListener(
                focusNode: _focusCaptura,
                onKeyEvent: _onKeyEvent,
                child: AbsorbPointer(
                  absorbing: _capturandoTeclas,
                  child: TextFormField(
                    controller: _teclas,
                    readOnly: _capturandoTeclas,
                    style: const TextStyle(fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      labelText: 'Combinación de teclas',
                      hintText: _capturandoTeclas
                          ? 'Presiona la combinación...'
                          : 'Ej. Ctrl+Shift+P',
                      suffixIcon: IconButton(
                        tooltip: _capturandoTeclas
                            ? 'Detener captura'
                            : 'Capturar desde el teclado',
                        icon: Icon(
                          _capturandoTeclas
                              ? Icons.fiber_manual_record
                              : Icons.keyboard,
                          color: _capturandoTeclas ? esquema.error : null,
                        ),
                        onPressed: _alternarCaptura,
                      ),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Ingresa la combinación de teclas';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              if (_capturandoTeclas)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    'Presiona las teclas deseadas (Esc para cancelar)',
                    style: TextStyle(color: esquema.primary, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 14),
              Text('Categoría', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CategoriasController.instance.categoriasShortcut.map((
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
                  hintText: 'productividad, git',
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
