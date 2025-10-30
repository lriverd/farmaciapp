import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/farmacia.dart';
import '../utils/constants.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 30);

  /// Obtiene el universo completo de farmacias
  static Future<List<Farmacia>> getLocales() async {
    try {
      final response = await http
          .get(
            Uri.parse(AppConstants.localesApiUrl),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

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
    } on http.ClientException {
      throw ApiException('Error de conexión. Verifique su conexión a internet.');
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
      final response = await http
          .get(
            Uri.parse(AppConstants.turnosApiUrl),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

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
    } on http.ClientException {
      throw ApiException('Error de conexión. Verifique su conexión a internet.');
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