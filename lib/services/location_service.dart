import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Obtiene la ubicación actual del usuario
  static Future<Position?> getCurrentPosition() async {
    try {
      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException('El servicio de ubicación está deshabilitado');
      }

      // Verificar y solicitar permisos usando geolocator
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        // Solicitar permiso
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationException('Permisos de ubicación denegados');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationException('Los permisos de ubicación están permanentemente denegados');
      }

      // Obtener la posición actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );

      return position;
    } on LocationServiceDisabledException {
      throw LocationException('El servicio de ubicación está deshabilitado');
    } on PermissionDeniedException {
      throw LocationException('Permisos de ubicación denegados');
    } catch (e) {
      if (e is LocationException) rethrow;
      throw LocationException('Error al obtener la ubicación: ${e.toString()}');
    }
  }

  /// Solicita permisos de ubicación (método público)
  static Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        return permission == LocationPermission.whileInUse || 
               permission == LocationPermission.always;
      }

      if (permission == LocationPermission.deniedForever) {
        // Abrir configuración de la app
        await Geolocator.openAppSettings();
        return false;
      }

      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  /// Verifica si los permisos de ubicación están concedidos
  static Future<bool> hasLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  /// Verifica si el servicio de ubicación está habilitado
  static Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }

  /// Abre la configuración de la aplicación
  static Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      await Geolocator.openAppSettings();
    }
  }

  /// Obtiene el estado detallado de los permisos y servicios de ubicación
  static Future<LocationStatus> getLocationStatus() async {
    try {
      final hasPermission = await hasLocationPermission();
      final serviceEnabled = await isLocationServiceEnabled();

      if (!serviceEnabled) {
        return LocationStatus.serviceDisabled;
      }

      if (!hasPermission) {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.deniedForever) {
          return LocationStatus.permissionDeniedPermanently;
        }
        return LocationStatus.permissionDenied;
      }

      return LocationStatus.available;
    } catch (e) {
      return LocationStatus.unknown;
    }
  }
}

enum LocationStatus {
  available,
  permissionDenied,
  permissionDeniedPermanently,
  serviceDisabled,
  unknown,
}

class LocationException implements Exception {
  final String message;
  
  const LocationException(this.message);
  
  @override
  String toString() => 'LocationException: $message';
}