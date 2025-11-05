import 'package:geolocator/geolocator.dart';
import '../models/farmacia.dart';
import '../models/farmacia_con_distancia.dart';
import '../utils/distance_calculator.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'location_service.dart';

class FarmaciaService {
  /// Obtiene farmacias cercanas basadas en la ubicación del usuario
  static Future<List<FarmaciaConDistancia>> getFarmaciasCercanas({
    required double radius,
    Position? userPosition,
  }) async {
    try {
      // Obtener ubicación del usuario si no se proporciona
      userPosition ??= await LocationService.getCurrentPosition();
      if (userPosition == null) {
        throw FarmaciaServiceException('No se pudo obtener la ubicación del usuario');
      }

      // Obtener farmacias y turnos
      final farmacias = await _getFarmaciasActualizadas();
      final farmaciasTurnoIds = await _getFarmaciasTurnoActualizadas();

      // Filtrar farmacias dentro del radio y calcular distancias
      List<FarmaciaConDistancia> farmaciasCercanas = [];

      for (final farmacia in farmacias) {
        final distancia = DistanceCalculator.calculateDistance(
          userPosition.latitude,
          userPosition.longitude,
          farmacia.localLat,
          farmacia.localLng,
        );

        if (distancia <= radius) {
          final esDeTurno = farmaciasTurnoIds.contains(farmacia.localId);
          farmaciasCercanas.add(FarmaciaConDistancia(
            farmacia: farmacia,
            distancia: distancia,
            esDeTurno: esDeTurno,
          ));
        }
      }

      // Ordenar: primero las de turno, luego por distancia
      farmaciasCercanas.sort((a, b) {
        if (a.esDeTurno && !b.esDeTurno) return -1;
        if (!a.esDeTurno && b.esDeTurno) return 1;
        return a.distancia.compareTo(b.distancia);
      });

      return farmaciasCercanas;
    } on ApiException catch (e) {
      throw FarmaciaServiceException(_getUserFriendlyMessage(e.message));
    } catch (e) {
      if (e is FarmaciaServiceException) rethrow;
      throw FarmaciaServiceException('Error al obtener farmacias cercanas: ${e.toString()}');
    }
  }

  /// Obtiene farmacias por localidad (comuna o ciudad) sin geolocalización
  static Future<List<FarmaciaConDistancia>> getFarmaciasPorLocalidad({
    required String localidad,
  }) async {
    try {
      // Obtener farmacias y turnos
      final farmacias = await _getFarmaciasActualizadas();
      final farmaciasTurnoIds = await _getFarmaciasTurnoActualizadas();

      // Normalizar texto de búsqueda
      final localidadNormalizada = localidad.toLowerCase().trim();

      // Filtrar farmacias que coincidan con la localidad
      List<FarmaciaConDistancia> farmaciasEncontradas = [];

      for (final farmacia in farmacias) {
        final comunaNormalizada = farmacia.comunaNombre.toLowerCase();
        final localidadNombreNormalizada = farmacia.localidadNombre.toLowerCase();
        
        // Buscar coincidencias en comuna_nombre o localidad_nombre
        if (comunaNormalizada.contains(localidadNormalizada) || 
            localidadNombreNormalizada.contains(localidadNormalizada)) {
          final esDeTurno = farmaciasTurnoIds.contains(farmacia.localId);
          farmaciasEncontradas.add(FarmaciaConDistancia(
            farmacia: farmacia,
            distancia: 0.0, // No calculamos distancia sin geolocalización
            esDeTurno: esDeTurno,
          ));
        }
      }

      if (farmaciasEncontradas.isEmpty) {
        throw FarmaciaServiceException(
          'No se encontraron farmacias en "$localidad". '
          'Verifica el nombre de la comuna o ciudad.'
        );
      }

      // Ordenar: primero las de turno, luego alfabéticamente por nombre
      farmaciasEncontradas.sort((a, b) {
        if (a.esDeTurno && !b.esDeTurno) return -1;
        if (!a.esDeTurno && b.esDeTurno) return 1;
        return a.farmacia.localNombre.compareTo(b.farmacia.localNombre);
      });

      return farmaciasEncontradas;
    } on ApiException catch (e) {
      throw FarmaciaServiceException(_getUserFriendlyMessage(e.message));
    } catch (e) {
      if (e is FarmaciaServiceException) rethrow;
      throw FarmaciaServiceException('Error al buscar farmacias por localidad: ${e.toString()}');
    }
  }

  /// Convierte mensajes técnicos en mensajes amigables para el usuario
  static String _getUserFriendlyMessage(String technicalMessage) {
    if (technicalMessage.contains('conexión segura') ||
        technicalMessage.contains('fecha y hora')) {
      return 'Error de conexión segura.\n\n'
          'Posibles soluciones:\n'
          '• Verifique que la fecha y hora de su dispositivo sean correctas\n'
          '• Actualice su sistema operativo si es posible\n'
          '• Intente conectarse desde otra red WiFi';
    }
    
    if (technicalMessage.contains('Sin conexión') || 
        technicalMessage.contains('internet')) {
      return 'Sin conexión a internet.\n'
          'Verifique su conexión y vuelva a intentar.';
    }
    
    if (technicalMessage.contains('Tiempo de espera')) {
      return 'El servidor tardó demasiado en responder.\n'
          'Intente nuevamente en unos momentos.';
    }
    
    if (technicalMessage.contains('Error del servidor')) {
      return 'El servidor está experimentando problemas.\n'
          'Intente nuevamente más tarde.';
    }
    
    return technicalMessage;
  }

  /// Filtra farmacias según los criterios especificados
  static List<FarmaciaConDistancia> filtrarFarmacias(
    List<FarmaciaConDistancia> farmacias, {
    bool? soloTurno,
    String? comuna,
    String? region,
    String? nombreFarmacia,
  }) {
    List<FarmaciaConDistancia> resultado = List.from(farmacias);

    if (soloTurno == true) {
      resultado = resultado.where((f) => f.esDeTurno).toList();
    }

    if (comuna != null && comuna.isNotEmpty) {
      resultado = resultado.where((f) => 
        f.farmacia.comunaNombre.toLowerCase().contains(comuna.toLowerCase())
      ).toList();
    }

    if (region != null && region.isNotEmpty) {
      resultado = resultado.where((f) => 
        f.farmacia.fkRegion == region
      ).toList();
    }

    if (nombreFarmacia != null && nombreFarmacia.isNotEmpty) {
      resultado = resultado.where((f) => 
        f.farmacia.localNombre.toLowerCase().contains(nombreFarmacia.toLowerCase())
      ).toList();
    }

    return resultado;
  }

  /// Obtiene las comunas únicas de una lista de farmacias
  static List<String> obtenerComunas(List<FarmaciaConDistancia> farmacias) {
    final comunas = farmacias
        .map((f) => f.farmacia.comunaNombre)
        .where((comuna) => comuna.isNotEmpty)
        .toSet()
        .toList();
    
    comunas.sort();
    return comunas;
  }

  /// Obtiene las regiones únicas de una lista de farmacias
  static List<String> obtenerRegiones(List<FarmaciaConDistancia> farmacias) {
    final regiones = farmacias
        .map((f) => f.farmacia.fkRegion)
        .where((region) => region.isNotEmpty)
        .toSet()
        .toList();
    
    regiones.sort();
    return regiones;
  }

  /// Obtiene farmacias actualizadas (del caché o de la API)
  /// Combina farmacias de ambos endpoints (locales y turnos)
  /// También actualiza los IDs de turnos de forma sincronizada
  static Future<List<Farmacia>> _getFarmaciasActualizadas() async {
    try {
      // Verificar si necesitamos actualizar los datos
      // Usamos shouldUpdateFarmacias() O shouldUpdateTurnos() para asegurar 
      // que ambos datos se actualicen juntos
      if (StorageService.shouldUpdateFarmacias() || StorageService.shouldUpdateTurnos()) {
        try {
          // Obtener farmacias de ambos endpoints en paralelo
          final farmaciasLocales = await ApiService.getLocales();
          final farmaciasTurnos = await ApiService.getLocalesTurnos();
          
          // Extraer IDs de las farmacias de turno
          final turnosIds = farmaciasTurnos.map((f) => f.localId).toList();
          
          // Combinar ambas listas eliminando duplicados por local_id
          final Map<String, Farmacia> farmaciasMap = {};
          
          // Agregar todas las farmacias de locales
          for (final farmacia in farmaciasLocales) {
            farmaciasMap[farmacia.localId] = farmacia;
          }
          
          // Agregar farmacias de turnos (incluyendo las que no están en locales)
          for (final farmacia in farmaciasTurnos) {
            // Si no existe, la agrega. Si existe, la mantiene (no sobrescribe)
            // porque la data de locales es más completa
            farmaciasMap.putIfAbsent(farmacia.localId, () => farmacia);
          }
          
          final farmaciasCombinadas = farmaciasMap.values.toList();
          
          if (farmaciasCombinadas.isNotEmpty) {
            // Guardar ambos datos de forma sincronizada
            await StorageService.saveFarmacias(farmaciasCombinadas);
            await StorageService.saveFarmaciasTurno(turnosIds);
            return farmaciasCombinadas;
          }
        } catch (e) {
          // Si falla la API, usar datos del caché si están disponibles
          final farmaciasDelCache = StorageService.getFarmacias();
          if (farmaciasDelCache.isNotEmpty) {
            return farmaciasDelCache;
          }
          rethrow;
        }
      }

      // Usar datos del caché
      return StorageService.getFarmacias();
    } catch (e) {
      throw FarmaciaServiceException('Error al obtener datos de farmacias: ${e.toString()}');
    }
  }

  /// Obtiene IDs de farmacias de turno del caché
  /// Los IDs se actualizan junto con las farmacias en _getFarmaciasActualizadas()
  static Future<List<String>> _getFarmaciasTurnoActualizadas() async {
    try {
      // Simplemente retornar los IDs del caché
      // Ya se actualizaron en _getFarmaciasActualizadas()
      return StorageService.getFarmaciasTurnoIds();
    } catch (e) {
      throw FarmaciaServiceException('Error al obtener datos de turnos: ${e.toString()}');
    }
  }

  /// Fuerza la actualización de todos los datos
  static Future<void> forzarActualizacion() async {
    try {
      // Limpiar caché
      await StorageService.clearAllData();
      
      // Obtener nuevos datos
      final farmacias = await ApiService.getLocales();
      final farmaciasTurno = await ApiService.getLocalesTurnos();
      
      // Guardar en caché
      await StorageService.saveFarmacias(farmacias);
      await StorageService.saveFarmaciasTurno(
        farmaciasTurno.map((f) => f.localId).toList()
      );
    } catch (e) {
      throw FarmaciaServiceException('Error al forzar actualización: ${e.toString()}');
    }
  }
}

class FarmaciaServiceException implements Exception {
  final String message;
  
  const FarmaciaServiceException(this.message);
  
  @override
  String toString() => 'FarmaciaServiceException: $message';
}