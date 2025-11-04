import 'package:flutter/material.dart';
import '../models/farmacia_con_distancia.dart';
import '../theme/app_theme.dart';
import '../utils/horario_utils.dart';

class FarmaciaCard extends StatelessWidget {
  final FarmaciaConDistancia farmaciaConDistancia;
  final VoidCallback onTap;

  const FarmaciaCard({
    super.key,
    required this.farmaciaConDistancia,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final farmacia = farmaciaConDistancia.farmacia;
    
    return Card(
      color: AppTheme.secondaryColor,
      shadowColor: AppTheme.primaryColor.withOpacity(0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con nombre y badge de turno
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      farmacia.localNombre,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ),
                  if (farmaciaConDistancia.esDeTurno) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.15),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'DE TURNO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              
              // Dirección
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      farmacia.localDireccion,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Comuna
              Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    farmacia.comunaNombre,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              
              // Estado (Abierto/Cerrado/24hrs)
              const SizedBox(height: 8),
              _buildEstadoChip(),
              
              const SizedBox(height: 12),
              
              // Footer con distancia y horario
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Distancia
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.near_me_outlined,
                          size: 12,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          farmaciaConDistancia.distanciaFormateada,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Horario
                  Text(
                    HorarioUtils.formatearHorario(
                      esDeTurno: farmaciaConDistancia.esDeTurno,
                      horaApertura: farmacia.funcionamientoHoraApertura,
                      horaCierre: farmacia.funcionamientoHoraCierre,
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoChip() {
    final farmacia = farmaciaConDistancia.farmacia;
    final estaAbierta = HorarioUtils.estaAbierta(
      esDeTurno: farmaciaConDistancia.esDeTurno,
      horaApertura: farmacia.funcionamientoHoraApertura,
      horaCierre: farmacia.funcionamientoHoraCierre,
    );
    
    final estado = HorarioUtils.obtenerEstado(
      esDeTurno: farmaciaConDistancia.esDeTurno,
      horaApertura: farmacia.funcionamientoHoraApertura,
      horaCierre: farmacia.funcionamientoHoraCierre,
    );

    final Color color;
    final IconData icon;

    if (farmaciaConDistancia.esDeTurno) {
      color = AppTheme.accentColor;
      icon = Icons.access_time_filled;
    } else if (estaAbierta) {
      color = Colors.green;
      icon = Icons.check_circle;
    } else {
      color = Colors.red;
      icon = Icons.cancel;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            estado,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}