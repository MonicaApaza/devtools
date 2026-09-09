/// Convierte el tipo local ('shortcut'/'comando'/'ambos') al valor que
/// espera el backend (`CategoryType`: Shortcut/Command/Both).
String tipoCategoriaAApi(String tipoLocal) => switch (tipoLocal) {
  'shortcut' => 'Shortcut',
  'comando' => 'Command',
  _ => 'Both',
};

/// Inverso de [tipoCategoriaAApi], para leer categorías que vienen del
/// backend.
String tipoCategoriaDesdeApi(String tipoApi) => switch (tipoApi) {
  'Shortcut' => 'shortcut',
  'Command' => 'comando',
  _ => 'ambos',
};

class ModeloCategoria {
  /// GUID asignado por el backend (`Category.Id`). `null` solo antes de
  /// crearla.
  String? pkCategoria;
  String nombreCategoria;
  String iconoCategoria;
  String tipoCategoria; // 'shortcut' | 'comando' | 'ambos'
  int creadoEnCategoria;

  ModeloCategoria({
    this.pkCategoria,
    required this.nombreCategoria,
    required this.iconoCategoria,
    required this.tipoCategoria,
    int? creadoEnCategoria,
  }) : creadoEnCategoria =
           creadoEnCategoria ?? DateTime.now().millisecondsSinceEpoch;

  factory ModeloCategoria.fromApi(Map<String, dynamic> json) =>
      ModeloCategoria(
        pkCategoria: json['id'] as String,
        nombreCategoria: json['name'] as String,
        iconoCategoria: json['icon'] as String,
        tipoCategoria: tipoCategoriaDesdeApi(json['type'] as String),
        creadoEnCategoria: DateTime.parse(
          json['createdAt'] as String,
        ).millisecondsSinceEpoch,
      );

  Map<String, dynamic> toApiBody() => {
    'name': nombreCategoria,
    'icon': iconoCategoria,
    'type': tipoCategoriaAApi(tipoCategoria),
  };
}
