import 'package:flutter/material.dart';

/// Fila de "chips" de teclado unidos por "+". Se usa tanto en las
/// tarjetas/lista de ShortcutsScreen (`grande: false`) como en
/// ShortcutDetalleScreen (`grande: true`), para no duplicar el widget.
class FilaTeclas extends StatelessWidget {
  final List<String> teclas;
  final bool grande;

  const FilaTeclas({super.key, required this.teclas, this.grande = false});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final fontSize = grande ? 16.0 : 11.0;
    final padding = grande
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 7, vertical: 3);

    return Wrap(
      spacing: grande ? 8 : 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < teclas.length; i++) ...[
          if (i > 0)
            Text('+', style: TextStyle(color: esquema.outline, fontSize: fontSize)),
          Container(
            padding: padding,
            decoration: BoxDecoration(
              color: esquema.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(grande ? 10 : 6),
              border: Border.all(color: esquema.outlineVariant),
            ),
            child: Text(
              teclas[i],
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
