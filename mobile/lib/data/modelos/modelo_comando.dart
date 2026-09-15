class ModeloComando {
  /// GUID asignado por el backend (`Command.Id`). `null` solo antes de
  /// crearlo.
  String? pkComando;
  String tituloComando;
  String textoComando;
  String descripcionComando;
  /// GUID de la categoría (backend), no una clave estática.
  String categoriaComando;
  String etiquetasComando;
  int favoritoComando;
  int creadoEnComando;
  int usosComando;

  ModeloComando({
    this.pkComando,
    required this.tituloComando,
    required this.textoComando,
    this.descripcionComando = '',
    required this.categoriaComando,
    this.etiquetasComando = '',
    this.favoritoComando = 0,
    int? creadoEnComando,
    this.usosComando = 0,
  }) : creadoEnComando =
           creadoEnComando ?? DateTime.now().millisecondsSinceEpoch;

  List<String> get etiquetas => etiquetasComando
      .split(',')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();

  bool get esFavorito => favoritoComando == 1;

  factory ModeloComando.fromApi(Map<String, dynamic> json) => ModeloComando(
    pkComando: json['id'] as String,
    tituloComando: json['title'] as String,
    textoComando: json['commandText'] as String,
    descripcionComando: json['description'] as String? ?? '',
    categoriaComando: json['categoryId'] as String,
    etiquetasComando: (json['tags'] as List).cast<String>().join(','),
    favoritoComando: (json['isFavorite'] as bool) ? 1 : 0,
    usosComando: json['usageCount'] as int? ?? 0,
    creadoEnComando: DateTime.parse(
      json['createdAt'] as String,
    ).millisecondsSinceEpoch,
  );

  Map<String, dynamic> toApiBody() => {
    'title': tituloComando,
    'commandText': textoComando,
    'description': descripcionComando.isEmpty ? null : descripcionComando,
    'categoryId': categoriaComando,
    'tags': etiquetas,
  };
}
