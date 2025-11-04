class AppConstants {
  // API URLs
  static const String localesApiUrl = 'https://midas.minsal.cl/farmacia_v2/WS/getLocales.php';
  static const String turnosApiUrl = 'https://midas.minsal.cl/farmacia_v2/WS/getLocalesTurnos.php';
  
  // Storage keys
  static const String keyFarmacias = 'farmacias_cache';
  static const String keyFarmaciasTurno = 'farmacias_turno_cache';
  static const String keyLastUpdateFarmacias = 'last_update_farmacias';
  static const String keyLastUpdateTurnos = 'last_update_turnos';
  static const String keyLastUpdateDay = 'last_update_day';
  
  // Default values
  static const double defaultRadius = 10.0;
  static const List<double> radiusOptions = [5.0, 10.0, 15.0, 20.0];
  
  // Colors (paleta azul/celeste/blanco, estilo salud)
  static const int primaryColorValue = 0xFF2196F3; // Azul hospital
  static const int secondaryColorValue = 0xFFB3E5FC; // Celeste claro
  static const int accentColorValue = 0xFF1565C0; // Azul profundo
  static const int textColorValue = 0xFF1565C0; // Azul profundo para texto
}