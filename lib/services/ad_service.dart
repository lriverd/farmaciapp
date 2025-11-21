import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Servicio para gestionar anuncios de Google AdMob
class AdService {
  /// ID de la app de AdMob para Android
  static const String _androidAppId = 'ca-app-pub-7060454650201968~4128813276';
  
  /// ID de la app de AdMob para iOS
  static const String _iosAppId = 'ca-app-pub-7060454650201968~4128813276';

  /// ID del banner para Android (Home)
  static const String _androidBannerHomeId = 'ca-app-pub-7060454650201968/4923020192';
  
  /// ID del banner para iOS (Home)
  static const String _iosBannerHomeId = 'ca-app-pub-7060454650201968/4923020192';
  
  /// ID del banner para Android (Lista de farmacias)
  static const String _androidBannerListId = 'ca-app-pub-7060454650201968/3588612988';
  
  /// ID del banner para iOS (Lista de farmacias)
  static const String _iosBannerListId = 'ca-app-pub-7060454650201968/3588612988';
  
  /// ID del banner para Android (Detalle de farmacia)
  static const String _androidBannerDetailId = 'ca-app-pub-7060454650201968/5456228425';
  
  /// ID del banner para iOS (Detalle de farmacia)
  static const String _iosBannerDetailId = 'ca-app-pub-7060454650201968/5456228425';
  
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

  /// Obtiene el ID del banner según la plataforma y ubicación
  /// [location] puede ser 'home', 'list' o 'detail'
  static String getBannerAdUnitId({String location = 'home'}) {
    try {
      if (kIsWeb) {
        return _testBannerId;
      }
      
      if (Platform.isAndroid) {
        switch (location) {
          case 'list':
            return _androidBannerListId;
          case 'detail':
            return _androidBannerDetailId;
          case 'home':
          default:
            return _androidBannerHomeId;
        }
      } else if (Platform.isIOS) {
        switch (location) {
          case 'list':
            return _iosBannerListId;
          case 'detail':
            return _iosBannerDetailId;
          case 'home':
          default:
            return _iosBannerHomeId;
        }
      }
      throw UnsupportedError('Plataforma no soportada');
    } catch (e) {
      // En tests, retornar ID de prueba
      return _testBannerId;
    }
  }
  
  /// Obtiene el ID del banner según la plataforma (para compatibilidad)
  /// @deprecated Usar getBannerAdUnitId con parámetro location
  static String get bannerAdUnitId => getBannerAdUnitId();

  /// Crea un banner ad
  /// [location] puede ser 'home', 'list' o 'detail'
  static BannerAd createBannerAd({
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
    String location = 'home',
  }) {
    return BannerAd(
      adUnitId: getBannerAdUnitId(location: location),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }
}
