import 'package:flutter_test/flutter_test.dart';
import 'package:farmaciaap/services/farmacia_service.dart';
import 'package:farmaciaap/models/farmacia.dart';
import 'package:farmaciaap/models/farmacia_con_distancia.dart';

void main() {
  group('FarmaciaService', () {
    group('filtrarFarmacias', () {
      test('filters by soloTurno true', () {
        final farmacias = [
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('1', 'Farmacia A'),
            distancia: 1.0,
            esDeTurno: true,
          ),
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('2', 'Farmacia B'),
            distancia: 2.0,
            esDeTurno: false,
          ),
        ];

        final filtered = FarmaciaService.filtrarFarmacias(
          farmacias,
          soloTurno: true,
        );

        expect(filtered.length, 1);
        expect(filtered.first.esDeTurno, true);
      });

      test('filters by soloTurno false shows all', () {
        final farmacias = [
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('1', 'Farmacia A'),
            distancia: 1.0,
            esDeTurno: true,
          ),
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('2', 'Farmacia B'),
            distancia: 2.0,
            esDeTurno: false,
          ),
        ];

        final filtered = FarmaciaService.filtrarFarmacias(
          farmacias,
          soloTurno: false,
        );

        expect(filtered.length, 2);
      });

      test('filters by comuna', () {
        final farmacias = [
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('1', 'Farmacia A', comuna: 'Santiago'),
            distancia: 1.0,
            esDeTurno: false,
          ),
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('2', 'Farmacia B', comuna: 'Providencia'),
            distancia: 2.0,
            esDeTurno: false,
          ),
        ];

        final filtered = FarmaciaService.filtrarFarmacias(
          farmacias,
          comuna: 'Santiago',
        );

        expect(filtered.length, 1);
        expect(filtered.first.farmacia.comunaNombre, 'Santiago');
      });

      test('filters by nombreFarmacia case insensitive', () {
        final farmacias = [
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('1', 'Cruz Verde'),
            distancia: 1.0,
            esDeTurno: false,
          ),
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('2', 'Ahumada'),
            distancia: 2.0,
            esDeTurno: false,
          ),
        ];

        final filtered = FarmaciaService.filtrarFarmacias(
          farmacias,
          nombreFarmacia: 'cruz',
        );

        expect(filtered.length, 1);
        expect(filtered.first.farmacia.localNombre, contains('Cruz'));
      });

      test('filters by multiple criteria', () {
        final farmacias = [
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('1', 'Cruz Verde', comuna: 'Santiago'),
            distancia: 1.0,
            esDeTurno: true,
          ),
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('2', 'Cruz Roja', comuna: 'Santiago'),
            distancia: 2.0,
            esDeTurno: false,
          ),
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('3', 'Ahumada', comuna: 'Providencia'),
            distancia: 3.0,
            esDeTurno: true,
          ),
        ];

        final filtered = FarmaciaService.filtrarFarmacias(
          farmacias,
          soloTurno: true,
          comuna: 'Santiago',
          nombreFarmacia: 'Cruz',
        );

        expect(filtered.length, 1);
        expect(filtered.first.farmacia.localId, '1');
      });

      test('returns empty list when no matches', () {
        final farmacias = [
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('1', 'Farmacia A'),
            distancia: 1.0,
            esDeTurno: false,
          ),
        ];

        final filtered = FarmaciaService.filtrarFarmacias(
          farmacias,
          nombreFarmacia: 'NoExiste',
        );

        expect(filtered.isEmpty, true);
      });

      test('handles empty input list', () {
        final filtered = FarmaciaService.filtrarFarmacias(
          [],
          soloTurno: true,
        );

        expect(filtered.isEmpty, true);
      });

      test('handles null/empty filters', () {
        final farmacias = [
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('1', 'Farmacia A'),
            distancia: 1.0,
            esDeTurno: false,
          ),
        ];

        final filtered = FarmaciaService.filtrarFarmacias(
          farmacias,
          comuna: null,
          nombreFarmacia: null,
        );

        expect(filtered.length, 1);
      });
    });

    group('obtenerComunas', () {
      test('returns sorted unique comunas', () {
        final farmacias = [
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('1', 'A', comuna: 'Santiago'),
            distancia: 1.0,
            esDeTurno: false,
          ),
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('2', 'B', comuna: 'Providencia'),
            distancia: 2.0,
            esDeTurno: false,
          ),
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('3', 'C', comuna: 'Santiago'),
            distancia: 3.0,
            esDeTurno: false,
          ),
        ];

        final comunas = FarmaciaService.obtenerComunas(farmacias);

        expect(comunas.length, 2);
        expect(comunas, ['Providencia', 'Santiago']); // Ordenadas alfabéticamente
      });

      test('returns empty list for empty input', () {
        final comunas = FarmaciaService.obtenerComunas([]);

        expect(comunas.isEmpty, true);
      });

      test('handles single comuna', () {
        final farmacias = [
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('1', 'A', comuna: 'Santiago'),
            distancia: 1.0,
            esDeTurno: false,
          ),
        ];

        final comunas = FarmaciaService.obtenerComunas(farmacias);

        expect(comunas.length, 1);
        expect(comunas.first, 'Santiago');
      });

      test('excludes empty comuna names', () {
        final farmacias = [
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('1', 'A', comuna: 'Santiago'),
            distancia: 1.0,
            esDeTurno: false,
          ),
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('2', 'B', comuna: ''),
            distancia: 2.0,
            esDeTurno: false,
          ),
        ];

        final comunas = FarmaciaService.obtenerComunas(farmacias);

        expect(comunas.length, 1);
        expect(comunas.first, 'Santiago');
      });
    });

    group('obtenerRegiones', () {
      test('returns sorted unique regions', () {
        final farmacias = [
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('1', 'A', region: '13'),
            distancia: 1.0,
            esDeTurno: false,
          ),
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('2', 'B', region: '5'),
            distancia: 2.0,
            esDeTurno: false,
          ),
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('3', 'C', region: '13'),
            distancia: 3.0,
            esDeTurno: false,
          ),
        ];

        final regiones = FarmaciaService.obtenerRegiones(farmacias);

        expect(regiones.length, 2);
        expect(regiones, ['13', '5']); // Ordenadas alfabéticamente
      });

      test('returns empty list for empty input', () {
        final regiones = FarmaciaService.obtenerRegiones([]);

        expect(regiones.isEmpty, true);
      });

      test('excludes empty region codes', () {
        final farmacias = [
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('1', 'A', region: '13'),
            distancia: 1.0,
            esDeTurno: false,
          ),
          FarmaciaConDistancia(
            farmacia: _createTestFarmacia('2', 'B', region: ''),
            distancia: 2.0,
            esDeTurno: false,
          ),
        ];

        final regiones = FarmaciaService.obtenerRegiones(farmacias);

        expect(regiones.length, 1);
        expect(regiones.first, '13');
      });
    });
  });
}

Farmacia _createTestFarmacia(
  String id,
  String nombre, {
  String comuna = 'Test',
  String region = '13',
}) {
  return Farmacia(
    fecha: '2025-10-30',
    localId: id,
    localNombre: nombre,
    comunaNombre: comuna,
    localidadNombre: 'Test',
    localDireccion: 'Test 123',
    funcionamientoHoraApertura: '09:00:00',
    funcionamientoHoraCierre: '21:00:00',
    localTelefono: '+56912345678',
    localLat: -33.4372,
    localLng: -70.6506,
    funcionamientoDia: 'lunes',
    fkRegion: region,
    fkComuna: '101',
    fkLocalidad: '1001',
  );
}
