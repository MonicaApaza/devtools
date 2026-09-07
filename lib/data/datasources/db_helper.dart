import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../datos_estaticos/categorias.dart';
import '../modelos/modelo_categoria.dart';
import '../modelos/modelo_comando.dart';
import '../modelos/modelo_shortcut.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static Database? _db;

  static const String dbName = 'quickdev.db';
  static const int dbVersion = 4;

  // Usuario al que se le asigna todo lo que ya existía en el dispositivo
  // antes de que shortcuts/comandos/categorías tuvieran dueño (versión 4).
  static const _usuarioPorDefecto = 'Monica';

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, dbName);
    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE shortcut (
        pkShortcut INTEGER PRIMARY KEY AUTOINCREMENT,
        tituloShortcut TEXT NOT NULL,
        teclasShortcut TEXT NOT NULL,
        descripcionShortcut TEXT,
        categoriaShortcut TEXT NOT NULL,
        etiquetasShortcut TEXT,
        favoritoShortcut INTEGER NOT NULL DEFAULT 0,
        creadoEnShortcut INTEGER NOT NULL,
        usuarioShortcut TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE comando (
        pkComando INTEGER PRIMARY KEY AUTOINCREMENT,
        tituloComando TEXT NOT NULL,
        textoComando TEXT NOT NULL,
        descripcionComando TEXT,
        categoriaComando TEXT NOT NULL,
        etiquetasComando TEXT,
        favoritoComando INTEGER NOT NULL DEFAULT 0,
        creadoEnComando INTEGER NOT NULL,
        usosComando INTEGER NOT NULL DEFAULT 0,
        usuarioComando TEXT NOT NULL
      )
    ''');

    await _crearTablaCategoria(db);
    await _sembrarCategorias(db);
    await _sembrarDatos(db);
  }

  static Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Forma original de la tabla (sin usuarioCategoria): si hace falta,
      // el paso `oldVersion < 4` de más abajo la lleva a su forma final
      // antes de sembrarla, para que _sembrarCategorias no falle insertando
      // una columna que todavía no existe.
      await _crearTablaCategoriaOriginal(db);
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE comando ADD COLUMN usosComando INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 4) {
      await _migrarAUsuarios(db);
    }
    if (oldVersion < 2) {
      await _sembrarCategorias(db);
    }
  }

  // Forma final (versión 4): usada por instalaciones nuevas.
  static Future _crearTablaCategoria(Database db) async {
    await db.execute('''
      CREATE TABLE categoria (
        pkCategoria INTEGER PRIMARY KEY AUTOINCREMENT,
        idCategoria TEXT NOT NULL,
        nombreCategoria TEXT NOT NULL,
        iconoCategoria TEXT NOT NULL,
        tipoCategoria TEXT NOT NULL,
        creadoEnCategoria INTEGER NOT NULL,
        usuarioCategoria TEXT NOT NULL,
        UNIQUE(idCategoria, tipoCategoria, usuarioCategoria)
      )
    ''');
  }

  // Forma original (versiones 2-3, antes de que existiera usuarioCategoria).
  // Solo la usa el upgrade desde la versión 1.
  static Future _crearTablaCategoriaOriginal(Database db) async {
    await db.execute('''
      CREATE TABLE categoria (
        pkCategoria INTEGER PRIMARY KEY AUTOINCREMENT,
        idCategoria TEXT NOT NULL,
        nombreCategoria TEXT NOT NULL,
        iconoCategoria TEXT NOT NULL,
        tipoCategoria TEXT NOT NULL,
        creadoEnCategoria INTEGER NOT NULL,
        UNIQUE(idCategoria, tipoCategoria)
      )
    ''');
  }

  // A partir de la versión 4, cada shortcut/comando/categoría pertenece a
  // un usuario. Todo lo que ya existía en el dispositivo queda asignado a
  // _usuarioPorDefecto, para no perderlo ni dejarlo huérfano.
  static Future<void> _migrarAUsuarios(Database db) async {
    await db.execute(
      "ALTER TABLE shortcut ADD COLUMN usuarioShortcut TEXT NOT NULL DEFAULT '$_usuarioPorDefecto'",
    );
    await db.execute(
      "ALTER TABLE comando ADD COLUMN usuarioComando TEXT NOT NULL DEFAULT '$_usuarioPorDefecto'",
    );

    // categoria tiene un UNIQUE(idCategoria, tipoCategoria) que debe
    // ampliarse a (idCategoria, tipoCategoria, usuarioCategoria); SQLite no
    // permite modificar un UNIQUE existente con ALTER TABLE, así que se
    // reconstruye la tabla completa.
    await db.execute('ALTER TABLE categoria RENAME TO categoria_vieja');
    await _crearTablaCategoria(db);
    await db.execute('''
      INSERT INTO categoria
        (pkCategoria, idCategoria, nombreCategoria, iconoCategoria, tipoCategoria, creadoEnCategoria, usuarioCategoria)
      SELECT pkCategoria, idCategoria, nombreCategoria, iconoCategoria, tipoCategoria, creadoEnCategoria, '$_usuarioPorDefecto'
      FROM categoria_vieja
    ''');
    await db.execute('DROP TABLE categoria_vieja');
  }

  // Categorías por defecto, iguales a las que antes estaban fijas en
  // código (lib/datos/categorias.dart), para que los shortcuts/comandos
  // ya guardados sigan resolviendo a una categoría válida.
  static Future _sembrarCategorias(Database db) async {
    const shortcuts = [
      ('vscode', 'VS Code', 'code'),
      ('android', 'Android Studio', 'developer_mode'),
      ('intellij', 'IntelliJ', 'diamond'),
      ('git', 'Git', 'git'),
      ('terminal', 'Terminal', 'terminal'),
      ('browser', 'Navegador', 'browser'),
      ('flutter', 'Flutter', 'flutter'),
    ];
    const comandos = [
      ('git', 'Git', 'git'),
      ('flutter', 'Flutter', 'flutter'),
      ('terminal', 'Terminal', 'terminal'),
      ('pub', 'Pub', 'pub'),
    ];

    for (final (id, nombre, icono) in shortcuts) {
      await db.insert(
        'categoria',
        ModeloCategoria(
          idCategoria: id,
          nombreCategoria: nombre,
          iconoCategoria: icono,
          tipoCategoria: 'shortcut',
          usuarioCategoria: _usuarioPorDefecto,
        ).toMap(),
      );
    }
    for (final (id, nombre, icono) in comandos) {
      await db.insert(
        'categoria',
        ModeloCategoria(
          idCategoria: id,
          nombreCategoria: nombre,
          iconoCategoria: icono,
          tipoCategoria: 'comando',
          usuarioCategoria: _usuarioPorDefecto,
        ).toMap(),
      );
    }
  }

  static Future<void> _sembrarDatos(Database db) async {
    final ahora = DateTime.now().millisecondsSinceEpoch;
    int t(int minutosAtras) => ahora - minutosAtras * 60000;

    final shortcuts = [
      ModeloShortcut(
        tituloShortcut: 'Paleta de comandos',
        teclasShortcut: 'Ctrl+Shift+P',
        descripcionShortcut:
            'Abre la paleta de comandos para ejecutar cualquier acción del editor.',
        categoriaShortcut: 'vscode',
        etiquetasShortcut: 'navegación,productividad',
        favoritoShortcut: 1,
        creadoEnShortcut: t(10),
        usuarioShortcut: _usuarioPorDefecto,
      ),
      ModeloShortcut(
        tituloShortcut: 'Buscar en archivos',
        teclasShortcut: 'Ctrl+Shift+F',
        descripcionShortcut:
            'Busca un texto en todos los archivos del proyecto abierto.',
        categoriaShortcut: 'vscode',
        etiquetasShortcut: 'búsqueda',
        creadoEnShortcut: t(30),
        usuarioShortcut: _usuarioPorDefecto,
      ),
      ModeloShortcut(
        tituloShortcut: 'Formatear documento',
        teclasShortcut: 'Shift+Alt+F',
        descripcionShortcut:
            'Aplica el formato configurado a todo el archivo actual.',
        categoriaShortcut: 'vscode',
        etiquetasShortcut: 'formato',
        creadoEnShortcut: t(60),
        usuarioShortcut: _usuarioPorDefecto,
      ),
      ModeloShortcut(
        tituloShortcut: 'Ir a definición',
        teclasShortcut: 'F12',
        descripcionShortcut:
            'Salta a la definición del símbolo bajo el cursor.',
        categoriaShortcut: 'vscode',
        etiquetasShortcut: 'navegación',
        creadoEnShortcut: t(120),
        usuarioShortcut: _usuarioPorDefecto,
      ),
      ModeloShortcut(
        tituloShortcut: 'Buscar en cualquier lugar',
        teclasShortcut: 'Shift+Shift',
        descripcionShortcut:
            'Búsqueda rápida de clases, archivos y acciones del IDE.',
        categoriaShortcut: 'android',
        etiquetasShortcut: 'búsqueda',
        favoritoShortcut: 1,
        creadoEnShortcut: t(200),
        usuarioShortcut: _usuarioPorDefecto,
      ),
      ModeloShortcut(
        tituloShortcut: 'Renombrar (Refactor)',
        teclasShortcut: 'Shift+F6',
        descripcionShortcut:
            'Renombra de forma segura una variable, clase o método.',
        categoriaShortcut: 'android',
        etiquetasShortcut: 'refactor',
        creadoEnShortcut: t(250),
        usuarioShortcut: _usuarioPorDefecto,
      ),
      ModeloShortcut(
        tituloShortcut: 'Optimizar imports',
        teclasShortcut: 'Ctrl+Alt+O',
        descripcionShortcut: 'Elimina imports no usados y ordena el resto.',
        categoriaShortcut: 'android',
        etiquetasShortcut: 'limpieza',
        creadoEnShortcut: t(300),
        usuarioShortcut: _usuarioPorDefecto,
      ),
      ModeloShortcut(
        tituloShortcut: 'Generar código',
        teclasShortcut: 'Alt+Insert',
        descripcionShortcut:
            'Genera getters, constructores y overrides automáticamente.',
        categoriaShortcut: 'intellij',
        etiquetasShortcut: 'productividad',
        creadoEnShortcut: t(340),
        usuarioShortcut: _usuarioPorDefecto,
      ),
      ModeloShortcut(
        tituloShortcut: 'Reformatear código',
        teclasShortcut: 'Ctrl+Alt+L',
        descripcionShortcut:
            'Aplica el estilo de código configurado al archivo actual.',
        categoriaShortcut: 'intellij',
        etiquetasShortcut: 'formato',
        creadoEnShortcut: t(400),
        usuarioShortcut: _usuarioPorDefecto,
      ),
      ModeloShortcut(
        tituloShortcut: 'Preparar cambios (Stage)',
        teclasShortcut: 'Ctrl+Shift+G',
        descripcionShortcut:
            'Abre el panel de control de versiones para preparar cambios.',
        categoriaShortcut: 'git',
        etiquetasShortcut: 'git',
        creadoEnShortcut: t(450),
        usuarioShortcut: _usuarioPorDefecto,
      ),
      ModeloShortcut(
        tituloShortcut: 'Confirmar commit',
        teclasShortcut: 'Ctrl+Enter',
        descripcionShortcut: 'Confirma el commit desde el cuadro de mensaje.',
        categoriaShortcut: 'git',
        etiquetasShortcut: 'git',
        favoritoShortcut: 1,
        creadoEnShortcut: t(500),
        usuarioShortcut: _usuarioPorDefecto,
      ),
      ModeloShortcut(
        tituloShortcut: 'Buscar en historial',
        teclasShortcut: 'Ctrl+R',
        descripcionShortcut:
            'Busca comandos ejecutados anteriormente en la sesión.',
        categoriaShortcut: 'terminal',
        etiquetasShortcut: 'historial',
        creadoEnShortcut: t(600),
        usuarioShortcut: _usuarioPorDefecto,
      ),
      ModeloShortcut(
        tituloShortcut: 'Limpiar pantalla',
        teclasShortcut: 'Ctrl+L',
        descripcionShortcut: 'Limpia la pantalla visible de la terminal.',
        categoriaShortcut: 'terminal',
        etiquetasShortcut: 'básico',
        creadoEnShortcut: t(650),
        usuarioShortcut: _usuarioPorDefecto,
      ),
      ModeloShortcut(
        tituloShortcut: 'Detener proceso',
        teclasShortcut: 'Ctrl+C',
        descripcionShortcut:
            'Envía una señal de interrupción al proceso activo.',
        categoriaShortcut: 'terminal',
        etiquetasShortcut: 'básico',
        creadoEnShortcut: t(2900),
        usuarioShortcut: _usuarioPorDefecto,
      ),
      ModeloShortcut(
        tituloShortcut: 'Abrir herramientas de desarrollo',
        teclasShortcut: 'F12',
        descripcionShortcut: 'Abre el panel de DevTools del navegador.',
        categoriaShortcut: 'browser',
        etiquetasShortcut: 'debug',
        creadoEnShortcut: t(700),
        usuarioShortcut: _usuarioPorDefecto,
      ),
      ModeloShortcut(
        tituloShortcut: 'Inspeccionar elemento',
        teclasShortcut: 'Ctrl+Shift+C',
        descripcionShortcut: 'Activa el selector de elementos del inspector.',
        categoriaShortcut: 'browser',
        etiquetasShortcut: 'debug',
        creadoEnShortcut: t(750),
        usuarioShortcut: _usuarioPorDefecto,
      ),
      ModeloShortcut(
        tituloShortcut: 'Hot reload',
        teclasShortcut: 'Ctrl+F5',
        descripcionShortcut:
            'Aplica los cambios de código sin perder el estado de la app.',
        categoriaShortcut: 'flutter',
        etiquetasShortcut: 'flutter',
        favoritoShortcut: 1,
        creadoEnShortcut: t(800),
        usuarioShortcut: _usuarioPorDefecto,
      ),
      ModeloShortcut(
        tituloShortcut: 'Hot restart',
        teclasShortcut: 'Ctrl+Shift+F5',
        descripcionShortcut:
            'Reinicia la app conservando la sesión de depuración.',
        categoriaShortcut: 'flutter',
        etiquetasShortcut: 'flutter',
        creadoEnShortcut: t(850),
        usuarioShortcut: _usuarioPorDefecto,
      ),
    ];

    final comandos = [
      ModeloComando(
        tituloComando: 'Ver estado del repo',
        textoComando: 'git status',
        descripcionComando:
            'Muestra archivos modificados, agregados y en preparación.',
        categoriaComando: 'git',
        etiquetasComando: 'básico',
        favoritoComando: 1,
        creadoEnComando: t(60),
        usuarioComando: _usuarioPorDefecto,
      ),
      ModeloComando(
        tituloComando: 'Crear un commit',
        textoComando: 'git commit -m "mensaje"',
        descripcionComando:
            'Guarda los cambios preparados con un mensaje descriptivo.',
        categoriaComando: 'git',
        etiquetasComando: 'git',
        creadoEnComando: t(120),
        usuarioComando: _usuarioPorDefecto,
      ),
      ModeloComando(
        tituloComando: 'Deshacer último commit',
        textoComando: 'git reset --soft HEAD~1',
        descripcionComando:
            'Revierte el último commit conservando los cambios.',
        categoriaComando: 'git',
        etiquetasComando: 'avanzado',
        creadoEnComando: t(180),
        usuarioComando: _usuarioPorDefecto,
      ),
      ModeloComando(
        tituloComando: 'Historial resumido',
        textoComando: 'git log --oneline --graph --all',
        descripcionComando:
            'Muestra el historial de commits en forma de árbol.',
        categoriaComando: 'git',
        etiquetasComando: 'historial',
        creadoEnComando: t(240),
        usuarioComando: _usuarioPorDefecto,
      ),
      ModeloComando(
        tituloComando: 'Crear proyecto Flutter',
        textoComando: 'flutter create mi_app',
        descripcionComando:
            'Genera la estructura inicial de un nuevo proyecto.',
        categoriaComando: 'flutter',
        etiquetasComando: 'inicio',
        favoritoComando: 1,
        creadoEnComando: t(300),
        usuarioComando: _usuarioPorDefecto,
      ),
      ModeloComando(
        tituloComando: 'Ejecutar en modo debug',
        textoComando: 'flutter run',
        descripcionComando:
            'Compila y ejecuta la app en el dispositivo conectado.',
        categoriaComando: 'flutter',
        etiquetasComando: 'básico',
        creadoEnComando: t(90),
        usuarioComando: _usuarioPorDefecto,
      ),
      ModeloComando(
        tituloComando: 'Limpiar build',
        textoComando: 'flutter clean',
        descripcionComando: 'Elimina los artefactos de compilación generados.',
        categoriaComando: 'flutter',
        etiquetasComando: 'mantenimiento',
        creadoEnComando: t(400),
        usuarioComando: _usuarioPorDefecto,
      ),
      ModeloComando(
        tituloComando: 'Analizar código',
        textoComando: 'flutter analyze',
        descripcionComando:
            'Revisa el proyecto en busca de errores y advertencias.',
        categoriaComando: 'flutter',
        etiquetasComando: 'calidad',
        creadoEnComando: t(450),
        usuarioComando: _usuarioPorDefecto,
      ),
      ModeloComando(
        tituloComando: 'Compilar APK release',
        textoComando: 'flutter build apk --release',
        descripcionComando:
            'Genera el instalador de Android listo para distribuir.',
        categoriaComando: 'flutter',
        etiquetasComando: 'build',
        creadoEnComando: t(500),
        usuarioComando: _usuarioPorDefecto,
      ),
      ModeloComando(
        tituloComando: 'Buscar archivo por nombre',
        textoComando: 'find . -name "*.dart"',
        descripcionComando:
            'Busca archivos por patrón dentro del directorio actual.',
        categoriaComando: 'terminal',
        etiquetasComando: 'búsqueda',
        creadoEnComando: t(550),
        usuarioComando: _usuarioPorDefecto,
      ),
      ModeloComando(
        tituloComando: 'Ver procesos activos',
        textoComando: 'ps aux | grep dart',
        descripcionComando:
            'Filtra los procesos en ejecución relacionados a Dart.',
        categoriaComando: 'terminal',
        etiquetasComando: 'debug',
        creadoEnComando: t(600),
        usuarioComando: _usuarioPorDefecto,
      ),
      ModeloComando(
        tituloComando: 'Instalar dependencias',
        textoComando: 'flutter pub get',
        descripcionComando: 'Descarga los paquetes definidos en pubspec.yaml.',
        categoriaComando: 'pub',
        etiquetasComando: 'básico',
        favoritoComando: 1,
        creadoEnComando: t(30),
        usuarioComando: _usuarioPorDefecto,
      ),
    ];

    for (final s in shortcuts) {
      await db.insert('shortcut', s.toMap());
    }
    for (final c in comandos) {
      await db.insert('comando', c.toMap());
    }
  }

  // ---------- Shortcuts ----------

  Future<int> insertarShortcut(ModeloShortcut shortcut) async {
    final db = await database;
    return await db.insert('shortcut', shortcut.toMap());
  }

  Future<void> actualizarShortcut(ModeloShortcut shortcut) async {
    final db = await database;
    await db.update(
      'shortcut',
      shortcut.toMap(),
      where: 'pkShortcut = ?',
      whereArgs: [shortcut.pkShortcut],
    );
  }

  Future<void> eliminarShortcut(int pkShortcut) async {
    final db = await database;
    await db.delete(
      'shortcut',
      where: 'pkShortcut = ?',
      whereArgs: [pkShortcut],
    );
  }

  Future<List<ModeloShortcut>> getShortcuts(String usuario) async {
    final db = await database;
    final maps = await db.query(
      'shortcut',
      where: 'usuarioShortcut = ?',
      whereArgs: [usuario],
      orderBy: 'creadoEnShortcut DESC',
    );
    return List.generate(maps.length, (i) => ModeloShortcut.fromMap(maps[i]));
  }

  Future<bool> existeTituloShortcut(
    String titulo,
    String usuario, {
    int? excluirPk,
  }) async {
    final db = await database;
    final result = await db.query(
      'shortcut',
      columns: ['pkShortcut'],
      where: excluirPk == null
          ? 'tituloShortcut = ? AND usuarioShortcut = ?'
          : 'tituloShortcut = ? AND usuarioShortcut = ? AND pkShortcut != ?',
      whereArgs: excluirPk == null
          ? [titulo, usuario]
          : [titulo, usuario, excluirPk],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // ---------- Comandos ----------

  Future<int> insertarComando(ModeloComando comando) async {
    final db = await database;
    return await db.insert('comando', comando.toMap());
  }

  Future<void> actualizarComando(ModeloComando comando) async {
    final db = await database;
    await db.update(
      'comando',
      comando.toMap(),
      where: 'pkComando = ?',
      whereArgs: [comando.pkComando],
    );
  }

  Future<void> eliminarComando(int pkComando) async {
    final db = await database;
    await db.delete('comando', where: 'pkComando = ?', whereArgs: [pkComando]);
  }

  Future<void> incrementarUsoComando(int pkComando) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE comando SET usosComando = usosComando + 1 WHERE pkComando = ?',
      [pkComando],
    );
  }

  Future<List<ModeloComando>> getComandos(String usuario) async {
    final db = await database;
    final maps = await db.query(
      'comando',
      where: 'usuarioComando = ?',
      whereArgs: [usuario],
      orderBy: 'creadoEnComando DESC',
    );
    return List.generate(maps.length, (i) => ModeloComando.fromMap(maps[i]));
  }

  Future<bool> existeTituloComando(
    String titulo,
    String usuario, {
    int? excluirPk,
  }) async {
    final db = await database;
    final result = await db.query(
      'comando',
      columns: ['pkComando'],
      where: excluirPk == null
          ? 'tituloComando = ? AND usuarioComando = ?'
          : 'tituloComando = ? AND usuarioComando = ? AND pkComando != ?',
      whereArgs: excluirPk == null
          ? [titulo, usuario]
          : [titulo, usuario, excluirPk],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // ---------- Categorías ----------

  // Una categoría 'ambos' es visible tanto para shortcuts como para
  // comandos, así que se incluye junto a las del tipo pedido.
  Future<List<ModeloCategoria>> getCategoriasModelo(
    String tipo,
    String usuario,
  ) async {
    final db = await database;
    final maps = await db.query(
      'categoria',
      where:
          '(tipoCategoria = ? OR tipoCategoria = ?) AND usuarioCategoria = ?',
      whereArgs: [tipo, 'ambos', usuario],
      orderBy: 'nombreCategoria ASC',
    );
    return List.generate(maps.length, (i) => ModeloCategoria.fromMap(maps[i]));
  }

  Future<List<Categoria>> getCategorias(String tipo, String usuario) async {
    final modelos = await getCategoriasModelo(tipo, usuario);
    return modelos
        .map(
          (m) => Categoria(
            id: m.idCategoria,
            nombre: m.nombreCategoria,
            icono: iconoPorClave(m.iconoCategoria),
          ),
        )
        .toList();
  }

  // Los tipos que comparten la lista visible con `tipo`: una categoría
  // 'ambos' aparece junto a 'shortcut' y junto a 'comando', y si `tipo` es
  // 'ambos' compite con las tres, porque terminará mezclada con todas.
  List<String> _tiposVisibles(String tipo) => tipo == 'ambos'
      ? const ['shortcut', 'comando', 'ambos']
      : [tipo, 'ambos'];

  Future<bool> existeNombreCategoria(
    String tipo,
    String nombre,
    String usuario, {
    int? excluirPk,
  }) async {
    final db = await database;
    final tipos = _tiposVisibles(tipo);
    final placeholders = List.filled(tipos.length, '?').join(', ');
    final where = excluirPk == null
        ? 'tipoCategoria IN ($placeholders) AND nombreCategoria = ? AND usuarioCategoria = ?'
        : 'tipoCategoria IN ($placeholders) AND nombreCategoria = ? AND usuarioCategoria = ? AND pkCategoria != ?';
    final result = await db.query(
      'categoria',
      columns: ['pkCategoria'],
      where: where,
      whereArgs: excluirPk == null
          ? [...tipos, nombre, usuario]
          : [...tipos, nombre, usuario, excluirPk],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<String> _generarIdCategoria(
    Database db,
    String tipo,
    String nombre,
    String usuario,
  ) async {
    final base = nombre
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final slugBase = base.isEmpty ? 'categoria' : base;
    final tipos = _tiposVisibles(tipo);
    final placeholders = List.filled(tipos.length, '?').join(', ');
    var candidato = slugBase;
    var sufijo = 1;
    while (true) {
      final result = await db.query(
        'categoria',
        columns: ['pkCategoria'],
        where:
            'tipoCategoria IN ($placeholders) AND idCategoria = ? AND usuarioCategoria = ?',
        whereArgs: [...tipos, candidato, usuario],
        limit: 1,
      );
      if (result.isEmpty) return candidato;
      sufijo++;
      candidato = '${slugBase}_$sufijo';
    }
  }

  Future<void> insertarCategoria({
    required String tipo,
    required String nombre,
    required String iconoClave,
    required String usuario,
  }) async {
    final db = await database;
    final id = await _generarIdCategoria(db, tipo, nombre, usuario);
    await db.insert(
      'categoria',
      ModeloCategoria(
        idCategoria: id,
        nombreCategoria: nombre,
        iconoCategoria: iconoClave,
        tipoCategoria: tipo,
        usuarioCategoria: usuario,
      ).toMap(),
    );
  }

  Future<void> actualizarCategoria(ModeloCategoria categoria) async {
    final db = await database;
    await db.update(
      'categoria',
      categoria.toMap(),
      where: 'pkCategoria = ?',
      whereArgs: [categoria.pkCategoria],
    );
  }

  Future<void> eliminarCategoria(int pkCategoria) async {
    final db = await database;
    await db.delete(
      'categoria',
      where: 'pkCategoria = ?',
      whereArgs: [pkCategoria],
    );
  }

  // Para una categoría 'ambos' cuenta el uso en las dos tablas, porque
  // tanto shortcuts como comandos pueden estar apuntando a su idCategoria.
  // Se limita al mismo usuario dueño de la categoría: dos usuarios distintos
  // pueden tener categorías con el mismo idCategoria (p. ej. 'git') sin que
  // el conteo de uno se mezcle con el del otro.
  Future<int> contarUsoCategoria(
    String tipo,
    String idCategoria,
    String usuario,
  ) async {
    if (tipo == 'ambos') {
      final enShortcuts = await contarUsoCategoria(
        'shortcut',
        idCategoria,
        usuario,
      );
      final enComandos = await contarUsoCategoria(
        'comando',
        idCategoria,
        usuario,
      );
      return enShortcuts + enComandos;
    }
    final db = await database;
    final tabla = tipo == 'shortcut' ? 'shortcut' : 'comando';
    final columnaCategoria = tipo == 'shortcut'
        ? 'categoriaShortcut'
        : 'categoriaComando';
    final columnaUsuario = tipo == 'shortcut'
        ? 'usuarioShortcut'
        : 'usuarioComando';
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM $tabla WHERE $columnaCategoria = ? AND $columnaUsuario = ?',
      [idCategoria, usuario],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
