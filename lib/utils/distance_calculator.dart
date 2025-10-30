import 'dart:math' as math;

class DistanceCalculator {
  /// Calcula la distancia entre dos puntos geográficos usando la fórmula Haversine
  /// Retorna la distancia en kilómetros
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const double earthRadius = 6371; // Radio de la Tierra en kilómetros

    double dLat = _toRadians(endLatitude - startLatitude);
    double dLng = _toRadians(endLongitude - startLongitude);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(startLatitude)) *
            math.cos(_toRadians(endLatitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Determina si una farmacia está dentro del radio especificado
  static bool isWithinRadius(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
    double radiusInKm,
  ) {
    double distance = calculateDistance(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
    return distance <= radiusInKm;
  }
}