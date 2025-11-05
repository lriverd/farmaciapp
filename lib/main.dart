import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/theme_service.dart';
import 'services/ad_service.dart';
import 'services/analytics_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp();
  
  // Configurar Crashlytics para capturar errores de Flutter
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  // Configurar Crashlytics para errores asíncronos
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  // Inicializar servicios
  await StorageService.init();
  
  // Inicializar servicio de tema
  final themeService = ThemeService();
  await themeService.init();
  
  // Inicializar AdMob
  await AdService.initialize();
  
  runApp(
    ChangeNotifierProvider.value(
      value: themeService,
      child: const FarmaciaApp(),
    ),
  );
}

class FarmaciaApp extends StatelessWidget {
  const FarmaciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    
    return MaterialApp(
      title: 'Farmacias de Turno Chile',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      navigatorObservers: [AnalyticsService.observer],
    );
  }
}
