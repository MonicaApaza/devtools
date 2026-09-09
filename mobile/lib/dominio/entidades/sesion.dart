/// Sesión autenticada contra el backend real (JWT). Reemplaza la sesión
/// puramente local de antes: ahora sí valida usuario/contraseña contra el
/// servidor y expira igual que en la app web.
class Sesion {
  final String userId;
  final String usuario;
  final String token;
  final DateTime expiraEn;

  const Sesion({
    required this.userId,
    required this.usuario,
    required this.token,
    required this.expiraEn,
  });

  bool get estaExpirada => DateTime.now().isAfter(expiraEn);

  factory Sesion.fromJson(Map<String, dynamic> json) => Sesion(
    userId: json['userId'] as String,
    usuario: json['username'] as String,
    token: json['token'] as String,
    expiraEn: DateTime.parse(json['expiresAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'username': usuario,
    'token': token,
    'expiresAt': expiraEn.toIso8601String(),
  };
}
