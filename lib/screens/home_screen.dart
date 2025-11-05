import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/farmacia_service.dart';
import '../services/theme_service.dart';
import '../services/ad_service.dart';
import '../services/analytics_service.dart';
import '../models/farmacia_con_distancia.dart';
import '../utils/constants.dart';
import 'farmacia_list_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _selectedRadius = AppConstants.defaultRadius;
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _localidadController = TextEditingController();
  bool _useGeolocation = true;
  
  // Banner ad
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    
    // Registrar vista de pantalla
    AnalyticsService.setCurrentScreen(screenName: 'HomeScreen');
  }

  /// Carga el anuncio banner
  void _loadBannerAd() {
    _bannerAd = AdService.createBannerAd(
      onAdLoaded: (ad) {
        setState(() {
          _isBannerAdLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
        setState(() {
          _isBannerAdLoaded = false;
        });
        
        // Registrar error de carga de anuncio
        AnalyticsService.logError(
          error: 'Error cargando banner ad: ${error.message}',
          stackTrace: StackTrace.current,
          contexto: 'HomeScreen - Banner Ad',
        );
      },
    );
    
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _localidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [const Color(0xFF1A237E), const Color(0xFF0D47A1)]
                : [const Color(0xFFE3F2FD), const Color(0xFF90CAF9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                // Header compacto
                const SizedBox(height: 16),
                Icon(
                  Icons.local_pharmacy_outlined,
                  size: 64,
                  color: isDarkMode 
                      ? Colors.lightBlue.shade300
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Encuentra farmacias cercanas a ti',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Las farmacias de turno están disponibles 24 horas',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDarkMode 
                        ? Colors.grey.shade300 
                        : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Selector de método de búsqueda
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.search_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Método de búsqueda',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      
                      // Toggle entre geolocalización y localidad manual
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(
                            value: true,
                            label: Text('Mi ubicación'),
                            icon: Icon(Icons.my_location, size: 18),
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            label: Text('Escribir localidad'),
                            icon: Icon(Icons.edit_location_alt, size: 18),
                          ),
                        ],
                        selected: {_useGeolocation},
                        onSelectionChanged: (Set<bool> newSelection) {
                          setState(() {
                            _useGeolocation = newSelection.first;
                            _errorMessage = null;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Campo de localidad (solo si no usa geolocalización)
                      if (!_useGeolocation) ...[
                        TextField(
                          controller: _localidadController,
                          decoration: InputDecoration(
                            labelText: 'Localidad',
                            hintText: 'Ej: Santiago, Providencia, Viña del Mar',
                            prefixIcon: const Icon(Icons.location_city),
                            border: const OutlineInputBorder(),
                            helperText: 'Ingresa una comuna o ciudad de Chile',
                          ),
                          textCapitalization: TextCapitalization.words,
                          onChanged: (_) {
                            setState(() {
                              _errorMessage = null;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),

              // Slider de radio de búsqueda (solo si usa geolocalización)
              if (_useGeolocation) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.radar,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Radio de búsqueda',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_selectedRadius.toInt()} km',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _selectedRadius,
                          min: AppConstants.radiusOptions.first,
                          max: AppConstants.radiusOptions.last,
                          divisions: AppConstants.radiusOptions.length - 1,
                          label: '${_selectedRadius.toInt()} km',
                          onChanged: (value) {
                            setState(() {
                              _selectedRadius = value;
                            });
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${AppConstants.radiusOptions.first.toInt()} km',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                '${AppConstants.radiusOptions.last.toInt()} km',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Mensaje de error
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Botón de búsqueda
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _buscarFarmacias,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.search),
                  label: Text(
                    _isLoading ? 'Buscando...' : 'Buscar farmacias cercanas',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Banner publicitario
              if (_isBannerAdLoaded && _bannerAd != null)
                Center(
                  child: Container(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isDarkMode 
                          ? Colors.white.withAlpha(25)
                          : Colors.white.withAlpha(128),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                  ),
                ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      // Botones en la esquina superior derecha
      Positioned(
        top: 8,
        right: 8,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón de cambio de tema
            IconButton(
              icon: Icon(
                Provider.of<ThemeService>(context).isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () async {
                final themeService = Provider.of<ThemeService>(context, listen: false);
                final nuevoModo = themeService.isDarkMode ? 'light' : 'dark';
                
                await themeService.toggleTheme();
                
                // Registrar cambio de tema
                await AnalyticsService.logCambioTema(modoTema: nuevoModo);
              },
              tooltip: Provider.of<ThemeService>(context).isDarkMode
                  ? 'Modo claro'
                  : 'Modo oscuro',
            ),
            const SizedBox(width: 4),
            // Botón de información
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                // Registrar vista de Acerca de
                AnalyticsService.logVerAcercaDe();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutScreen(),
                  ),
                );
              },
              tooltip: 'Acerca de',
            ),
          ],
        ),
      ),
    ],
        ),
      ),
    ),
    );
  }

  Future<void> _buscarFarmacias() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<FarmaciaConDistancia> farmaciasCercanas;
      Position? position;

      if (_useGeolocation) {
        // Búsqueda por geolocalización
        
        // Verificar estado de ubicación
        final locationStatus = await LocationService.getLocationStatus();
        
        switch (locationStatus) {
          case LocationStatus.serviceDisabled:
            setState(() {
              _errorMessage = 'El servicio de ubicación está deshabilitado. Por favor, actívalo en la configuración.';
            });
            return;
          case LocationStatus.permissionDenied:
            // Intentar solicitar permiso automáticamente
            // No mostramos error aquí, dejamos que getCurrentPosition() lo maneje
            break;
          case LocationStatus.permissionDeniedPermanently:
            setState(() {
              _errorMessage = 'Los permisos de ubicación fueron denegados permanentemente. Por favor, actívalos en la configuración de la aplicación.';
            });
            return;
          case LocationStatus.unknown:
            setState(() {
              _errorMessage = 'Error desconocido con la ubicación. Por favor, intenta nuevamente.';
            });
            return;
          case LocationStatus.available:
            break;
        }

        // Obtener ubicación (esto solicitará permisos si es necesario)
        position = await LocationService.getCurrentPosition();
        if (position == null) {
          setState(() {
            _errorMessage = 'No se pudo obtener tu ubicación actual.';
          });
          return;
        }

        // Buscar farmacias cercanas
        farmaciasCercanas = await FarmaciaService.getFarmaciasCercanas(
          radius: _selectedRadius,
          userPosition: position,
        );
        
        // Registrar búsqueda por GPS
        await AnalyticsService.logBusquedaFarmacias(
          metodo: 'gps',
          resultados: farmaciasCercanas.length,
          radioKm: _selectedRadius,
        );
      } else {
        // Búsqueda por localidad escrita
        final localidad = _localidadController.text.trim();
        
        if (localidad.isEmpty) {
          setState(() {
            _errorMessage = 'Por favor, ingresa una localidad para buscar.';
          });
          return;
        }

        // Buscar farmacias por localidad
        farmaciasCercanas = await FarmaciaService.getFarmaciasPorLocalidad(
          localidad: localidad,
        );
        
        // Registrar búsqueda manual
        await AnalyticsService.logBusquedaFarmacias(
          metodo: 'manual',
          resultados: farmaciasCercanas.length,
          comuna: localidad,
        );
        
        position = null; // No hay posición del usuario en este caso
      }

      if (!mounted) return;

      // Navegar a la pantalla de resultados
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FarmaciaListScreen(
            farmaciasCercanas: farmaciasCercanas,
            userPosition: position,
            radius: _selectedRadius,
          ),
        ),
      );

    } catch (e) {
      if (!mounted) return;
      
      // Registrar error
      await AnalyticsService.logError(
        error: e.toString(),
        stackTrace: StackTrace.current,
        contexto: 'Búsqueda de farmacias',
        datosAdicionales: {
          'metodo': _useGeolocation ? 'gps' : 'manual',
          if (!_useGeolocation) 'localidad': _localidadController.text,
        },
      );
      
      setState(() {
        _errorMessage = 'Error al buscar farmacias: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}