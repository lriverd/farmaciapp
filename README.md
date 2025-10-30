# Farmacias de Turno Chile 🏥

Una aplicación móvil desarrollada en Flutter para encontrar farmacias de turno (abiertas 24 horas) y farmacias cercanas en Chile.

## 📱 Características

- 🔍 Búsqueda de farmacias por ubicación GPS
- 🕒 Identificación de farmacias de turno (24 horas)
- 📍 Cálculo de distancia desde tu ubicación
- 🗺️ Integración con Google Maps para direcciones
- 📱 Llamadas directas desde la app
- 🔄 Actualización automática de datos
- 🎯 Filtros por comuna, región y nombre
- 📊 Estadísticas de farmacias disponibles

## 🚀 Instalación

### Prerrequisitos

- Flutter SDK (3.9.2+)
- Dart SDK
- Android Studio / Xcode para desarrollo móvil

### Configuración

1. **Clonar el repositorio**
   ```bash
   git clone [url-del-repositorio]
   cd farmaciaap
   ```

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
