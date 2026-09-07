import 'package:flutter/material.dart';

/// Curva principal del encabezado de LoginScreen: dos capas de onda (una
/// más ancha detrás, otra más marcada al frente) para dar profundidad al
/// elemento visual central de la pantalla. Misma técnica de
/// `Path.quadraticBezierTo` que FondoSaludoPainter, pero pensada para un
/// header más grande y con dos capas en vez de una.
class CurvaLoginPainter extends CustomPainter {
  final Color colorPrincipal;
  final Color colorAcento;

  CurvaLoginPainter({required this.colorPrincipal, required this.colorAcento});

  @override
  void paint(Canvas canvas, Size size) {
    final pinturaAcento = Paint()
      ..style = PaintingStyle.fill
      ..color = colorAcento;
    final curvaAcento = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.95,
        size.width,
        size.height * 0.6,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(curvaAcento, pinturaAcento);

    final pinturaPrincipal = Paint()
      ..style = PaintingStyle.fill
      ..color = colorPrincipal;
    final curvaPrincipal = Path()
      ..moveTo(0, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 1.12,
        size.width,
        size.height * 0.78,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(curvaPrincipal, pinturaPrincipal);
  }

  @override
  bool shouldRepaint(covariant CurvaLoginPainter oldDelegate) {
    return oldDelegate.colorPrincipal != colorPrincipal ||
        oldDelegate.colorAcento != colorAcento;
  }
}
