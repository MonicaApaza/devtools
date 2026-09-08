import 'package:flutter/material.dart';

/// Dos ondas superiores superpuestas. Sus proporciones siguen la disposición
/// del ejemplo de referencia: ocupan todo el ancho y se concentran a la
/// derecha, dejando libre el título del formulario.
class CurvaLoginPainter extends CustomPainter {
  final Color colorPrincipal;
  final Color colorAcento;

  CurvaLoginPainter({required this.colorPrincipal, required this.colorAcento});

  @override
  void paint(Canvas canvas, Size size) {
    final capaPosterior = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.84)
      ..cubicTo(
        size.width * 0.74,
        size.height * 0.96,
        size.width * 0.58,
        size.height * 0.94,
        size.width * 0.48,
        size.height * 0.65,
      )
      ..cubicTo(
        size.width * 0.37,
        size.height * 0.26,
        size.width * 0.25,
        size.height * 0.10,
        0,
        0,
      )
      ..close();
    canvas.drawPath(capaPosterior, Paint()..color = colorAcento);

    final capaFrontal = Path()
      // Ambas capas arrancan en el mismo punto: evita las dos puntas que
      // aparecían en el borde superior izquierdo.
      ..moveTo(0, 0)
      ..cubicTo(
        size.width * 0.25,
        0,
        size.width * 0.48,
        size.height * 0.09,
        size.width * 0.56,
        size.height * 0.21,
      )
      ..cubicTo(
        size.width * 0.66,
        size.height * 0.38,
        size.width * 0.69,
        size.height * 0.58,
        size.width * 0.79,
        size.height * 0.75,
      )
      ..cubicTo(
        size.width * 0.87,
        size.height * 0.88,
        size.width * 0.94,
        size.height * 0.96,
        size.width,
        size.height,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(capaFrontal, Paint()..color = colorPrincipal);
  }

  @override
  bool shouldRepaint(covariant CurvaLoginPainter oldDelegate) {
    return oldDelegate.colorPrincipal != colorPrincipal ||
        oldDelegate.colorAcento != colorAcento;
  }
}

/// Dos ondas inferiores que se interceptan en el centro, como las capas
/// `bottom1` y `bottom2` de la referencia.
class CurvasLoginInferioresPainter extends CustomPainter {
  final Color colorPrincipal;
  final Color colorAcento;

  CurvasLoginInferioresPainter({
    required this.colorPrincipal,
    required this.colorAcento,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final capaPosterior = Path()
      // Los extremos viven fuera del lienzo para que el recorte de pantalla
      // muestre una curva continua, sin picos en los bordes.
      ..moveTo(-size.width * 0.16, -size.height * 0.02)
      ..cubicTo(
        size.width * 0.14,
        -size.height * 0.01,
        size.width * 0.22,
        size.height * 0.98,
        size.width * 1.16,
        size.height * 0.64,
      )
      ..lineTo(size.width * 1.16, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(capaPosterior, Paint()..color = colorAcento);

    final capaFrontal = Path()
      ..moveTo(-size.width * 0.16, -size.height * 0.02)
      ..cubicTo(
        size.width * 0.08,
        size.height * 0.74,
        size.width * 0.44,
        size.height * 0.78,
        size.width * 1.16,
        size.height * 0.13,
      )
      ..lineTo(size.width * 1.16, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(capaFrontal, Paint()..color = colorPrincipal);
  }

  @override
  bool shouldRepaint(covariant CurvasLoginInferioresPainter oldDelegate) {
    return oldDelegate.colorPrincipal != colorPrincipal ||
        oldDelegate.colorAcento != colorAcento;
  }
}
