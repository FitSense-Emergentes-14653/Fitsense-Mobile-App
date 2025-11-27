import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Clase de configuración centralizada para URLs del backend
/// URLs de producción en Railway
class AppConfig {
  /// URL base de la API principal (Authentication y Athlete)
  /// Desplegado en: https://fitsense-backend-services-production.up.railway.app
  static const String apiBaseUrl = 'https://fitsense-backend-services-production.up.railway.app/api/v1';

  /// URL base del chatbot (Operaciones del chatbot)
  /// Desplegado en: https://chatbox-ai-production-6ead.up.railway.app
  static const String chatbotBaseUrl = 'https://chatbox-ai-production-6ead.up.railway.app';

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

