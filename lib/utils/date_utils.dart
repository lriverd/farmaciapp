import 'package:intl/intl.dart';

class DateUtils {
  static final DateFormat _dayFormat = DateFormat('EEEE', 'es');
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  /// Obtiene el nombre del día actual en español (ej: "lunes")
  static String getCurrentDayName() {
    return _dayFormat.format(DateTime.now()).toLowerCase();
  }

  /// Obtiene la fecha actual en formato yyyy-MM-dd
  static String getCurrentDate() {
    return _dateFormat.format(DateTime.now());
  }

  /// Convierte una fecha en formato dd-MM-yy a yyyy-MM-dd
  static String convertDateFormat(String dateString) {
    try {
      // Formato de entrada: dd-MM-yy
      List<String> parts = dateString.split('-');
      if (parts.length != 3) return getCurrentDate();
      
      String day = parts[0].padLeft(2, '0');
      String month = parts[1].padLeft(2, '0');
      String year = parts[2];
      
      // Convertir año de 2 dígitos a 4 dígitos
      int yearInt = int.parse(year);
      if (yearInt < 50) {
        yearInt += 2000;
      } else {
        yearInt += 1900;
      }
      
      return '$yearInt-$month-$day';
    } catch (e) {
      return getCurrentDate();
    }
  }

  /// Verifica si han pasado más de 24 horas desde la última actualización
  static bool shouldUpdateData(String? lastUpdateString) {
    if (lastUpdateString == null || lastUpdateString.isEmpty) {
      return true;
    }

    try {
      DateTime lastUpdate = DateTime.parse(lastUpdateString);
      DateTime now = DateTime.now();
      Duration difference = now.difference(lastUpdate);
      
      return difference.inHours >= 24;
    } catch (e) {
      return true;
    }
  }

  /// Verifica si el día ha cambiado desde la última actualización
  static bool hasDayChanged(String? lastDay) {
    if (lastDay == null || lastDay.isEmpty) {
      return true;
    }
    
    String currentDay = getCurrentDayName();
    return currentDay != lastDay;
  }

  /// Formatea una hora en formato HH:mm:ss a HH:mm
  static String formatTime(String timeString) {
    try {
      List<String> parts = timeString.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return timeString;
    } catch (e) {
      return timeString;
    }
  }
}