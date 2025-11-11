import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Clase de configuración centralizada para URLs del backend
/// Detecta automáticamente la plataforma y usa la URL correcta
class AppConfig {
  /// Puerto del servidor principal (API REST)
  static const int _mainPort = 8080;

  /// Puerto del servidor del chatbot
  static const int _chatbotPort = 8085;

  /// Host para desarrollo local
  static const String _localhostDev = 'localhost';

  /// Host para emulador Android (10.0.2.2 apunta al localhost del host)
  static const String _androidEmulatorHost = '10.0.2.2';

  /// Obtiene el host correcto según la plataforma
  static String get _host {
    if (kIsWeb) {
      // Web siempre usa localhost
      return _localhostDev;
    } else {
      try {
        if (Platform.isAndroid) {
          // Android Emulator necesita 10.0.2.2 para acceder al localhost del host
          return _androidEmulatorHost;
        } else {
          // iOS, macOS, Linux, Windows usan localhost
          return _localhostDev;
        }
      } catch (e) {
        return _localhostDev;
      }
    }
  }

  /// URL base de la API principal
  /// Ejemplos:
  /// - Android: http://10.0.2.2:8080/api/v1
  /// - Web: http://localhost:8080/api/v1
  static String get apiBaseUrl => 'http://$_host:$_mainPort/api/v1';

  /// URL base del chatbot
  /// Ejemplos:
  /// - Android: http://10.0.2.2:8085
  /// - Web: http://localhost:8085
  static String get chatbotBaseUrl => 'http://$_host:$_chatbotPort';

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

  /// Para producción, cambiar estas URLs a las del servidor real
  /// Ejemplo:
  /// static String get apiBaseUrl => 'https://api.fitsense.com/v1';
  /// static String get chatbotBaseUrl => 'https://chatbot.fitsense.com';
}

