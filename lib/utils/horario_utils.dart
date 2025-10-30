/// Utilidades para manejo de horarios de farmacias
class HorarioUtils {
  /// Determina si una farmacia está abierta actualmente
  /// Si es de turno (24hrs), siempre está abierta
  static bool estaAbierta({
    required bool esDeTurno,
    required String horaApertura,
    required String horaCierre,
  }) {
    // Si es de turno, está abierta 24 horas
    if (esDeTurno) {
      return true;
    }

    // Si no tiene horarios definidos, asumimos cerrada
    if (horaApertura.isEmpty || horaCierre.isEmpty) {
      return false;
    }

    try {
      final now = DateTime.now();
      final apertura = _parseHora(horaApertura);
      final cierre = _parseHora(horaCierre);

      if (apertura == null || cierre == null) {
        return false;
      }

      // Crear DateTime para hoy con las horas de apertura y cierre
      final aperturaHoy = DateTime(
        now.year,
        now.month,
        now.day,
        apertura.hour,
        apertura.minute,
      );

      var cierreHoy = DateTime(
        now.year,
        now.month,
        now.day,
        cierre.hour,
        cierre.minute,
      );

      // Si la hora de cierre es menor que la de apertura,
      // significa que cierra al día siguiente
      if (cierre.hour < apertura.hour || 
          (cierre.hour == apertura.hour && cierre.minute < apertura.minute)) {
        cierreHoy = cierreHoy.add(const Duration(days: 1));
      }

      return now.isAfter(aperturaHoy) && now.isBefore(cierreHoy);
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el estado de la farmacia como texto
  static String obtenerEstado({
    required bool esDeTurno,
    required String horaApertura,
    required String horaCierre,
  }) {
    if (esDeTurno) {
      return 'Abierto 24 horas';
    }

    if (estaAbierta(
      esDeTurno: esDeTurno,
      horaApertura: horaApertura,
      horaCierre: horaCierre,
    )) {
      return 'Abierto ahora';
    }

    return 'Cerrado';
  }

  /// Formatea el horario para mostrar
  static String formatearHorario({
    required bool esDeTurno,
    required String horaApertura,
    required String horaCierre,
  }) {
    if (esDeTurno) {
      return '24 horas';
    }

    if (horaApertura.isEmpty || horaCierre.isEmpty) {
      return 'Horario no disponible';
    }

    final apertura = _formatearHora(horaApertura);
    final cierre = _formatearHora(horaCierre);

    return '$apertura - $cierre';
  }

  /// Parsea una hora en formato HH:mm:ss o HH:mm
  static DateTime? _parseHora(String hora) {
    try {
      final parts = hora.split(':');
      if (parts.length < 2) return null;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return null;
      }

      return DateTime(2000, 1, 1, hour, minute);
    } catch (e) {
      return null;
    }
  }

  /// Formatea una hora para mostrar (HH:mm)
  static String _formatearHora(String hora) {
    try {
      final dt = _parseHora(hora);
      if (dt == null) return hora;

      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return hora;
    }
  }
}
