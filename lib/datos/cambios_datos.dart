import 'package:flutter/foundation.dart';

/// Avisa a quien esté escuchando (p. ej. HomeScreen) que los shortcuts o
/// comandos cambiaron en la base de datos, sin que las pantallas necesiten
/// conocerse entre sí. Mismo patrón que ThemeController, pero para datos.
class CambiosDatos extends ChangeNotifier {
  CambiosDatos._internal();
  static final CambiosDatos instance = CambiosDatos._internal();
  factory CambiosDatos() => instance;

  void avisar() => notifyListeners();
}
