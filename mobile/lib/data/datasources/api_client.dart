import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// URL base de la API (mismo backend que usa la app web). Se puede
/// sobreescribir en build/run time con `--dart-define=API_BASE_URL=...`
/// (ej. para apuntar al backend desplegado en vez del local). Sin eso,
/// usa el backend local: el emulador de Android no puede resolver
/// `localhost` como el host de la máquina, así que usa la IP especial
/// `10.0.2.2`; iOS Simulator y macOS sí resuelven `localhost` directamente.
String get _baseUrl {
  const urlPersonalizada = String.fromEnvironment('API_BASE_URL');
  if (urlPersonalizada.isNotEmpty) return urlPersonalizada;

  if (Platform.isAndroid) {
    return 'http://10.0.2.2:5262/api';
  }
  return 'http://localhost:5262/api';
}

/// Excepción base para cualquier fallo al hablar con la API.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// 401 — token ausente/expirado, o credenciales inválidas en login.
class ApiUnauthorizedException extends ApiException {
  const ApiUnauthorizedException([super.message = 'No autorizado'])
    : super(statusCode: 401);
}

/// 404 — el recurso no existe o no pertenece al usuario autenticado.
class ApiNotFoundException extends ApiException {
  const ApiNotFoundException([super.message = 'No encontrado'])
    : super(statusCode: 404);
}

/// 409 — duplicado, o categoría en uso. `shortcutCount`/`commandCount` solo
/// vienen presentes en el caso de "categoría en uso al eliminar".
class ApiConflictException extends ApiException {
  final int? shortcutCount;
  final int? commandCount;

  const ApiConflictException(
    super.message, {
    this.shortcutCount,
    this.commandCount,
  }) : super(statusCode: 409);
}

/// 400 — validación fallida.
class ApiValidationException extends ApiException {
  const ApiValidationException([super.message = 'Datos inválidos'])
    : super(statusCode: 400);
}

/// Cliente HTTP delgado: agrega el token Bearer cuando hay sesión, codifica
/// bodies como JSON y traduce códigos de estado a las excepciones de arriba.
/// Sin caché, sin reintentos: la app es online-only, si falla la llamada
/// falla la operación (se muestra el error y ya).
class ApiClient {
  /// Instancia compartida por todos los repositorios: un solo lugar donde
  /// conectar `tokenProvider` (ver `main.dart`) en vez de repetirlo por
  /// cada repo.
  static final ApiClient instancia = ApiClient._();

  final http.Client _http;
  String? Function()? tokenProvider;

  ApiClient._({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  /// Para tests: permite construir un cliente aislado con su propio
  /// `http.Client` (mock) en vez de usar [instancia].
  factory ApiClient({http.Client? httpClient}) =>
      httpClient == null ? instancia : ApiClient._(httpClient: httpClient);

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$_baseUrl$path').replace(queryParameters: query);

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final respuesta = await _http.get(_uri(path, query), headers: _headers);
    return _procesar(respuesta);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final respuesta = await _http.post(
      _uri(path),
      headers: _headers,
      body: body == null ? null : jsonEncode(body),
    );
    return _procesar(respuesta);
  }

  Future<dynamic> put(String path, {Object? body}) async {
    final respuesta = await _http.put(
      _uri(path),
      headers: _headers,
      body: body == null ? null : jsonEncode(body),
    );
    return _procesar(respuesta);
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    final respuesta = await _http.patch(
      _uri(path),
      headers: _headers,
      body: body == null ? null : jsonEncode(body),
    );
    return _procesar(respuesta);
  }

  Future<void> delete(String path) async {
    final respuesta = await _http.delete(_uri(path), headers: _headers);
    _procesar(respuesta);
  }

  dynamic _procesar(http.Response respuesta) {
    final cuerpo = respuesta.body.isEmpty ? null : jsonDecode(respuesta.body);

    if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
      return cuerpo;
    }

    final mensaje = (cuerpo is Map ? cuerpo['detail'] ?? cuerpo['message'] : null)
            ?.toString() ??
        'Ocurrió un error inesperado';

    switch (respuesta.statusCode) {
      case 400:
        throw ApiValidationException(mensaje);
      case 401:
        throw ApiUnauthorizedException(mensaje);
      case 404:
        throw ApiNotFoundException(mensaje);
      case 409:
        throw ApiConflictException(
          mensaje,
          shortcutCount: cuerpo is Map ? cuerpo['shortcutCount'] as int? : null,
          commandCount: cuerpo is Map ? cuerpo['commandCount'] as int? : null,
        );
      default:
        throw ApiException(mensaje, statusCode: respuesta.statusCode);
    }
  }
}
