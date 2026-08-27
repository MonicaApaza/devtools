import 'package:flutter/material.dart';

/// Barra horizontal proporcional: el ancho relleno representa
/// `valor / valorMaximo`. Se usa para los gráficos simples de
/// "cantidad por categoría" en la pantalla de Estadísticas.
class BarraEstadistica extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final int valor;
  final int valorMaximo;
  final Color color;

  const BarraEstadistica({
    super.key,
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.valorMaximo,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final fraccion = valorMaximo == 0 ? 0.0 : valor / valorMaximo;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icono, size: 18, color: esquema.onSurfaceVariant),
          const SizedBox(width: 8),
          SizedBox(
            width: 92,
            child: Text(
              etiqueta,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LayoutBuilder(
                builder: (context, restricciones) {
                  return Stack(
                    children: [
                      Container(
                        height: 10,
                        color: esquema.surfaceContainerHighest,
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        height: 10,
                        width: restricciones.maxWidth * fraccion,
                        color: color,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              '$valor',
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
