import '../config/app_config.dart';

class BaseService {
  /// URL base de la API principal (Authentication y Athlete)
  /// Producción: https://fitsense-backend-services-production.up.railway.app/api/v1
  String get baseUrl => AppConfig.apiBaseUrl;

  Map<String, String> getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
