class ModeloShortcut {
  /// GUID asignado por el backend (`Shortcut.Id`). `null` solo antes de
  /// crearlo.
  String? pkShortcut;
  String tituloShortcut;
  String teclasShortcut;
  String descripcionShortcut;
  /// GUID de la categoría (backend), no una clave estática.
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
  }) : creadoEnShortcut =
           creadoEnShortcut ?? DateTime.now().millisecondsSinceEpoch;

  List<String> get teclas => teclasShortcut
      .split('+')
      .map((k) => k.trim())
      .where((k) => k.isNotEmpty)
      .toList();

  List<String> get etiquetas => etiquetasShortcut
      .split(',')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();

  bool get esFavorito => favoritoShortcut == 1;

  factory ModeloShortcut.fromApi(Map<String, dynamic> json) => ModeloShortcut(
    pkShortcut: json['id'] as String,
    tituloShortcut: json['title'] as String,
    teclasShortcut: json['keys'] as String,
    descripcionShortcut: json['description'] as String? ?? '',
    categoriaShortcut: json['categoryId'] as String,
    etiquetasShortcut: (json['tags'] as List).cast<String>().join(','),
    favoritoShortcut: (json['isFavorite'] as bool) ? 1 : 0,
    creadoEnShortcut: DateTime.parse(
      json['createdAt'] as String,
    ).millisecondsSinceEpoch,
  );

  Map<String, dynamic> toApiBody() => {
    'title': tituloShortcut,
    'keys': teclasShortcut,
    'description': descripcionShortcut.isEmpty ? null : descripcionShortcut,
    'categoryId': categoriaShortcut,
    'tags': etiquetas,
  };
}
