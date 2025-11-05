import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Servicio para gestionar anuncios de Google AdMob
class AdService {
  /// ID de la app de AdMob para Android
  static const String _androidAppId = 'ca-app-pub-7060454650201968~4128813276';
  
  /// ID de la app de AdMob para iOS
  static const String _iosAppId = 'ca-app-pub-7060454650201968~4128813276';

  /// ID del banner para Android
  static const String _androidBannerId = 'ca-app-pub-7060454650201968/4923020192';
  
  /// ID del banner para iOS
  static const String _iosBannerId = 'ca-app-pub-7060454650201968/4923020192';
  
  /// ID de prueba de banner para Android
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';

  /// Inicializa el SDK de Mobile Ads
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// Obtiene el ID de la app según la plataforma
  static String get appId {
    try {
      if (kIsWeb) {
        return _androidAppId;
      }
      
      if (Platform.isAndroid) {
        return _androidAppId;
      } else if (Platform.isIOS) {
        return _iosAppId;
      }
      throw UnsupportedError('Plataforma no soportada');
    } catch (e) {
      // En tests, retornar ID por defecto
      return _androidAppId;
    }
  }

  /// Obtiene el ID del banner según la plataforma
  static String get bannerAdUnitId {
    try {
      if (kIsWeb) {
        return _testBannerId;
      }
      
      if (Platform.isAndroid) {
        return _androidBannerId;
      } else if (Platform.isIOS) {
        return _iosBannerId;
      }
      throw UnsupportedError('Plataforma no soportada');
    } catch (e) {
      // En tests, retornar ID de prueba
      return _testBannerId;
    }
  }

  /// Crea un banner ad
  static BannerAd createBannerAd({
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }
}
