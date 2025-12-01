import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Clase de configuración centralizada para URLs del backend
/// URLs de desarrollo local
class AppConfig {
  /// URL base de la API principal (Authentication y Athlete)
  /// Para Android emulator: http://10.0.2.2:8080/api/v1
  /// Para Web/iOS: http://localhost:8080/api/v1
  static String get apiBaseUrl {
    String url;
    if (kIsWeb) {
      url = 'http://localhost:8080/api/v1';
      print('🌐 [APP CONFIG] Plataforma: Web | API URL: $url');
    } else {
      try {
        if (Platform.isAndroid) {
          url = 'http://10.0.2.2:8080/api/v1';
          print('🤖 [APP CONFIG] Plataforma: Android | API URL: $url');
        } else {
          url = 'http://localhost:8080/api/v1';
          print('📱 [APP CONFIG] Plataforma: ${Platform.operatingSystem} | API URL: $url');
        }
      } catch (e) {
        url = 'http://localhost:8080/api/v1';
        print('⚠️ [APP CONFIG] Error detectando plataforma | API URL: $url');
      }
    }
    return url;
  }

  /// URL base del chatbot (Operaciones del chatbot)
  /// Para Android emulator: http://10.0.2.2:8085
  /// Para Web/iOS: http://localhost:8085
  static String get chatbotBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8085';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8085';
      }
      return 'http://localhost:8085';
    } catch (e) {
      return 'http://localhost:8085';
    }
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

