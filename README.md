# Farmacias de Turno Chile 🏥💊

Aplicación móvil Flutter para encontrar farmacias de turno (24 horas) y farmacias cercanas en Chile, con datos oficiales del Ministerio de Salud (MINSAL).

[![Flutter](https://img.shields.io/badge/Flutter-3.35.7-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Proprietary-red)](LICENSE)

## 📱 Características Principales

### Búsqueda Inteligente
- 🎯 **Búsqueda por GPS**: Encuentra farmacias cercanas usando tu ubicación actual
- 📝 **Búsqueda Manual**: Busca por comuna o localidad específica
- 🔄 **Radio Ajustable**: Configura el radio de búsqueda (1-50 km)

### Información Detallada
- 🕒 **Farmacias de Turno**: Identificación clara de farmacias 24/7
- ⏰ **Horarios**: Información de horarios de apertura y cierre
- 📍 **Distancia**: Cálculo preciso desde tu ubicación
- 📞 **Llamadas Directas**: Contacta farmacias directamente desde la app
- 🗺️ **Integración Maps**: Navegación con Google Maps

### Filtros Avanzados
- 🏪 **Solo de Turno**: Muestra únicamente farmacias 24 horas
- � **Solo Abiertas**: Filtra por horario actual
- 🏘️ **Por Comuna**: Búsqueda específica por ubicación

### Experiencia de Usuario
- 🌓 **Modo Oscuro/Claro**: Tema adaptativo con cambio dinámico
- � **Caché Inteligente**: Actualización cada 24 horas para rendimiento óptimo
- 📊 **Analytics**: Monitoreo de uso y mejora continua
- 🎨 **Diseño Moderno**: Interfaz Material Design adaptada a Chile

### Monetización
- 📢 **Google AdMob**: Banner publicitario no intrusivo

## 🛠️ Tecnologías Utilizadas

### Core
- **Flutter** 3.35.7 - Framework multiplataforma
- **Dart** ^3.9.2 - Lenguaje de programación

### Servicios Firebase
- **Firebase Core** - Inicialización
- **Firebase Crashlytics** - Monitoreo de errores
- **Firebase Analytics** - Métricas de uso

### Funcionalidades
- **Geolocator** ^10.1.0 - Geolocalización y permisos
- **Google Maps Flutter** ^2.5.0 - Mapas interactivos
- **Google Mobile Ads** ^5.1.0 - Publicidad
- **HTTP** ^1.1.0 - Consumo de API REST
- **Provider** ^6.1.1 - State management
- **Shared Preferences** ^2.2.2 - Almacenamiento local
- **Permission Handler** ^11.0.1 - Gestión de permisos
- **URL Launcher** ^6.2.1 - Enlaces externos
- **Package Info Plus** ^8.1.2 - Información de la app
- **Intl** ^0.18.1 - Internacionalización

## 🚀 Instalación y Configuración

### Prerrequisitos

```bash
Flutter SDK: >= 3.9.2
Dart SDK: >= 3.9.2
Android Studio / Xcode
Git
```

### Clonar e Instalar

```bash
# Clonar repositorio
git clone https://github.com/lriverd/farmaciapp.git
cd farmaciaap

# Instalar dependencias
flutter pub get

# Ejecutar la app
flutter run
```

### Configuración de Firebase (Requerido)

1. **Crear proyecto en Firebase Console**
   - Ir a [Firebase Console](https://console.firebase.google.com/)
   - Crear proyecto o usar existente

2. **Configurar Android**
   ```bash
   # Descargar google-services.json
   # Colocar en: android/app/google-services.json
   ```

3. **Configurar iOS** (opcional)
   ```bash
   # Descargar GoogleService-Info.plist
   # Colocar en: ios/Runner/GoogleService-Info.plist
   ```

### Configuración de AdMob (Opcional)

Editar `lib/services/ad_service.dart` con tus IDs:
```dart
static const String _androidAppId = 'ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY';
static const String _androidBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/BBBBBBBBBB';
```

## 📦 Compilación

### Debug
```bash
# Android APK
flutter build apk --debug

# Android App Bundle
flutter build appbundle --debug
```

### Release
```bash
# Android APK
flutter build apk --release

# Android App Bundle (para Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 🧪 Testing

```bash
# Ejecutar todos los tests
flutter test

# Tests con coverage
flutter test --coverage

# Análisis estático
flutter analyze
```

### Coverage Actual
- **Tests Unitarios**: 74 tests pasando
- **Services**: 100% coverage
- **Models**: 95% coverage
- **Utils**: 100% coverage
- **Theme**: 100% coverage

## 📊 Arquitectura

### Estructura de Directorios

```
lib/
├── main.dart                 # Entry point con Firebase init
├── models/                   # Modelos de datos
│   ├── farmacia.dart
│   ├── farmacia_con_distancia.dart
│   └── local_comercial.dart
├── screens/                  # Pantallas de la UI
│   ├── home_screen.dart
│   ├── farmacia_list_screen.dart
│   ├── farmacia_detail_screen.dart
│   └── about_screen.dart
├── services/                 # Lógica de negocio
│   ├── api_service.dart      # Comunicación HTTP
│   ├── farmacia_service.dart # Lógica de farmacias
│   ├── location_service.dart # Geolocalización
│   ├── storage_service.dart  # SharedPreferences
│   ├── theme_service.dart    # Gestión de temas
│   ├── ad_service.dart       # Google AdMob
│   └── analytics_service.dart # Firebase Analytics
├── theme/                    # Configuración de temas
│   └── app_theme.dart
├── utils/                    # Utilidades
│   ├── constants.dart
│   └── date_utils.dart
└── widgets/                  # Widgets reutilizables
    ├── empty_state.dart
    ├── error_display.dart
    └── farmacia_card.dart
```

### Patrones de Diseño

- **Provider**: State management con ChangeNotifier
- **Service Layer**: Separación de lógica de negocio
- **Repository Pattern**: Caché y gestión de datos
- **Singleton**: Servicios únicos (Analytics, Storage)

## 📡 API y Fuentes de Datos

### API MINSAL
```
https://midas.minsal.cl/farmacia_v2/WS/getLocalesTurnos.php
https://midas.minsal.cl/farmacia_v2/WS/getLocalesRegion.php
```

**Características**:
- Datos oficiales del Ministerio de Salud
- Actualización en tiempo real
- Sin autenticación requerida
- Formato JSON

### Caché Local
- **SharedPreferences** para farmacias
- **Actualización**: Cada 24 horas automáticamente
- **Persistencia**: Modo offline básico

## 🔐 Permisos

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para encontrar farmacias cercanas</string>
```

## 📈 Monitoreo y Analytics

### Firebase Crashlytics
- Captura automática de crashes
- Errores no fatales registrados
- Stack traces completos
- Información de dispositivo

### Firebase Analytics
Eventos monitoreados:
- `busqueda_farmacias` (GPS/manual, resultados, radio)
- `ver_detalle_farmacia` (ID, nombre, distancia)
- `llamar_farmacia` (ID, nombre)
- `aplicar_filtros` (solo_turno, solo_abiertas, comuna)
- `cambio_tema` (light/dark)
- `ver_acerca_de`
- `error_no_fatal` (contexto, mensaje)

## 🚧 Roadmap

- [x] Búsqueda por ubicación GPS
- [x] Filtros avanzados
- [x] Modo oscuro/claro
- [x] Integración Firebase
- [x] Google AdMob
- [ ] Favoritos y historial
- [ ] Notificaciones de turno
- [ ] Compartir farmacias
- [ ] Búsqueda por productos
- [ ] Mapa interactivo con clusters

## 📄 Licencia

Este proyecto es de código cerrado y propiedad de DUAMIT.

## 👨‍💻 Autor

**Luis Riveros**  
- GitHub: [@lriverd](https://github.com/lriverd)
- Organización: DUAMIT

## 🙏 Agradecimientos

- **Ministerio de Salud de Chile (MINSAL)** - Por proporcionar la API pública de farmacias
- **Comunidad Flutter** - Por las excelentes librerías open source
- **Google Firebase** - Por las herramientas de monitoreo y analytics

---

**Versión**: 1.0.2+4  
**Última actualización**: Noviembre 2025  
**Plataformas**: Android 5.0+ | iOS 12.0+



2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación**
   ```bash
   # Para desarrollo
   flutter run
   
   # Para release
   flutter run --release
   ```

## 🏗️ Arquitectura

### Estructura del proyecto

```
lib/
├── main.dart                     # Punto de entrada
├── models/                       # Modelos de datos
│   ├── farmacia.dart            # Modelo de farmacia
│   └── farmacia_con_distancia.dart
├── services/                     # Servicios y lógica de negocio
│   ├── api_service.dart         # Consumo de APIs
│   ├── location_service.dart    # Servicios de geolocalización
│   ├── storage_service.dart     # Persistencia local
│   └── farmacia_service.dart    # Lógica principal de farmacias
├── screens/                      # Pantallas de la aplicación
│   ├── home_screen.dart         # Pantalla principal
│   ├── farmacia_list_screen.dart # Lista de resultados
│   └── farmacia_detail_screen.dart # Detalle de farmacia
├── widgets/                      # Componentes reutilizables
│   ├── farmacia_card.dart       # Tarjeta de farmacia
│   ├── loading_widget.dart      # Indicador de carga
│   └── empty_state_widget.dart  # Estados vacíos
├── utils/                        # Utilidades
│   ├── constants.dart           # Constantes de la app
│   ├── distance_calculator.dart # Cálculos de distancia
│   └── date_utils.dart         # Utilidades de fecha
└── theme/
    └── app_theme.dart          # Tema de la aplicación
```

## 🔗 APIs Utilizadas

### 1. Universo de Farmacias
- **URL**: `https://midas.minsal.cl/farmacia_v2/WS/getLocales.php`
- **Función**: Obtiene todas las farmacias disponibles
- **Caché**: Se actualiza cada 24 horas

### 2. Farmacias de Turno
- **URL**: `https://midas.minsal.cl/farmacia_v2/WS/getLocalesTurnos.php`
- **Función**: Obtiene farmacias que están de turno
- **Caché**: Se actualiza al cambiar el día o cada 24 horas

## 🎯 Funcionalidades Principales

### Búsqueda por Ubicación
- Solicita permisos de ubicación GPS
- Permite seleccionar radio de búsqueda (5, 10, 15, 20 km)
- Ordena resultados: primero farmacias de turno, luego por distancia

### Sistema de Filtros
- **Solo de turno**: Muestra únicamente farmacias 24 horas
- **Por comuna**: Filtra por comuna específica
- **Por nombre**: Búsqueda de texto en el nombre de la farmacia

### Información Detallada
- Dirección completa con opción de copiar
- Horarios de funcionamiento
- Teléfono con opción de llamada directa
- Integración con Google Maps para navegación

## 🎨 Diseño

### Paleta de Colores
- **Primario**: Verde médico (#4CAF50) - representa salud y confianza
- **Secundario**: Azul (#2196F3) - tecnología y claridad  
- **Acento**: Naranja (#FF9800) - resalta farmacias de turno
- **Texto**: Gris oscuro (#333333)

### Principios de Diseño
- **Minimalismo**: Interfaz limpia y sin distracciones
- **Accesibilidad**: Contraste adecuado y elementos touch-friendly
- **Feedback visual**: Estados de carga y confirmaciones claras
- **Navegación intuitiva**: Flujo lógico entre pantallas

## 🔧 Configuración de Permisos

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS (ios/Runner/Info.plist)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Esta aplicación necesita acceso a tu ubicación para encontrar farmacias cercanas a ti.</string>
```

## 📦 Dependencias Principales

- `http: ^1.1.0` - Peticiones HTTP
- `geolocator: ^10.1.0` - Servicios de ubicación
- `permission_handler: ^11.0.1` - Manejo de permisos
- `google_maps_flutter: ^2.5.0` - Mapas de Google
- `shared_preferences: ^2.2.2` - Almacenamiento local
- `url_launcher: ^6.2.1` - Launcher de URLs
- `intl: ^0.18.1` - Internacionalización y formato de fechas

## 🚀 Características Técnicas

### Manejo de Estados
- Estados de carga con indicadores visuales
- Manejo de errores con mensajes informativos
- Estados vacíos con acciones sugeridas

### Optimizaciones
- Caché inteligente de datos de APIs
- Lazy loading de listas largas
- Compresión y limpieza de datos Unicode
- Debounce en búsquedas de texto

### Offline Support
- Fallback a datos almacenados localmente
- Indicadores de estado de conexión
- Actualización manual de datos

Desarrollado con ❤️ en Flutter para la comunidad chilena 🇨🇱
