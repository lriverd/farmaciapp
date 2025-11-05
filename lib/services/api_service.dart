import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../models/farmacia.dart';
import '../utils/constants.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 30);
  static http.Client? _client;

  /// Obtiene el cliente HTTP con configuración SSL personalizada
  static http.Client get _httpClient {
    if (_client != null) return _client!;

    // Crear HttpClient con configuración SSL para manejar problemas de certificados
    final ioClient = HttpClient();
    
    // Permitir certificados del dominio MINSAL incluso si hay problemas de cadena
    // Esto es necesario porque algunos dispositivos tienen certificados raíz desactualizados
    ioClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      // Solo permitir para el dominio MINSAL
      return host == 'midas.minsal.cl';
    };

    _client = IOClient(ioClient);
    return _client!;
  }

  /// Obtiene el universo completo de farmacias
  static Future<List<Farmacia>> getLocales() async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse(AppConstants.localesApiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout, onTimeout: () {
            throw ApiException('Tiempo de espera agotado');
          });

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonList = jsonDecode(responseBody);
        
        return jsonList
            .map((json) => Farmacia.fromJson(json as Map<String, dynamic>))
            .where((farmacia) => _isValidFarmacia(farmacia))
            .toList();
      } else {
        throw ApiException('Error del servidor: ${response.statusCode}');
      }
    } on SocketException {
      throw ApiException('Sin conexión a internet. Verifique su conexión.');
    } on HttpException {
      throw ApiException('Error HTTP. Intente nuevamente.');
    } on HandshakeException {
      throw ApiException('Error de conexión segura. Verifique la fecha y hora de su dispositivo.');
    } on FormatException {
      throw ApiException('Error al procesar los datos del servidor.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Obtiene las farmacias que están de turno
  static Future<List<Farmacia>> getLocalesTurnos() async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse(AppConstants.turnosApiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout, onTimeout: () {
            throw ApiException('Tiempo de espera agotado');
          });

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonList = jsonDecode(responseBody);
        
        return jsonList
            .map((json) => Farmacia.fromJson(json as Map<String, dynamic>))
            .where((farmacia) => _isValidFarmacia(farmacia))
            .toList();
      } else {
        throw ApiException('Error del servidor: ${response.statusCode}');
      }
    } on SocketException {
      throw ApiException('Sin conexión a internet. Verifique su conexión.');
    } on HttpException {
      throw ApiException('Error HTTP. Intente nuevamente.');
    } on HandshakeException {
      throw ApiException('Error de conexión segura. Verifique la fecha y hora de su dispositivo.');
    } on FormatException {
      throw ApiException('Error al procesar los datos del servidor.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Valida que una farmacia tenga los datos mínimos requeridos
  static bool _isValidFarmacia(Farmacia farmacia) {
    return farmacia.localId.isNotEmpty &&
           farmacia.localNombre.isNotEmpty &&
           farmacia.comunaNombre.isNotEmpty &&
           farmacia.localLat != 0.0 &&
           farmacia.localLng != 0.0;
  }

  /// Libera los recursos del cliente HTTP
  static void dispose() {
    _client?.close();
    _client = null;
  }

  /// Verifica la conectividad realizando una petición simple
  static Future<bool> checkConnectivity() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

class ApiException implements Exception {
  final String message;
  
  const ApiException(this.message);
  
  @override
  String toString() => 'ApiException: $message';
}