import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Servicio para gestionar analytics y reportes de errores con Firebase
class AnalyticsService {
  static FirebaseAnalytics? _analytics;
  static FirebaseCrashlytics? _crashlytics;
  static bool _initialized = false;
  
  /// Verifica e inicializa Firebase si está disponible
  static void _ensureInitialized() {
    if (_initialized) return;
    
    try {
      if (Firebase.apps.isNotEmpty) {
        _analytics = FirebaseAnalytics.instance;
        _crashlytics = FirebaseCrashlytics.instance;
        _initialized = true;
      }
    } catch (e) {
      // Firebase no está disponible (probablemente en tests)
      if (kDebugMode) {
        print('Firebase no disponible: $e');
      }
    }
  }

  /// Obtiene el observer de navegación para analytics
  static FirebaseAnalyticsObserver get observer {
    _ensureInitialized();
    if (_analytics != null) {
      return FirebaseAnalyticsObserver(analytics: _analytics!);
    }
    // En tests, retornar un observer no funcional
    throw UnsupportedError('Firebase Analytics no está inicializado');
  }

  /// Registra un evento de búsqueda de farmacias
  static Future<void> logBusquedaFarmacias({
    required String metodo,
    required int resultados,
    double? radioKm,
    String? comuna,
  }) async {
    await _analytics?.logEvent(
      name: 'busqueda_farmacias',
      parameters: {
        'metodo': metodo, // 'gps' o 'manual'
        'resultados': resultados,
        if (radioKm != null) 'radio_km': radioKm,
        if (comuna != null) 'comuna': comuna,
      },
    );
  }

  /// Registra cuando se visualiza el detalle de una farmacia
  static Future<void> logVerDetalleFarmacia({
    required String farmaciaId,
    required String farmaciaNombre,
    required bool esDeTurno,
    double? distanciaKm,
  }) async {
    await _analytics?.logEvent(
      name: 'ver_detalle_farmacia',
      parameters: {
        'farmacia_id': farmaciaId,
        'farmacia_nombre': farmaciaNombre,
        'es_de_turno': esDeTurno,
        if (distanciaKm != null) 'distancia_km': distanciaKm,
      },
    );
  }

  /// Registra cuando se llama a una farmacia
  static Future<void> logLlamarFarmacia({
    required String farmaciaId,
    required String farmaciaNombre,
  }) async {
    await _analytics?.logEvent(
      name: 'llamar_farmacia',
      parameters: {
        'farmacia_id': farmaciaId,
        'farmacia_nombre': farmaciaNombre,
      },
    );
  }

  /// Registra cuando se abre el mapa de una farmacia
  static Future<void> logAbrirMapa({
    required String farmaciaId,
    required String farmaciaNombre,
  }) async {
    await _analytics?.logEvent(
      name: 'abrir_mapa',
      parameters: {
        'farmacia_id': farmaciaId,
        'farmacia_nombre': farmaciaNombre,
      },
    );
  }

  /// Registra cuando se aplican filtros
  static Future<void> logAplicarFiltros({
    required bool soloTurno,
    required bool soloAbiertas,
    String? comuna,
  }) async {
    await _analytics?.logEvent(
      name: 'aplicar_filtros',
      parameters: {
        'solo_turno': soloTurno,
        'solo_abiertas': soloAbiertas,
        if (comuna != null) 'comuna': comuna,
      },
    );
  }

  /// Registra cambio de tema
  static Future<void> logCambioTema({
    required String modoTema,
  }) async {
    await _analytics?.logEvent(
      name: 'cambio_tema',
      parameters: {'modo': modoTema}, // 'light', 'dark', 'system'
    );
  }

  /// Registra cuando se visualiza la pantalla Acerca de
  static Future<void> logVerAcercaDe() async {
    await _analytics?.logEvent(name: 'ver_acerca_de');
  }

  /// Registra errores no fatales
  static Future<void> logError({
    required String error,
    required StackTrace stackTrace,
    String? contexto,
    Map<String, dynamic>? datosAdicionales,
  }) async {
    // Registrar en Crashlytics
    await _crashlytics?.recordError(
      error,
      stackTrace,
      reason: contexto,
      fatal: false,
    );

    // También registrar como evento de analytics
    await _analytics?.logEvent(
      name: 'error_no_fatal',
      parameters: {
        'error_mensaje': error.toString(),
        if (contexto != null) 'contexto': contexto,
        if (datosAdicionales != null) ...datosAdicionales,
      },
    );
  }

  /// Registra errores de API
  static Future<void> logApiError({
    required String endpoint,
    required String error,
    int? statusCode,
    StackTrace? stackTrace,
  }) async {
    final errorMessage = 'API Error: $endpoint - $error';
    
    await _crashlytics?.recordError(
      errorMessage,
      stackTrace ?? StackTrace.current,
      reason: 'Error en llamada a API del MINSAL',
      fatal: false,
    );

    await _analytics?.logEvent(
      name: 'error_api',
      parameters: {
        'endpoint': endpoint,
        'error': error,
        if (statusCode != null) 'status_code': statusCode,
      },
    );
  }

  /// Registra errores de permisos
  static Future<void> logPermisoError({
    required String permiso,
    required String estado,
  }) async {
    await _analytics?.logEvent(
      name: 'error_permiso',
      parameters: {
        'permiso': permiso, // 'ubicacion'
        'estado': estado, // 'denegado', 'denegado_permanente', 'deshabilitado'
      },
    );
  }

  /// Establece propiedades de usuario personalizadas
  static Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics?.setUserProperty(name: name, value: value);
  }

  /// Registra la pantalla actual (se hace automáticamente con el observer)
  static Future<void> setCurrentScreen({
    required String screenName,
  }) async {
    await _analytics?.logScreenView(
      screenName: screenName,
    );
  }

  /// Configura información adicional de contexto en Crashlytics
  static Future<void> setCustomKey({
    required String key,
    required String value,
  }) async {
    await _crashlytics?.setCustomKey(key, value);
  }

  /// Habilita o deshabilita la recopilación de datos
  static Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    await _analytics?.setAnalyticsCollectionEnabled(enabled);
  }

  /// Habilita o deshabilita Crashlytics
  static Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    await _crashlytics?.setCrashlyticsCollectionEnabled(enabled);
  }
}
