# Documentación Técnica - Farmacias de Turno Chile

## Tabla de Contenidos

1. [Arquitectura General](#arquitectura-general)
2. [Flujo de Datos](#flujo-de-datos)
3. [Servicios](#servicios)
4. [Modelos de Datos](#modelos-de-datos)
5. [Gestión de Estado](#gestión-de-estado)
6. [Integración con APIs Externas](#integración-con-apis-externas)
7. [Almacenamiento y Caché](#almacenamiento-y-caché)
8. [Monitoreo y Analytics](#monitoreo-y-analytics)
9. [Rendimiento y Optimización](#rendimiento-y-optimización)
10. [Seguridad](#seguridad)

---

## Arquitectura General

### Principios de Diseño

La aplicación sigue los principios de **Clean Architecture** adaptada para Flutter, con una clara separación de responsabilidades:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (Screens, Widgets, Theme)              │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Business Logic Layer            │
│  (Services, State Management)           │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Data Layer                      │
│  (API, Storage, Models)                 │
└─────────────────────────────────────────┘
```

### Capas de la Aplicación

#### 1. Presentation Layer (UI)
- **Screens**: Pantallas principales de la aplicación
- **Widgets**: Componentes reutilizables
- **Theme**: Configuración de temas (light/dark)

#### 2. Business Logic Layer
- **Services**: Lógica de negocio encapsulada
- **State Management**: Provider para gestión de estado
- **Analytics**: Monitoreo de eventos y errores

#### 3. Data Layer
- **API Client**: Comunicación con backend MINSAL
- **Storage**: Persistencia local con SharedPreferences
- **Models**: Estructuras de datos

---

## Flujo de Datos

### 1. Búsqueda de Farmacias por GPS

```mermaid
sequenceDiagram
    participant U as Usuario
    participant HS as HomeScreen
    participant LS as LocationService
    participant FS as FarmaciaService
    participant API as API MINSAL
    participant SS as StorageService
    participant FL as FarmaciaListScreen

    U->>HS: Click "Buscar"
    HS->>LS: getLocationStatus()
    LS-->>HS: LocationStatus
    
    alt Permisos OK
        HS->>LS: getCurrentPosition()
        LS-->>HS: Position
        HS->>FS: getFarmaciasCercanas(pos, radius)
        
        alt Caché válido
            FS->>SS: getFarmacias()
            SS-->>FS: List<Farmacia>
        else Caché expirado
            FS->>API: getLocalesTurnos()
            API-->>FS: JSON Response
            FS->>SS: saveFarmacias()
        end
        
        FS->>FS: _calcularDistancias()
        FS->>FS: _ordenarPorDistancia()
        FS-->>HS: List<FarmaciaConDistancia>
        HS->>FL: Navigate con resultados
    else Sin permisos
        HS-->>U: Mostrar error
    end
```

### 2. Filtros de Búsqueda

```mermaid
sequenceDiagram
    participant U as Usuario
    participant FLS as FarmaciaListScreen
    participant State as Estado Local

    U->>FLS: Abrir filtros
    FLS->>U: Mostrar modal
    U->>FLS: Cambiar filtros
    FLS->>State: Actualizar variables
    U->>FLS: Aplicar filtros
    FLS->>FLS: _aplicarFiltros()
    FLS->>FLS: _filtrarFarmacias()
    FLS->>FLS: setState()
    FLS-->>U: Mostrar resultados filtrados
```

### 3. Cambio de Tema

```mermaid
sequenceDiagram
    participant U as Usuario
    participant HS as HomeScreen
    participant TS as ThemeService
    participant SP as SharedPreferences
    participant UI as MaterialApp

    U->>HS: Click botón tema
    HS->>TS: toggleTheme()
    TS->>TS: setThemeMode(nuevo)
    TS->>SP: saveString('theme_mode')
    TS->>TS: notifyListeners()
    TS-->>UI: Rebuild con nuevo tema
    UI-->>U: Actualizar interfaz
```

---

## Servicios

### 1. ApiService

**Propósito**: Gestionar comunicaciones HTTP con la API del MINSAL.

**Características**:
- Cliente HTTP personalizado con manejo de certificados SSL
- Reintentos automáticos en caso de fallo
- Manejo de errores específico por código HTTP
- Soporte para conexiones inseguras (certificados caducados)

**Implementación**:

```dart
class ApiService {
  static final HttpClient _httpClient = HttpClient()
    ..badCertificateCallback = (cert, host, port) {
      // Permitir certificados del MINSAL
      return host == 'midas.minsal.cl';
    };

  static Future<dynamic> get(String endpoint) async {
    try {
      final ioClient = IOClient(_httpClient);
      final response = await ioClient.get(
        Uri.parse(endpoint),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw ApiException(response.statusCode);
    } on HandshakeException {
      // Manejar errores SSL
      throw SSLException();
    }
  }
}
```

**Casos de Uso**:
1. Obtener farmacias de turno
2. Buscar por localidad/comuna
3. Consultar por región

### 2. FarmaciaService

**Propósito**: Lógica de negocio para farmacias.

**Responsabilidades**:
- Coordinar API y Storage
- Calcular distancias geográficas
- Ordenar y filtrar resultados
- Gestionar caché

**Métodos Principales**:

```dart
class FarmaciaService {
  /// Obtiene farmacias cercanas por GPS
  static Future<List<FarmaciaConDistancia>> getFarmaciasCercanas({
    required Position userPosition,
    required double radius,
  }) async {
    // 1. Obtener farmacias (caché o API)
    final farmacias = await _getFarmaciasCached();
    
    // 2. Calcular distancias
    final conDistancias = _calcularDistancias(
      farmacias, 
      userPosition
    );
    
    // 3. Filtrar por radio
    final cercanas = conDistancias.where(
      (f) => f.distancia <= radius
    ).toList();
    
    // 4. Ordenar
    cercanas.sort((a, b) => 
      a.distancia.compareTo(b.distancia)
    );
    
    return cercanas;
  }
  
  /// Cálculo de distancia Haversine
  static double _calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const R = 6371; // Radio de la Tierra en km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * 
        math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }
}
```

**Optimizaciones**:
- Caché de 24 horas para reducir llamadas API
- Cálculo de distancias solo para farmacias visibles
- Ordenamiento eficiente con algoritmo QuickSort nativo

### 3. LocationService

**Propósito**: Gestionar geolocalización y permisos.

**Estados de Ubicación**:

```dart
enum LocationStatus {
  available,           // Listo para usar
  serviceDisabled,     // GPS deshabilitado
  permissionDenied,    // Permiso denegado temporalmente
  permissionDeniedPermanently, // Permiso denegado permanente
  unknown             // Error desconocido
}
```

**Flujo de Permisos**:

```
Inicio
  │
  ▼
¿Servicio habilitado?
  │         │
  NO        SÍ
  │         │
  └─────────▼
     ¿Tiene permiso?
         │       │
         NO      SÍ
         │       │
         ▼       │
   Solicitar ────┘
         │
         ▼
   ¿Concedido?
    │       │
    NO      SÍ
    │       │
    ▼       ▼
  Error  Ubicación
```

### 4. StorageService

**Propósito**: Persistencia local con SharedPreferences.

**Datos Almacenados**:
- Farmacias (JSON serializado)
- Timestamp de última actualización
- Preferencias de tema
- Configuraciones de usuario

**Estrategia de Caché**:

```dart
class StorageService {
  static const Duration _cacheExpiration = Duration(hours: 24);
  
  static Future<bool> isCacheValid() async {
    final timestamp = _prefs!.getString(_farmaciasTimestampKey);
    if (timestamp == null) return false;
    
    final lastUpdate = DateTime.parse(timestamp);
    final now = DateTime.now();
    
    return now.difference(lastUpdate) < _cacheExpiration;
  }
}
```

### 5. ThemeService

**Propósito**: Gestión de temas con Provider.

**Características**:
- Cambio dinámico entre light/dark/system
- Persistencia de preferencia
- Notificación automática a widgets

**Implementación**:

```dart
class ThemeService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    
    notifyListeners(); // Actualizar UI
    await _savePreference();
  }
}
```

### 6. AnalyticsService

**Propósito**: Monitoreo con Firebase Analytics y Crashlytics.

**Eventos Registrados**:

| Evento | Parámetros | Propósito |
|--------|-----------|-----------|
| `busqueda_farmacias` | metodo, resultados, radio, comuna | Analizar patrones de búsqueda |
| `ver_detalle_farmacia` | id, nombre, distancia | Medir engagement |
| `llamar_farmacia` | id, nombre | Tracking de conversión |
| `aplicar_filtros` | solo_turno, solo_abiertas, comuna | Uso de filtros |
| `cambio_tema` | modo | Preferencias de UX |
| `error_no_fatal` | mensaje, contexto | Debugging |

**Crashlytics**:
```dart
// Registro automático de crashes
FlutterError.onError = 
    FirebaseCrashlytics.instance.recordFlutterFatalError;

// Errores asíncronos
PlatformDispatcher.instance.onError = (error, stack) {
  FirebaseCrashlytics.instance.recordError(
    error, stack, fatal: true
  );
  return true;
};
```

### 7. AdService

**Propósito**: Gestión de publicidad con Google AdMob.

**Tipos de Anuncios**:
- **Banner**: Footer de HomeScreen
- **Intersticial**: (Futuro) Entre pantallas
- **Rewarded**: (Futuro) Funciones premium

**Implementación**:

```dart
class AdService {
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
```

---

## Modelos de Datos

### 1. Farmacia

**Estructura**:
```dart
class Farmacia {
  final String localId;
  final String localNombre;
  final String localDireccion;
  final String comunaNombre;
  final String localTelefono;
  final double localLat;
  final double localLng;
  final String funcionamientoHoraApertura;
  final String funcionamientoHoraCierre;
  final DateTime fecha;
  
  // JSON Serialization
  factory Farmacia.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

**Campos Calculados**:
```dart
class Farmacia {
  /// Determina si la farmacia está de turno (24 horas)
  bool get esDeTurno => 
      funcionamientoHoraApertura == '00:00:00' && 
      funcionamientoHoraCierre == '23:59:59';
  
  /// Verifica si está abierta en el momento actual
  bool get estaAbierta {
    final now = DateTime.now();
    final apertura = _parseHora(funcionamientoHoraApertura);
    final cierre = _parseHora(funcionamientoHoraCierre);
    
    return now.isAfter(apertura) && now.isBefore(cierre);
  }
}
```

### 2. FarmaciaConDistancia

**Propósito**: Extender Farmacia con información de distancia.

```dart
class FarmaciaConDistancia {
  final Farmacia farmacia;
  final double distancia; // en kilómetros
  final bool esDeTurno;
  
  // Helpers
  String get distanciaFormateada {
    if (distancia < 1) {
      return '${(distancia * 1000).toStringAsFixed(0)} m';
    }
    return '${distancia.toStringAsFixed(1)} km';
  }
}
```

### 3. LocalComercial

**Propósito**: Wrapper para respuesta de API.

```dart
class LocalComercial {
  final String localId;
  final String localNombre;
  final String comunaNombre;
  // ... otros campos
  
  /// Convierte a modelo Farmacia
  Farmacia toFarmacia() => Farmacia(
    localId: localId,
    localNombre: localNombre,
    // ...
  );
}
```

---

## Gestión de Estado

### Provider Pattern

**Configuración Global**:

```dart
void main() async {
  final themeService = ThemeService();
  await themeService.init();
  
  runApp(
    ChangeNotifierProvider.value(
      value: themeService,
      child: const FarmaciaApp(),
    ),
  );
}
```

**Consumo en Widgets**:

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Escuchar cambios
    final themeService = Provider.of<ThemeService>(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: themeService.isDarkMode
              ? darkGradient
              : lightGradient,
        ),
      ),
    );
  }
}
```

### Estado Local con StatefulWidget

**Patrón Utilizado**:

```dart
class _HomeScreenState extends State<HomeScreen> {
  // Estado UI
  bool _isLoading = false;
  String? _errorMessage;
  double _selectedRadius = 10.0;
  
  // Controladores
  final TextEditingController _localidadController;
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  
  @override
  void dispose() {
    _localidadController.dispose();
    super.dispose();
  }
}
```

---

## Integración con APIs Externas

### API MINSAL

**Base URL**: `https://midas.minsal.cl/farmacia_v2/WS/`

**Endpoints**:

#### 1. Obtener Farmacias de Turno
```http
GET /getLocalesTurnos.php
```

**Respuesta**:
```json
[
  {
    "local_id": "12345",
    "local_nombre": "Farmacia Cruz Verde",
    "local_direccion": "Av. Libertador 1234",
    "comuna_nombre": "Santiago",
    "local_telefono": "+56912345678",
    "local_lat": "-33.4569",
    "local_lng": "-70.6483",
    "funcionamiento_hora_apertura": "00:00:00",
    "funcionamiento_hora_cierre": "23:59:59",
    "fecha": "2025-11-05"
  }
]
```

#### 2. Buscar por Localidad
```http
GET /getLocalesRegion.php?id_region=13&id_comuna=131
```

### Manejo de Errores API

**Códigos HTTP**:

| Código | Significado | Acción |
|--------|------------|--------|
| 200 | OK | Procesar respuesta |
| 400 | Bad Request | Mostrar error de parámetros |
| 404 | Not Found | Sin farmacias disponibles |
| 500 | Server Error | Reintentar con exponential backoff |
| 503 | Service Unavailable | Mostrar mensaje de mantenimiento |

**Reintentos**:
```dart
static Future<T> _retryRequest<T>(
  Future<T> Function() request,
  {int maxRetries = 3}
) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      return await request();
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      await Future.delayed(Duration(seconds: math.pow(2, i).toInt()));
    }
  }
  throw Exception('Max retries exceeded');
}
```

---

## Almacenamiento y Caché

### SharedPreferences

**Keys Utilizadas**:
```dart
static const String _farmaciasKey = 'cached_farmacias';
static const String _farmaciasTimestampKey = 'farmacias_timestamp';
static const String _themeKey = 'theme_mode';
```

**Estrategia de Caché**:

1. **Escritura**:
```dart
Future<void> saveFarmacias(List<Farmacia> farmacias) async {
  final json = jsonEncode(farmacias.map((f) => f.toJson()).toList());
  await _prefs.setString(_farmaciasKey, json);
  await _prefs.setString(_farmaciasTimestampKey, DateTime.now().toIso8601String());
}
```

2. **Lectura con Validación**:
```dart
Future<List<Farmacia>?> getFarmacias() async {
  if (!await isCacheValid()) return null;
  
  final jsonString = _prefs.getString(_farmaciasKey);
  if (jsonString == null) return null;
  
  final List<dynamic> jsonList = jsonDecode(jsonString);
  return jsonList.map((json) => Farmacia.fromJson(json)).toList();
}
```

3. **Invalidación**:
- Automática: Después de 24 horas
- Manual: Al hacer pull-to-refresh
- Por error: Si la API responde con datos más recientes

### Tamaño de Datos

**Estimación**:
- Promedio farmacias: ~500 registros
- Tamaño por farmacia: ~350 bytes JSON
- Total: ~175 KB
- Con overhead: ~200 KB

**Límites de SharedPreferences**:
- Android: Sin límite definido (controlado por almacenamiento)
- iOS: Ilimitado en práctica

---

## Monitoreo y Analytics

### Firebase Crashlytics

**Configuración**:
```dart
void main() async {
  await Firebase.initializeApp();
  
  // Captura de errores Flutter
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  // Errores de plataforma
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}
```

**Custom Keys**:
```dart
await FirebaseCrashlytics.instance.setCustomKey('user_location', 'Santiago');
await FirebaseCrashlytics.instance.setCustomKey('search_radius', '10km');
```

### Firebase Analytics

**Eventos Personalizados**:
```dart
await AnalyticsService.logBusquedaFarmacias(
  metodo: 'gps',
  resultados: 15,
  radioKm: 10.0,
);

await AnalyticsService.logVerDetalleFarmacia(
  farmaciaId: '12345',
  farmaciaNombre: 'Cruz Verde',
  esDeTurno: true,
  distanciaKm: 2.5,
);
```

**Screen Tracking Automático**:
```dart
MaterialApp(
  navigatorObservers: [
    FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
  ],
)
```

---

## Rendimiento y Optimización

### Optimizaciones Implementadas

#### 1. Lazy Loading de Widgets
```dart
ListView.builder(
  itemCount: farmacias.length,
  itemBuilder: (context, index) {
    return FarmaciaCard(farmacia: farmacias[index]);
  },
)
```

#### 2. Caché de Imágenes
```dart
Image.network(
  url,
  cacheWidth: 100,
  cacheHeight: 100,
)
```

#### 3. Debouncing de Búsqueda
```dart
Timer? _debounce;

void _onSearchChanged(String query) {
  _debounce?.cancel();
  _debounce = Timer(const Duration(milliseconds: 500), () {
    _performSearch(query);
  });
}
```

#### 4. Compresión de JSON
- Serialización eficiente con `json_serializable`
- Eliminación de campos innecesarios
- Compresión gzip en HTTP

### Métricas de Rendimiento

**Tiempo de Carga**:
- Cold start: ~2.5s
- Warm start: ~0.8s
- Hot reload: ~200ms

**Consumo de Memoria**:
- Idle: ~50 MB
- Con 500 farmacias: ~65 MB
- Con mapa activo: ~85 MB

**Tamaño de App**:
- APK Debug: ~45 MB
- APK Release: ~18 MB
- App Bundle: ~14 MB

---

## Seguridad

### Protección de Datos

#### 1. API Keys
```dart
// NO hacer esto:
const apiKey = 'AIzaSyDf3aRzJeatsPVOyJhXbqqh8dZDKXa6WW0';

// Mejor: Usar flutter_dotenv o compilar en build
const String apiKey = String.fromEnvironment('GOOGLE_API_KEY');
```

#### 2. Certificados SSL
```dart
HttpClient()
  ..badCertificateCallback = (cert, host, port) {
    // Solo permitir hosts específicos
    return host == 'midas.minsal.cl';
  };
```

#### 3. Datos Sensibles
- NO almacenar contraseñas en SharedPreferences
- Usar flutter_secure_storage para tokens
- Limpiar caché en logout

### Permisos Mínimos

**Android**:
```xml
<!-- Solo lo necesario -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**iOS**:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para encontrar farmacias cercanas</string>
```

### Validación de Datos

```dart
class Farmacia {
  Farmacia({
    required this.localId,
    required this.localNombre,
    // ...
  }) {
    // Validaciones
    if (localId.isEmpty) throw ArgumentError('ID vacío');
    if (localLat < -90 || localLat > 90) throw ArgumentError('Latitud inválida');
  }
}
```

---

## Anexos

### A. Convenciones de Código (Effective Dart)

**Nombres**:
- Clases: `UpperCamelCase`
- Variables: `lowerCamelCase`
- Constantes: `lowerCamelCase` (preferido sobre SCREAMING_CAPS)
- Archivos: `snake_case`

**Documentación**:
```dart
/// Busca farmacias cercanas usando geolocalización.
///
/// Retorna una lista de [FarmaciaConDistancia] ordenada por
/// distancia ascendente. Si [radius] es null, usa el valor
/// por defecto de [AppConstants.defaultRadius].
///
/// Throws [LocationServiceException] si no hay permisos.
Future<List<FarmaciaConDistancia>> getFarmaciasCercanas({
  required Position userPosition,
  double? radius,
}) async {
  // ...
}
```

### B. Comandos Útiles

```bash
# Análisis de código
flutter analyze

# Tests con coverage
flutter test --coverage

# Generar reporte HTML de coverage
genhtml coverage/lcov.info -o coverage/html

# Build optimizado
flutter build appbundle --release --obfuscate --split-debug-info=debug-info

# Limpiar build
flutter clean && flutter pub get

# Actualizar dependencias
flutter pub upgrade --major-versions
```

### C. Troubleshooting Común

**Problema**: Error SSL en algunos dispositivos
**Solución**: Implementado `badCertificateCallback` en ApiService

**Problema**: Permisos de ubicación denegados
**Solución**: Implementado flujo completo con estados en LocationService

**Problema**: Caché desactualizado
**Solución**: Validación de timestamp de 24 horas

---

**Versión de Documentación**: 1.0.0  
**Última Actualización**: 5 de Noviembre de 2025  
**Autor**: Luis Riveros (DUAMIT)
