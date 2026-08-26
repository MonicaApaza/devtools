String tiempoRelativo(int milisegundos) {
  final diferencia = DateTime.now().difference(
    DateTime.fromMillisecondsSinceEpoch(milisegundos),
  );
  if (diferencia.inMinutes < 1) return 'Hace un momento';
  if (diferencia.inMinutes < 60) return 'Hace ${diferencia.inMinutes} min';
  if (diferencia.inHours < 24) {
    final horas = diferencia.inHours;
    return 'Hace $horas ${horas == 1 ? 'hora' : 'horas'}';
  }
  final dias = diferencia.inDays;
  return 'Hace $dias ${dias == 1 ? 'día' : 'días'}';
}
