import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/farmacia_con_distancia.dart';
import '../services/farmacia_service.dart';
import '../utils/horario_utils.dart';
import '../widgets/farmacia_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';
import 'farmacia_detail_screen.dart';

class FarmaciaListScreen extends StatefulWidget {
  final List<FarmaciaConDistancia> farmaciasCercanas;
  final Position? userPosition;
  final double radius;

  const FarmaciaListScreen({
    super.key,
    required this.farmaciasCercanas,
    this.userPosition,
    required this.radius,
  });

  @override
  State<FarmaciaListScreen> createState() => _FarmaciaListScreenState();
}

class _FarmaciaListScreenState extends State<FarmaciaListScreen> {
  List<FarmaciaConDistancia> _farmaciasFiltradas = [];
  bool _soloTurno = false;
  bool _soloAbiertas = false;
  String? _comunaSeleccionada;
  String? _regionSeleccionada;
  String _busquedaNombre = '';
  
  List<String> _comunasDisponibles = [];
  
  bool _isRefreshing = false;
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializarDatos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializarDatos() {
    _farmaciasFiltradas = widget.farmaciasCercanas;
    _comunasDisponibles = FarmaciaService.obtenerComunas(widget.farmaciasCercanas);
  }

  void _aplicarFiltros() {
    setState(() {
      var farmacias = FarmaciaService.filtrarFarmacias(
        widget.farmaciasCercanas,
        soloTurno: _soloTurno,
        comuna: _comunaSeleccionada,
        region: _regionSeleccionada,
        nombreFarmacia: _busquedaNombre,
      );
      
      // Aplicar filtro de solo abiertas si está activado
      if (_soloAbiertas) {
        farmacias = farmacias.where((farmaciaConDistancia) {
          return HorarioUtils.estaAbierta(
            esDeTurno: farmaciaConDistancia.esDeTurno,
            horaApertura: farmaciaConDistancia.farmacia.funcionamientoHoraApertura,
            horaCierre: farmaciaConDistancia.farmacia.funcionamientoHoraCierre,
          );
        }).toList();
      }
      
      _farmaciasFiltradas = farmacias;
    });
  }

  Future<void> _refrescarDatos() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await FarmaciaService.forzarActualizacion();
      
      final farmaciasCercanas = widget.userPosition != null
          ? await FarmaciaService.getFarmaciasCercanas(
              radius: widget.radius,
              userPosition: widget.userPosition,
            )
          : widget.farmaciasCercanas; // Si no hay posición, no podemos refrescar con geolocalización
      
      setState(() {
        _farmaciasFiltradas = farmaciasCercanas;
        _comunasDisponibles = FarmaciaService.obtenerComunas(farmaciasCercanas);
      });
      
      _aplicarFiltros();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Datos actualizados correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalFarmacias = widget.farmaciasCercanas.length;
    final farmaciasTurno = widget.farmaciasCercanas.where((f) => f.esDeTurno).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmacias Cercanas'),
        actions: [
          IconButton(
            onPressed: _mostrarFiltros,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de estadísticas
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEstadistica(
                  'Total',
                  totalFarmacias.toString(),
                  Icons.local_pharmacy_outlined,
                  Colors.blue,
                ),
                _buildEstadistica(
                  'De Turno',
                  farmaciasTurno.toString(),
                  Icons.access_time,
                  Colors.orange,
                ),
                _buildEstadistica(
                  'Radio',
                  '${widget.radius.toInt()} km',
                  Icons.near_me,
                  Colors.green,
                ),
              ],
            ),
          ),

          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre de farmacia...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busquedaNombre.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _busquedaNombre = '';
                          });
                          _aplicarFiltros();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _busquedaNombre = value;
                });
                _aplicarFiltros();
              },
            ),
          ),

          // Lista de farmacias
          Expanded(
            child: _isRefreshing
                ? const LoadingWidget(message: 'Actualizando datos...')
                : _farmaciasFiltradas.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.search_off,
                        title: 'No se encontraron farmacias',
                        subtitle: 'Intenta ajustar los filtros o aumentar el radio de búsqueda',
                        action: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _soloTurno = false;
                              _comunaSeleccionada = null;
                              _regionSeleccionada = null;
                              _busquedaNombre = '';
                              _searchController.clear();
                            });
                            _aplicarFiltros();
                          },
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Limpiar filtros'),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refrescarDatos,
                        child: ListView.builder(
                          itemCount: _farmaciasFiltradas.length,
                          itemBuilder: (context, index) {
                            final farmaciaConDistancia = _farmaciasFiltradas[index];
                            return FarmaciaCard(
                              farmaciaConDistancia: farmaciaConDistancia,
                              onTap: () => _navegarADetalle(farmaciaConDistancia),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadistica(String label, String valor, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtros',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _soloTurno = false;
                            _comunaSeleccionada = null;
                            _regionSeleccionada = null;
                          });
                        },
                        child: const Text('Limpiar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Filtro solo de turno
                  SwitchListTile(
                    title: const Text('Solo farmacias de turno'),
                    subtitle: const Text('Mostrar únicamente farmacias abiertas 24 horas'),
                    value: _soloTurno,
                    onChanged: (value) {
                      setModalState(() {
                        _soloTurno = value;
                      });
                    },
                  ),
                  
                  // Filtro solo abiertas
                  SwitchListTile(
                    title: const Text('Solo farmacias abiertas'),
                    subtitle: const Text('Mostrar únicamente farmacias abiertas en este momento'),
                    value: _soloAbiertas,
                    onChanged: (value) {
                      setModalState(() {
                        _soloAbiertas = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Filtro por comuna
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Comuna',
                      hintText: 'Seleccionar comuna',
                    ),
                    value: _comunaSeleccionada,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Todas las comunas'),
                      ),
                      ..._comunasDisponibles.map((comuna) =>
                        DropdownMenuItem<String>(
                          value: comuna,
                          child: Text(comuna),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        _comunaSeleccionada = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Los filtros ya están actualizados en las variables
                      });
                      _aplicarFiltros();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Aplicar filtros'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navegarADetalle(FarmaciaConDistancia farmaciaConDistancia) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FarmaciaDetailScreen(
          farmaciaConDistancia: farmaciaConDistancia,
          userPosition: widget.userPosition,
        ),
      ),
    );
  }
}