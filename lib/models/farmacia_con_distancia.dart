import 'farmacia.dart';

class FarmaciaConDistancia {
  final Farmacia farmacia;
  final double distancia;
  final bool esDeTurno;

  const FarmaciaConDistancia({
    required this.farmacia,
    required this.distancia,
    required this.esDeTurno,
  });

  String get distanciaFormateada {
    if (distancia < 1) {
      return '${(distancia * 1000).round()}m';
    } else {
      return '${distancia.toStringAsFixed(1)}km';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FarmaciaConDistancia &&
          runtimeType == other.runtimeType &&
          farmacia == other.farmacia;

  @override
  int get hashCode => farmacia.hashCode;

  @override
  String toString() {
    return 'FarmaciaConDistancia{farmacia: ${farmacia.localNombre}, distancia: $distanciaFormateada, esDeTurno: $esDeTurno}';
  }
}