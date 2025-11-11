# Detección Automática de Plataforma - URLs del Backend

## 📱 ¿Cómo funciona?

La aplicación detecta automáticamente en qué plataforma está corriendo y ajusta las URLs del backend según corresponda:

### Android Emulator
- **API Principal**: `http://10.0.2.2:8080/api/v1`
- **Chatbot**: `http://10.0.2.2:8085`
- **Razón**: El emulador de Android usa `10.0.2.2` para acceder al `localhost` de la máquina host

### Web (Chrome/Firefox/etc.)
- **API Principal**: `http://localhost:8080/api/v1`
- **Chatbot**: `http://localhost:8085`
- **Razón**: El navegador puede acceder directamente a `localhost`

### iOS Simulator / Otras plataformas
- **API Principal**: `http://localhost:8080/api/v1`
- **Chatbot**: `http://localhost:8085`
- **Razón**: El simulador de iOS puede acceder directamente a `localhost`

## 🔧 Configuración

### Archivo Principal: `lib/infrastructure/config/app_config.dart`

Este archivo contiene toda la lógica de detección de plataforma y configuración de URLs.

```dart
import 'package:fitsense/infrastructure/config/app_config.dart';

// Obtener URL de la API principal
String apiUrl = AppConfig.apiBaseUrl;

// Obtener URL del chatbot
String chatbotUrl = AppConfig.chatbotBaseUrl;

// Obtener información de la plataforma actual
String platform = AppConfig.platformInfo; // "Android", "Web", "iOS", etc.
```

## 🐛 Debugging

### Ver en qué plataforma está corriendo

1. **En el Chatbot**: El header muestra un ícono con la plataforma detectada:
   - 🤖 Android
   - 🌐 Web
   - 📱 iOS/Otros

2. **En la Consola**: Al iniciar el chatbot, verás logs como:
   ```
   🤖 [Chatbot] Plataforma detectada: Android
   🌐 [Chatbot] URL del chatbot: http://10.0.2.2:8085
   👤 [Chatbot] Usuario ID: 123
   📡 [Chatbot] Iniciando POST a: http://10.0.2.2:8085/session/start
   ✅ [Chatbot] Respuesta: 200
   ```

3. **Al enviar mensajes**:
   ```
   💬 [Chatbot] Enviando mensaje: "Quiero ver mi rutina"
   📡 [Chatbot] POST a: http://10.0.2.2:8085/chat/send
   ```

## 🚀 Compilar para diferentes plataformas

### Compilar para Android
```bash
flutter run -d <android-device-id>
# Automáticamente usará: http://10.0.2.2:8080 y http://10.0.2.2:8085
```

### Compilar para Web
```bash
flutter run -d chrome
# Automáticamente usará: http://localhost:8080 y http://localhost:8085
```

### Ver dispositivos disponibles
```bash
flutter devices
```

## 📝 Cambiar URLs para Producción

Cuando despliegues a producción, edita `lib/infrastructure/config/app_config.dart`:

```dart
class AppConfig {
  // DESARROLLO
  // static String get apiBaseUrl => 'http://$_host:$_mainPort/api/v1';
  // static String get chatbotBaseUrl => 'http://$_host:$_chatbotPort';
  
  // PRODUCCIÓN
  static String get apiBaseUrl => 'https://api.fitsense.com/v1';
  static String get chatbotBaseUrl => 'https://chatbot.fitsense.com';
}
```

## 🔍 Verificar Configuración Actual

Ejecuta este código en cualquier pantalla para ver la configuración:

```dart
import 'package:fitsense/infrastructure/config/app_config.dart';

void printConfig() {
  print('Plataforma: ${AppConfig.platformInfo}');
  print('API URL: ${AppConfig.apiBaseUrl}');
  print('Chatbot URL: ${AppConfig.chatbotBaseUrl}');
}
```

## ⚠️ Problemas Comunes

### Error: "Connection refused" en Android
- **Causa**: El servidor no está corriendo en el puerto especificado
- **Solución**: Asegúrate de que el servidor esté corriendo en `localhost:8080` y `localhost:8085`

### Error: "Connection refused" en Web
- **Causa**: Problemas de CORS o servidor no corriendo
- **Solución**: 
  1. Verifica que el servidor esté corriendo
  2. Configura CORS en el backend para aceptar peticiones desde `localhost`

### URLs incorrectas
- **Verifica la consola**: Revisa los logs de debugging para ver qué URL está usando
- **Verifica el header del chatbot**: Mira el ícono de plataforma para confirmar la detección

## 📦 Archivos Modificados

1. `lib/infrastructure/config/app_config.dart` - ✅ Nuevo archivo de configuración centralizada
2. `lib/infrastructure/services/base_service.dart` - ✅ Actualizado para usar `AppConfig`
3. `lib/features/auth/presentation/chatbot/athlete_chatbot_screen.dart` - ✅ Actualizado con detección de plataforma y logs

## 🎯 Beneficios

- ✅ **Detección automática**: No necesitas cambiar código al compilar para diferentes plataformas
- ✅ **Configuración centralizada**: Un solo lugar para cambiar todas las URLs
- ✅ **Debugging fácil**: Logs y UI que muestran exactamente qué está usando
- ✅ **Listo para producción**: Fácil cambio a URLs de producción
- ✅ **Sin errores de conexión**: Usa automáticamente la URL correcta según la plataforma

