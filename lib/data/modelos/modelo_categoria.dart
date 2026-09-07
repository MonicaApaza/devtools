class ModeloCategoria {
  int? pkCategoria;
  String idCategoria;
  String nombreCategoria;
  String iconoCategoria;
  String tipoCategoria; // 'shortcut' o 'comando'
  int creadoEnCategoria;
  String usuarioCategoria;

  ModeloCategoria({
    this.pkCategoria,
    required this.idCategoria,
    required this.nombreCategoria,
    required this.iconoCategoria,
    required this.tipoCategoria,
    int? creadoEnCategoria,
    required this.usuarioCategoria,
  }) : creadoEnCategoria =
           creadoEnCategoria ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() {
    return {
      'pkCategoria': pkCategoria,
      'idCategoria': idCategoria,
      'nombreCategoria': nombreCategoria,
      'iconoCategoria': iconoCategoria,
      'tipoCategoria': tipoCategoria,
      'creadoEnCategoria': creadoEnCategoria,
      'usuarioCategoria': usuarioCategoria,
    };
  }

  static ModeloCategoria fromMap(Map<String, dynamic> map) {
    return ModeloCategoria(
      pkCategoria: map['pkCategoria'],
      idCategoria: map['idCategoria'],
      nombreCategoria: map['nombreCategoria'],
      iconoCategoria: map['iconoCategoria'],
      tipoCategoria: map['tipoCategoria'],
      creadoEnCategoria: map['creadoEnCategoria'],
      usuarioCategoria: map['usuarioCategoria'],
    );
  }
}
