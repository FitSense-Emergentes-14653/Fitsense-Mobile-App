import '../config/app_config.dart';

class BaseService {
  /// URL base de la API - usa detección automática de plataforma
  /// - Android Emulator: http://10.0.2.2:8080/api/v1
  /// - Web (Chrome): http://localhost:8080/api/v1
  /// - iOS/otras: http://localhost:8080/api/v1
  String get baseUrl => AppConfig.apiBaseUrl;

  Map<String, String> getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
