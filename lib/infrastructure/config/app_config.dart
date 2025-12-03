import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Clase de configuración centralizada para URLs del backend
/// URLs de producción en Railway
class AppConfig {
  /// URL base de la API principal (Authentication y Athlete)
  /// Producción: https://fitsense-backend-services-production.up.railway.app/api/v1
  static String get apiBaseUrl {
    const url = 'https://fitsense-backend-services-production.up.railway.app/api/v1';
    if (kIsWeb) {
      print('🌐 [APP CONFIG] Plataforma: Web | API URL: $url');
    } else {
      try {
        if (Platform.isAndroid) {
          print('🤖 [APP CONFIG] Plataforma: Android | API URL: $url');
        } else {
          print('📱 [APP CONFIG] Plataforma: ${Platform.operatingSystem} | API URL: $url');
        }
      } catch (e) {
        print('⚠️ [APP CONFIG] Error detectando plataforma | API URL: $url');
      }
    }
    return url;
  }

  /// URL base del chatbot (Operaciones del chatbot)
  /// Producción: https://chatbox-ai-production-6ead.up.railway.app
  static String get chatbotBaseUrl {
    const url = 'https://chatbox-ai-production-6ead.up.railway.app';
    print('🤖 [CHATBOT CONFIG] URL: $url');
    return url;
  }

  /// Información de la plataforma actual (para debugging)
  static String get platformInfo {
    if (kIsWeb) {
      return 'Web';
    } else {
      try {
        if (Platform.isAndroid) return 'Android';
        if (Platform.isIOS) return 'iOS';
        if (Platform.isMacOS) return 'macOS';
        if (Platform.isWindows) return 'Windows';
        if (Platform.isLinux) return 'Linux';
        return 'Unknown';
      } catch (e) {
        return 'Unknown';
      }
    }
  }
}

