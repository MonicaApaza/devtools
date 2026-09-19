import 'package:flutter/material.dart';

Color oscurecer(Color color, double cantidad) {
  final hsl = HSLColor.fromColor(color);
  final luminosidad = (hsl.lightness - cantidad).clamp(0.0, 1.0);
  return hsl.withLightness(luminosidad).toColor();
}

class FondoSaludoPainter extends CustomPainter {
  final Color color;
  final Color colorAcento;

  FondoSaludoPainter({required this.color, required this.colorAcento});

  @override
  void paint(Canvas canvas, Size size) {
    final pinturaAcento = Paint()
      ..style = PaintingStyle.fill
      ..color = colorAcento;
    final curvaAcento = Path()
      ..moveTo(0, size.height * 0.62)
      ..cubicTo(
        size.width * 0.24,
        size.height * 0.78,
        size.width * 0.76,
        size.height * 0.78,
        size.width,
        size.height * 0.62,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(curvaAcento, pinturaAcento);

    final pintura = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final curva = Path()
      ..moveTo(0, size.height * 0.74)
      ..cubicTo(
        size.width * 0.24,
        size.height * 0.94,
        size.width * 0.76,
        size.height * 0.94,
        size.width,
        size.height * 0.74,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(curva, pintura);
  }

  @override
  bool shouldRepaint(covariant FondoSaludoPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.colorAcento != colorAcento;
  }
}
