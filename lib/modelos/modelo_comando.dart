class ModeloComando {
  int? pkComando;
  String tituloComando;
  String textoComando;
  String descripcionComando;
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
  }) : creadoEnComando = creadoEnComando ?? DateTime.now().millisecondsSinceEpoch;

  List<String> get etiquetas => etiquetasComando
      .split(',')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();

  bool get esFavorito => favoritoComando == 1;

  Map<String, dynamic> toMap() {
    return {
      'pkComando': pkComando,
      'tituloComando': tituloComando,
      'textoComando': textoComando,
      'descripcionComando': descripcionComando,
      'categoriaComando': categoriaComando,
      'etiquetasComando': etiquetasComando,
      'favoritoComando': favoritoComando,
      'creadoEnComando': creadoEnComando,
      'usosComando': usosComando,
    };
  }

  static ModeloComando fromMap(Map<String, dynamic> map) {
    return ModeloComando(
      pkComando: map['pkComando'],
      tituloComando: map['tituloComando'],
      textoComando: map['textoComando'],
      descripcionComando: map['descripcionComando'] ?? '',
      categoriaComando: map['categoriaComando'],
      etiquetasComando: map['etiquetasComando'] ?? '',
      favoritoComando: map['favoritoComando'] ?? 0,
      creadoEnComando: map['creadoEnComando'],
      usosComando: map['usosComando'] ?? 0,
    );
  }
}
