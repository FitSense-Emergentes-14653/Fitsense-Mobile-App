class BaseService {
  String get baseUrl =>
      'http://10.0.2.2:8080/api/v1';

  Map<String, String> getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}

// Localhost en: http://10.0.2.2:8080/api/v1