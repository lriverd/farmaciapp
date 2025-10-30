import 'package:flutter_test/flutter_test.dart';
import 'package:farmaciaap/utils/distance_calculator.dart';

void main() {
  group('DistanceCalculator', () {
    test('calculateDistance returns 0 for same location', () {
      final distance = DistanceCalculator.calculateDistance(
        -33.4372,
        -70.6506,
        -33.4372,
        -70.6506,
      );

      expect(distance, 0.0);
    });

    test('calculateDistance returns correct distance for known locations', () {
      // Distancia aproximada entre Plaza de Armas y Costanera Center (Santiago)
      final distance = DistanceCalculator.calculateDistance(
        -33.4372, // Plaza de Armas
        -70.6506,
        -33.4125, // Costanera Center
        -70.6119,
      );

      // La distancia real es aproximadamente 4.5 km
      expect(distance, greaterThan(4.0));
      expect(distance, lessThan(5.0));
    });

    test('calculateDistance handles negative coordinates', () {
      final distance = DistanceCalculator.calculateDistance(
        -33.4372,
        -70.6506,
        33.4372,
        70.6506,
      );

      expect(distance, greaterThan(0));
    });

    test('calculateDistance is symmetric', () {
      final distance1 = DistanceCalculator.calculateDistance(
        -33.4372,
        -70.6506,
        -33.4125,
        -70.6119,
      );

      final distance2 = DistanceCalculator.calculateDistance(
        -33.4125,
        -70.6119,
        -33.4372,
        -70.6506,
      );

      expect(distance1, distance2);
    });

    test('calculateDistance handles equator crossing', () {
      final distance = DistanceCalculator.calculateDistance(
        -1.0, // Sur del ecuador
        -70.0,
        1.0, // Norte del ecuador
        -70.0,
      );

      expect(distance, greaterThan(0));
      expect(distance, lessThan(300)); // Aproximadamente 222 km
    });

    test('calculateDistance handles prime meridian crossing', () {
      final distance = DistanceCalculator.calculateDistance(
        0.0,
        -1.0, // Oeste del meridiano de Greenwich
        0.0,
        1.0, // Este del meridiano de Greenwich
      );

      expect(distance, greaterThan(0));
      expect(distance, lessThan(300)); // Aproximadamente 222 km
    });

    test('calculateDistance with zero coordinates', () {
      final distance = DistanceCalculator.calculateDistance(
        0.0,
        0.0,
        0.0,
        0.0,
      );

      expect(distance, 0.0);
    });
  });
}
