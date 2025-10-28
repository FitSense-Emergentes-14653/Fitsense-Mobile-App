import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:fitsense/infrastructure/services/base_service.dart';

class AuthRemoteDataSource extends BaseService {
  AuthRemoteDataSource() {
    print('🚀 DEBUG AUTH: AuthRemoteDataSource initialized');
    print('🌐 DEBUG AUTH: Base URL configured: $baseUrl');
    print('🔧 DEBUG AUTH: Service ready for authentication requests');
  }

  // ---------------------------
  // Helpers
  // ---------------------------
  Map<String, String> _headers({String? token}) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) h['Authorization'] = 'Bearer $token';
    return h;
  }

  String _tokenPreview(String token) {
    if (token.isEmpty) return '(empty)';
    final n = min(50, token.length);
    return '${token.substring(0, n)}...';
  }

  T _decodeJson<T>(String body) {
    final data = jsonDecode(body);
    return data as T;
  }

  // ---------------------------
  // Auth
  // ---------------------------
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = '$baseUrl/authentication/sign-in';
    final requestBody = {"email": email, "password": password}; // <-- O {"email": email, ...}

    print('🔐 DEBUG AUTH: Starting login process...');
    print('🌐 DEBUG AUTH: Request URL: $url');
    print('📧 DEBUG AUTH: Email: $email');
    print('📦 DEBUG AUTH: Request body: ${jsonEncode(requestBody)}');

    try {
      final response = await http
          .post(Uri.parse(url), headers: _headers(), body: jsonEncode(requestBody))
          .timeout(const Duration(seconds: 20));

      print('📡 DEBUG AUTH: Response received | ${response.statusCode}');
      print('📄 DEBUG AUTH: Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _decodeJson<Map<String, dynamic>>(response.body);
        final tok = (data['token'] ?? '').toString();
        print('✅ DEBUG AUTH: Login OK | token: ${_tokenPreview(tok)}');
        return data;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('🚨 DEBUG AUTH: Exception during login: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      final data = await login(email, password);
      return data;
    } catch (e) {
      print('❌ DEBUG AUTH: signInUser failed: $e');
      return null;
    }
  }

  // ---------------------------
  // Users
  // ---------------------------
  Future<Map<String, dynamic>> getUserData(String token, int userId) async {
    final url = '$baseUrl/users/$userId';
    final headers = _headers(token: token);

    print('👤 DEBUG AUTH: getUserData -> $url | userId=$userId');
    print('🔑 DEBUG AUTH: Token: ${_tokenPreview(token)}');

    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 20));

      print('📡 DEBUG AUTH: getUserData status: ${response.statusCode}');
      print('📄 DEBUG AUTH: Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = _decodeJson<Map<String, dynamic>>(response.body);
        print('✅ DEBUG AUTH: User OK | email=${data['email']} | roles=${data['roles']}');
        return data;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('🚨 DEBUG AUTH: Exception getUserData: $e');
      rethrow;
    }
  }

  // ---------------------------
  // Profiles by role
  // ---------------------------
  Future<Map<String, dynamic>> getProfileByRole(String token, String role) async {
    late final String url;
    switch (role.toUpperCase()) {
      case 'CARETAKER':
        url = '$baseUrl/athletes';
        break;
      default:
        throw Exception('Rol desconocido: $role');
    }

    final headers = _headers(token: token);
    print('👥 DEBUG AUTH: getProfileByRole($role) -> $url');

    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 20));

      print('📡 DEBUG AUTH: getProfileByRole status: ${response.statusCode}');
      print('📄 DEBUG AUTH: Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          print('✅ DEBUG AUTH: Profiles OK | count=${decoded.length}');
          return {'list': decoded};
        } else if (decoded is Map && decoded['content'] is List) {
          // Soporta paginación tipo Spring Data
          final list = List.from(decoded['content']);
          print('✅ DEBUG AUTH: Profiles OK (paged) | count=${list.length}');
          return {'list': list, 'page': decoded};
        } else {
          throw Exception('Formato inesperado de respuesta para $role');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('🚨 DEBUG AUTH: Exception getProfileByRole: $e');
      rethrow;
    }
  }

  // ---------------------------
  // Registration
  // ---------------------------
  Future<bool> registerUser({
    required String email,
    required String password,
    required String role,
  }) async {
    final url = '$baseUrl/authentication/sign-up';
    final body = {
      'email': email,
      'password': password,
      'roles': [role],
    };

    print('📝 DEBUG AUTH: registerUser -> $url | $email | role=$role');

    try {
      final response = await http
          .post(Uri.parse(url), headers: _headers(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));

      print('📡 DEBUG AUTH: registerUser status: ${response.statusCode}');
      print('📄 DEBUG AUTH: Body: ${response.body}');

      final ok = response.statusCode == 200 || response.statusCode == 201;
      if (!ok) print('❌ DEBUG AUTH: register failed');
      return ok;
    } catch (e) {
      print('🚨 DEBUG AUTH: Exception registerUser: $e');
      return false;
    }
  }

  // ---------------------------
  // Athlete by ID
  // ---------------------------
  Future<Map<String, dynamic>> getAthletesById(
      String token, int athleteId) async {
    final url = '$baseUrl/athletes/$athleteId';
    final headers = _headers(token: token);

    print('🧑‍🏫 DEBUG AUTH: getAthleteById -> $url');
    print('🔑 DEBUG AUTH: Token: ${_tokenPreview(token)}');

    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 20));

      print('📡 DEBUG AUTH: getAthleteById status: ${response.statusCode}');
      print('📄 DEBUG AUTH: Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = _decodeJson<Map<String, dynamic>>(response.body);
        print('✅ DEBUG AUTH: Athlete OK | name=${data['fullname'] ?? 'N/A'}');
        return data;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('🚨 DEBUG AUTH: Exception getAthleteById: $e');
      rethrow;
    }
  }
}

