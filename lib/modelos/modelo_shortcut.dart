class ModeloShortcut {
  int? pkShortcut;
  String tituloShortcut;
  String teclasShortcut;
  String descripcionShortcut;
  String categoriaShortcut;
  String etiquetasShortcut;
  int favoritoShortcut;
  int creadoEnShortcut;

  ModeloShortcut({
    this.pkShortcut,
    required this.tituloShortcut,
    required this.teclasShortcut,
    this.descripcionShortcut = '',
    required this.categoriaShortcut,
    this.etiquetasShortcut = '',
    this.favoritoShortcut = 0,
    int? creadoEnShortcut,
  }) : creadoEnShortcut = creadoEnShortcut ?? DateTime.now().millisecondsSinceEpoch;

  List<String> get teclas =>
      teclasShortcut.split('+').map((k) => k.trim()).where((k) => k.isNotEmpty).toList();

  List<String> get etiquetas => etiquetasShortcut
      .split(',')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();

  bool get esFavorito => favoritoShortcut == 1;

  Map<String, dynamic> toMap() {
    return {
      'pkShortcut': pkShortcut,
      'tituloShortcut': tituloShortcut,
      'teclasShortcut': teclasShortcut,
      'descripcionShortcut': descripcionShortcut,
      'categoriaShortcut': categoriaShortcut,
      'etiquetasShortcut': etiquetasShortcut,
      'favoritoShortcut': favoritoShortcut,
      'creadoEnShortcut': creadoEnShortcut,
    };
  }

  static ModeloShortcut fromMap(Map<String, dynamic> map) {
    return ModeloShortcut(
      pkShortcut: map['pkShortcut'],
      tituloShortcut: map['tituloShortcut'],
      teclasShortcut: map['teclasShortcut'],
      descripcionShortcut: map['descripcionShortcut'] ?? '',
      categoriaShortcut: map['categoriaShortcut'],
      etiquetasShortcut: map['etiquetasShortcut'] ?? '',
      favoritoShortcut: map['favoritoShortcut'] ?? 0,
      creadoEnShortcut: map['creadoEnShortcut'],
    );
  }
}
