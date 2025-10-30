import 'package:flutter_test/flutter_test.dart';
import 'package:farmaciaap/models/farmacia.dart';
import 'package:farmaciaap/models/farmacia_con_distancia.dart';

void main() {
  group('FarmaciaConDistancia', () {
    test('creates instance with all properties', () {
      final farmacia = Farmacia(
        fecha: '2025-10-30',
        localId: '123',
        localNombre: 'Cruz Verde',
        comunaNombre: 'Santiago',
        localidadNombre: 'Centro',
        localDireccion: 'Av. Principal 123',
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

      final farmaciaConDistancia = FarmaciaConDistancia(
        farmacia: farmacia,
        distancia: 2.5,
        esDeTurno: true,
      );

      expect(farmaciaConDistancia.farmacia, farmacia);
      expect(farmaciaConDistancia.distancia, 2.5);
      expect(farmaciaConDistancia.esDeTurno, true);
    });

    test('esDeTurno can be false', () {
      final farmacia = Farmacia(
        fecha: '2025-10-30',
        localId: '123',
        localNombre: 'Test',
        comunaNombre: 'Test',
        localidadNombre: 'Test',
        localDireccion: 'Test',
        funcionamientoHoraApertura: '09:00:00',
        funcionamientoHoraCierre: '21:00:00',
        localTelefono: '',
        localLat: 0.0,
        localLng: 0.0,
        funcionamientoDia: '',
        fkRegion: '',
        fkComuna: '',
        fkLocalidad: '',
      );

      final farmaciaConDistancia = FarmaciaConDistancia(
        farmacia: farmacia,
        distancia: 5.0,
        esDeTurno: false,
      );

      expect(farmaciaConDistancia.esDeTurno, false);
    });

    test('distancia can be zero', () {
      final farmacia = Farmacia(
        fecha: '2025-10-30',
        localId: '123',
        localNombre: 'Test',
        comunaNombre: 'Test',
        localidadNombre: 'Test',
        localDireccion: 'Test',
        funcionamientoHoraApertura: '09:00:00',
        funcionamientoHoraCierre: '21:00:00',
        localTelefono: '',
        localLat: 0.0,
        localLng: 0.0,
        funcionamientoDia: '',
        fkRegion: '',
        fkComuna: '',
        fkLocalidad: '',
      );

      final farmaciaConDistancia = FarmaciaConDistancia(
        farmacia: farmacia,
        distancia: 0.0,
        esDeTurno: true,
      );

      expect(farmaciaConDistancia.distancia, 0.0);
    });
  });
}
