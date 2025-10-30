import 'dart:convert';

class Farmacia {
  final String fecha;
  final String localId;
  final String localNombre;
  final String comunaNombre;
  final String localidadNombre;
  final String localDireccion;
  final String funcionamientoHoraApertura;
  final String funcionamientoHoraCierre;
  final String localTelefono;
  final double localLat;
  final double localLng;
  final String funcionamientoDia;
  final String fkRegion;
  final String fkComuna;
  final String fkLocalidad;

  const Farmacia({
    required this.fecha,
    required this.localId,
    required this.localNombre,
    required this.comunaNombre,
    required this.localidadNombre,
    required this.localDireccion,
    required this.funcionamientoHoraApertura,
    required this.funcionamientoHoraCierre,
    required this.localTelefono,
    required this.localLat,
    required this.localLng,
    required this.funcionamientoDia,
    required this.fkRegion,
    required this.fkComuna,
    required this.fkLocalidad,
  });

  factory Farmacia.fromJson(Map<String, dynamic> json) {
    return Farmacia(
      fecha: json['fecha'] as String? ?? '',
      localId: json['local_id'] as String? ?? '',
      localNombre: _cleanText(json['local_nombre'] as String? ?? ''),
      comunaNombre: _cleanText(json['comuna_nombre'] as String? ?? ''),
      localidadNombre: _cleanText(json['localidad_nombre'] as String? ?? ''),
      localDireccion: _cleanText(json['local_direccion'] as String? ?? ''),
      funcionamientoHoraApertura: json['funcionamiento_hora_apertura'] as String? ?? '',
      funcionamientoHoraCierre: json['funcionamiento_hora_cierre'] as String? ?? '',
      localTelefono: json['local_telefono'] as String? ?? '',
      localLat: double.tryParse(json['local_lat'] as String? ?? '0') ?? 0.0,
      localLng: double.tryParse(json['local_lng'] as String? ?? '0') ?? 0.0,
      funcionamientoDia: json['funcionamiento_dia'] as String? ?? '',
      fkRegion: json['fk_region'] as String? ?? '',
      fkComuna: json['fk_comuna'] as String? ?? '',
      fkLocalidad: json['fk_localidad'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha,
      'local_id': localId,
      'local_nombre': localNombre,
      'comuna_nombre': comunaNombre,
      'localidad_nombre': localidadNombre,
      'local_direccion': localDireccion,
      'funcionamiento_hora_apertura': funcionamientoHoraApertura,
      'funcionamiento_hora_cierre': funcionamientoHoraCierre,
      'local_telefono': localTelefono,
      'local_lat': localLat.toString(),
      'local_lng': localLng.toString(),
      'funcionamiento_dia': funcionamientoDia,
      'fk_region': fkRegion,
      'fk_comuna': fkComuna,
      'fk_localidad': fkLocalidad,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static String _cleanText(String text) {
    // Decode Unicode escape sequences
    String decoded = text.replaceAllMapped(
      RegExp(r'\\u([0-9A-Fa-f]{4})'),
      (match) => String.fromCharCode(int.parse(match.group(1)!, radix: 16)),
    );
    return decoded.trim();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Farmacia &&
          runtimeType == other.runtimeType &&
          localId == other.localId;

  @override
  int get hashCode => localId.hashCode;

  @override
  String toString() {
    return 'Farmacia{localId: $localId, localNombre: $localNombre, comunaNombre: $comunaNombre}';
  }
}