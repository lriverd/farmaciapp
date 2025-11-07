import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/farmacia_con_distancia.dart';
import '../theme/app_theme.dart';
import '../services/ad_service.dart';
import '../services/analytics_service.dart';

class FarmaciaDetailScreen extends StatefulWidget {
  final FarmaciaConDistancia farmaciaConDistancia;
  final Position? userPosition;

  const FarmaciaDetailScreen({
    super.key,
    required this.farmaciaConDistancia,
    this.userPosition,
  });

  @override
  State<FarmaciaDetailScreen> createState() => _FarmaciaDetailScreenState();
}

class _FarmaciaDetailScreenState extends State<FarmaciaDetailScreen> {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = AdService.createBannerAd(
      onAdLoaded: (ad) {
        setState(() {
          _isBannerAdLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
        AnalyticsService.logError(
          error: 'Error al cargar banner en detalle',
          stackTrace: StackTrace.current,
          contexto: 'FarmaciaDetailScreen',
        );
      },
    );
    _bannerAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    final farmacia = widget.farmaciaConDistancia.farmacia;

    return Scaffold(
      appBar: AppBar(
        title: Text(farmacia.localNombre),
        actions: [
          IconButton(
            onPressed: () => _compartir(context),
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header con información principal
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          farmacia.localNombre,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (widget.farmaciaConDistancia.esDeTurno)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'DE TURNO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.near_me_outlined,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'A ${widget.farmaciaConDistancia.distanciaFormateada} de distancia',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Información de contacto y ubicación
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildInfoCard(
                    context,
                    'Ubicación',
                    [
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        'Dirección',
                        farmacia.localDireccion,
                        onTap: () => _copiarAlPortapapeles(context, '${farmacia.localDireccion}, ${farmacia.comunaNombre}'),
                      ),
                      _buildInfoRow(
                        Icons.place_outlined,
                        'Comuna',
                        farmacia.comunaNombre,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildInfoCard(
                    context,
                    'Horarios',
                    [
                      if (widget.farmaciaConDistancia.esDeTurno)
                        _buildInfoRow(
                          Icons.access_time,
                          'Estado',
                          'Abierta 24 horas',
                          textColor: AppTheme.accentColor,
                        )
                      else ...[
                        _buildInfoRow(
                          Icons.schedule,
                          'Atención',
                          '${_formatTime(farmacia.funcionamientoHoraApertura)} - ${_formatTime(farmacia.funcionamientoHoraCierre)}',
                        ),
                      ],
                      _buildInfoRow(
                        Icons.today_outlined,
                        'Día',
                        _capitalizarPrimeraLetra(farmacia.funcionamientoDia),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Botones de acción
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _abrirEnGoogleMaps(),
                    icon: const Icon(Icons.directions),
                    label: const Text('Cómo llegar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),

                  if (_isValidPhoneNumber(farmacia.localTelefono)) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _llamar(farmacia.localTelefono),
                      icon: const Icon(Icons.phone),
                      label: const Text('Llamar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Banner publicitario
            if (_isBannerAdLoaded && _bannerAd != null)
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: 60,
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String titulo, List<Widget> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 20,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return timeString;
    } catch (e) {
      return timeString;
    }
  }

  String _capitalizarPrimeraLetra(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
  }
  
  bool _isValidPhoneNumber(String telefono) {
    if (telefono.isEmpty) return false;
    final regex = RegExp(r'^\+56\d{4,}$');
    return regex.hasMatch(telefono);
  }

  Future<void> _abrirEnGoogleMaps() async {
    final farmacia = widget.farmaciaConDistancia.farmacia;
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${farmacia.localLat},${farmacia.localLng}&travelmode=driving';
    
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Si falla, intentar abrir la aplicación de Google Maps directamente
      final googleMapsUrl = 'google.navigation:q=${farmacia.localLat},${farmacia.localLng}';
      try {
        final uri = Uri.parse(googleMapsUrl);
        await launchUrl(uri);
      } catch (e) {
        // Como último recurso, abrir en el navegador
        final webUrl = 'https://maps.google.com/?q=${farmacia.localLat},${farmacia.localLng}';
        final uri = Uri.parse(webUrl);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _llamar(String telefono) async {
    final url = 'tel:$telefono';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      // Manejar error silenciosamente
    }
  }

  Future<void> _copiarAlPortapapeles(BuildContext context, String texto) async {
    await Clipboard.setData(ClipboardData(text: texto));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dirección copiada al portapapeles'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _compartir(BuildContext context) {
    final farmacia = widget.farmaciaConDistancia.farmacia;
    final texto = '''
${farmacia.localNombre}
${farmacia.localDireccion}
${farmacia.comunaNombre}

${widget.farmaciaConDistancia.esDeTurno ? 'Farmacia de turno - Abierta 24 horas' : 'Horario: ${_formatTime(farmacia.funcionamientoHoraApertura)} - ${_formatTime(farmacia.funcionamientoHoraCierre)}'}

Distancia: ${widget.farmaciaConDistancia.distanciaFormateada}
${farmacia.localTelefono.isNotEmpty ? 'Teléfono: ${farmacia.localTelefono}' : ''}

Ubicación: https://maps.google.com/?q=${farmacia.localLat},${farmacia.localLng}
''';

    // En una implementación real, usarías el plugin share_plus
    // Share.share(texto, subject: 'Farmacia ${farmacia.localNombre}');
    
    // Por ahora, copiar al portapapeles
    _copiarAlPortapapeles(context, texto);
  }
}