import 'package:flutter_test/flutter_test.dart';
import 'package:farmaciaap/models/farmacia.dart';

void main() {
  group('Farmacia', () {
    test('fromJson creates Farmacia from valid JSON', () {
      final json = {
        'local_id': '123',
        'local_nombre': 'Cruz Verde',
        'comuna_nombre': 'Santiago',
        'localidad_nombre': 'Centro',
        'local_direccion': 'Av. Principal 123',
        'funcionamiento_hora_apertura': '09:00:00',
        'funcionamiento_hora_cierre': '21:00:00',
        'local_telefono': '+56912345678',
        'local_lat': '-33.4372',
        'local_lng': '-70.6506',
        'funcionamiento_dia': 'lunes',
        'fk_region': '13',
        'fk_comuna': '101',
        'fk_localidad': '1001',
      };

      final farmacia = Farmacia.fromJson(json);

      expect(farmacia.localId, '123');
      expect(farmacia.localNombre, 'Cruz Verde');
      expect(farmacia.comunaNombre, 'Santiago');
      expect(farmacia.localDireccion, 'Av. Principal 123');
      expect(farmacia.localTelefono, '+56912345678');
      expect(farmacia.localLat, -33.4372);
      expect(farmacia.localLng, -70.6506);
    });

    test('fromJson handles Unicode characters in direccion', () {
      final json = {
        'local_id': '123',
        'local_nombre': 'Test',
        'comuna_nombre': 'Test',
        'localidad_nombre': 'Test',
        'local_direccion': 'Calle N\u00b0 123',
        'funcionamiento_hora_apertura': '09:00:00',
        'funcionamiento_hora_cierre': '21:00:00',
        'local_telefono': '+56912345678',
        'local_lat': '-33.4372',
        'local_lng': '-70.6506',
        'funcionamiento_dia': 'lunes',
        'fk_region': '13',
        'fk_comuna': '101',
        'fk_localidad': '1001',
      };

      final farmacia = Farmacia.fromJson(json);

      // El símbolo unicode \u00b0 es el símbolo de grado °
      expect(farmacia.localDireccion, 'Calle N° 123');
    });

    test('fromJson handles empty strings', () {
      final json = {
        'local_id': '123',
        'local_nombre': 'Test',
        'comuna_nombre': '',
        'localidad_nombre': '',
        'local_direccion': '',
        'funcionamiento_hora_apertura': '09:00:00',
        'funcionamiento_hora_cierre': '21:00:00',
        'local_telefono': '',
        'local_lat': '0',
        'local_lng': '0',
        'funcionamiento_dia': '',
        'fk_region': '',
        'fk_comuna': '',
        'fk_localidad': '',
      };

      final farmacia = Farmacia.fromJson(json);

      expect(farmacia.comunaNombre, '');
      expect(farmacia.localTelefono, '');
      expect(farmacia.localLat, 0.0);
      expect(farmacia.localLng, 0.0);
    });

    test('fromJson handles null values with defaults', () {
      final json = {
        'local_id': '123',
        'local_nombre': 'Test',
        'comuna_nombre': null,
        'localidad_nombre': null,
        'local_direccion': null,
        'funcionamiento_hora_apertura': null,
        'funcionamiento_hora_cierre': null,
        'local_telefono': null,
        'local_lat': null,
        'local_lng': null,
        'funcionamiento_dia': null,
        'fk_region': null,
        'fk_comuna': null,
        'fk_localidad': null,
      };

      final farmacia = Farmacia.fromJson(json);

      expect(farmacia.localId, '123');
      expect(farmacia.localNombre, 'Test');
      expect(farmacia.comunaNombre, '');
      expect(farmacia.localDireccion, '');
    });

    test('toJson creates valid JSON from Farmacia', () {
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

      final json = farmacia.toJson();

      expect(json['local_id'], '123');
      expect(json['local_nombre'], 'Cruz Verde');
      expect(json['local_lat'], '-33.4372');
      expect(json['local_lng'], '-70.6506');
      expect(json['comuna_nombre'], 'Santiago');
    });

    test('toJson preserves all fields', () {
      final farmacia = Farmacia(
        fecha: '2025-10-30',
        localId: 'id-1',
        localNombre: 'Farmacia Test',
        comunaNombre: 'Comuna Test',
        localidadNombre: 'Localidad Test',
        localDireccion: 'Dirección Test',
        funcionamientoHoraApertura: '08:00:00',
        funcionamientoHoraCierre: '20:00:00',
        localTelefono: '+56987654321',
        localLat: -33.5,
        localLng: -70.5,
        funcionamientoDia: 'martes',
        fkRegion: '5',
        fkComuna: '202',
        fkLocalidad: '2002',
      );

      final json = farmacia.toJson();

      expect(json['local_id'], 'id-1');
      expect(json['funcionamiento_hora_apertura'], '08:00:00');
      expect(json['funcionamiento_hora_cierre'], '20:00:00');
      expect(json['fk_region'], '5');
    });
  });
}
