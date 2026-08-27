import 'package:flutter/material.dart';

Color oscurecer(Color color, double cantidad) {
  final hsl = HSLColor.fromColor(color);
  final luminosidad = (hsl.lightness - cantidad).clamp(0.0, 1.0);
  return hsl.withLightness(luminosidad).toColor();
}

class FondoSaludoPainter extends CustomPainter {
  final Color color;

  FondoSaludoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final pintura = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final curva = Path()
      ..moveTo(0, size.height * 0.88)
      ..quadraticBezierTo(
        size.width * 0.55,
        size.height * 1.18,
        size.width,
        size.height * 0.82,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(curva, pintura);
  }

  @override
  bool shouldRepaint(covariant FondoSaludoPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
