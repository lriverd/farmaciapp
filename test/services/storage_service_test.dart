import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farmaciaap/services/storage_service.dart';
import 'package:farmaciaap/models/farmacia.dart';

void main() {
  group('StorageService', () {
    setUp(() async {
      // Configurar SharedPreferences para testing
      SharedPreferences.setMockInitialValues({});
      await StorageService.init();
    });

    tearDown(() async {
      // Limpiar después de cada test
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    group('Farmacias', () {
      test('saveFarmacias and getFarmacias work correctly', () async {
        final farmacias = [
          Farmacia(
            fecha: '2025-10-30',
            localId: '1',
            localNombre: 'Farmacia Test',
            comunaNombre: 'Santiago',
            localidadNombre: 'Centro',
            localDireccion: 'Test 123',
            funcionamientoHoraApertura: '09:00:00',
            funcionamientoHoraCierre: '21:00:00',
            localTelefono: '+56912345678',
            localLat: -33.4372,
            localLng: -70.6506,
            funcionamientoDia: 'lunes',
            fkRegion: '13',
            fkComuna: '101',
            fkLocalidad: '1001',
          ),
        ];

        final saved = await StorageService.saveFarmacias(farmacias);
        expect(saved, true);

        final loaded = StorageService.getFarmacias();
        expect(loaded.length, 1);
        expect(loaded.first.localId, '1');
        expect(loaded.first.localNombre, 'Farmacia Test');
      });

      test('getFarmacias returns empty list when no data', () {
        final farmacias = StorageService.getFarmacias();
        expect(farmacias, isEmpty);
      });

      test('saveFarmacias updates timestamp', () async {
        final farmacias = [
          _createTestFarmacia('1'),
        ];

        await StorageService.saveFarmacias(farmacias);

        // Verificar que shouldUpdateFarmacias retorna false (recién guardado)
        expect(StorageService.shouldUpdateFarmacias(), false);
      });
    });

    group('Farmacias Turno', () {
      test('saveFarmaciasTurno and getFarmaciasTurnoIds work correctly', () async {
        final ids = ['1', '2', '3'];

        final saved = await StorageService.saveFarmaciasTurno(ids);
        expect(saved, true);

        final loaded = StorageService.getFarmaciasTurnoIds();
        expect(loaded.length, 3);
        expect(loaded, containsAll(['1', '2', '3']));
      });

      test('saveFarmaciasTurno updates timestamp', () async {
        final ids = ['1', '2'];

        await StorageService.saveFarmaciasTurno(ids);

        // Verificar que shouldUpdateTurnos retorna false (recién guardado)
        expect(StorageService.shouldUpdateTurnos(), false);
      });
    });

    group('Update checks', () {
      test('shouldUpdateFarmacias returns false after recent save', () async {
        final farmacias = [_createTestFarmacia('1')];
        await StorageService.saveFarmacias(farmacias);
        
        expect(StorageService.shouldUpdateFarmacias(), false);
      });

      test('shouldUpdateFarmacias returns false immediately after save', () async {
        final farmacias = [_createTestFarmacia('1')];
        await StorageService.saveFarmacias(farmacias);

        expect(StorageService.shouldUpdateFarmacias(), false);
      });

      test('shouldUpdateTurnos returns false after recent save', () async {
        final ids = ['1'];
        await StorageService.saveFarmaciasTurno(ids);
        
        expect(StorageService.shouldUpdateTurnos(), false);
      });

      test('shouldUpdateTurnos returns false immediately after save', () async {
        final ids = ['1'];
        await StorageService.saveFarmaciasTurno(ids);

        expect(StorageService.shouldUpdateTurnos(), false);
      });
    });

    group('Multiple saves', () {
      test('can save and retrieve multiple times', () async {
        // Primera vez
        final farmacias1 = [_createTestFarmacia('1')];
        await StorageService.saveFarmacias(farmacias1);
        
        var loaded = StorageService.getFarmacias();
        expect(loaded.length, 1);

        // Segunda vez (sobrescribe)
        final farmacias2 = [
          _createTestFarmacia('1'),
          _createTestFarmacia('2'),
        ];
        await StorageService.saveFarmacias(farmacias2);
        
        loaded = StorageService.getFarmacias();
        expect(loaded.length, 2);
      });

      test('updating farmacias also updates turno timestamp', () async {
        final farmacias = [_createTestFarmacia('1')];
        await StorageService.saveFarmacias(farmacias);

        // Ambos deberían retornar false porque se sincronizan
        expect(StorageService.shouldUpdateFarmacias(), false);
        expect(StorageService.shouldUpdateTurnos(), false);
      });
    });
  });
}

Farmacia _createTestFarmacia(String id) {
  return Farmacia(
    fecha: '2025-10-30',
    localId: id,
    localNombre: 'Farmacia $id',
    comunaNombre: 'Test',
    localidadNombre: 'Test',
    localDireccion: 'Test 123',
    funcionamientoHoraApertura: '09:00:00',
    funcionamientoHoraCierre: '21:00:00',
    localTelefono: '+56912345678',
    localLat: -33.4372,
    localLng: -70.6506,
    funcionamientoDia: 'lunes',
    fkRegion: '13',
    fkComuna: '101',
    fkLocalidad: '1001',
  );
}
