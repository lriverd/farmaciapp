import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/farmacia.dart';
import '../utils/constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call StorageService.init() first.');
    }
    return _prefs!;
  }

  // Guardar farmacias del universo
  static Future<bool> saveFarmacias(List<Farmacia> farmacias) async {
    try {
      final jsonList = farmacias.map((f) => f.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      final now = DateTime.now();
      await _instance.setString(AppConstants.keyFarmacias, jsonString);
      // Sincronizar timestamp con el de turnos para mantener coherencia
      await _instance.setString(AppConstants.keyLastUpdateFarmacias, now.toIso8601String());
      await _instance.setString(AppConstants.keyLastUpdateTurnos, now.toIso8601String());
      await _instance.setString(AppConstants.keyLastUpdateDay, _getCurrentDay());
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Obtener farmacias del universo
  static List<Farmacia> getFarmacias() {
    try {
      final jsonString = _instance.getString(AppConstants.keyFarmacias);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Farmacia.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Guardar farmacias de turno
  static Future<bool> saveFarmaciasTurno(List<String> farmaciaIds) async {
    try {
      final jsonString = jsonEncode(farmaciaIds);
      
      await _instance.setString(AppConstants.keyFarmaciasTurno, jsonString);
      await _instance.setString(AppConstants.keyLastUpdateTurnos, DateTime.now().toIso8601String());
      await _instance.setString(AppConstants.keyLastUpdateDay, _getCurrentDay());
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Obtener IDs de farmacias de turno
  static List<String> getFarmaciasTurnoIds() {
    try {
      final jsonString = _instance.getString(AppConstants.keyFarmaciasTurno);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.cast<String>();
    } catch (e) {
      return [];
    }
  }

  // Verificar si los datos de farmacias necesitan actualización
  static bool shouldUpdateFarmacias() {
    final lastUpdate = _instance.getString(AppConstants.keyLastUpdateFarmacias);
    if (lastUpdate == null) return true;

    try {
      final lastUpdateDate = DateTime.parse(lastUpdate);
      final now = DateTime.now();
      final difference = now.difference(lastUpdateDate);
      
      return difference.inHours >= 24;
    } catch (e) {
      return true;
    }
  }

  // Verificar si los datos de turnos necesitan actualización
  static bool shouldUpdateTurnos() {
    final lastUpdate = _instance.getString(AppConstants.keyLastUpdateTurnos);
    final lastDay = _instance.getString(AppConstants.keyLastUpdateDay);
    final currentDay = _getCurrentDay();

    if (lastUpdate == null || lastDay == null) return true;

    // Si cambió el día, actualizar
    if (lastDay != currentDay) return true;

    // Si han pasado más de 24 horas, actualizar
    try {
      final lastUpdateDate = DateTime.parse(lastUpdate);
      final now = DateTime.now();
      final difference = now.difference(lastUpdateDate);
      
      return difference.inHours >= 24;
    } catch (e) {
      return true;
    }
  }

  // Obtener el nombre del día actual
  static String _getCurrentDay() {
    final weekdays = [
      'lunes', 'martes', 'miércoles', 'jueves', 
      'viernes', 'sábado', 'domingo'
    ];
    final today = DateTime.now().weekday - 1;
    return weekdays[today];
  }

  // Limpiar todos los datos guardados
  static Future<bool> clearAllData() async {
    try {
      await _instance.remove(AppConstants.keyFarmacias);
      await _instance.remove(AppConstants.keyFarmaciasTurno);
      await _instance.remove(AppConstants.keyLastUpdateFarmacias);
      await _instance.remove(AppConstants.keyLastUpdateTurnos);
      await _instance.remove(AppConstants.keyLastUpdateDay);
      return true;
    } catch (e) {
      return false;
    }
  }
}