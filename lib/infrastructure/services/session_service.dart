import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // 👇 Lazy init helper para evitar nulls
  Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ===================== TOKEN =====================
  Future<void> setToken(String token) async {
    final prefs = await _ensurePrefs();
    print('DEBUG SessionService: Setting token, length: ${token.length}');
    print('DEBUG SessionService: Token preview: ${token.substring(0, 20)}...');
    await prefs.setString('token', token);
  }

  String getToken() {
    final token = _prefs?.getString('token') ?? '';
    print('DEBUG SessionService: Getting token, length: ${token.length}');
    if (token.isNotEmpty) {
      print('DEBUG SessionService: Token preview: ${token.substring(0, 20)}...');
    } else {
      print('DEBUG SessionService: No token found');
    }
    return token;
  }

  // ===================== USER =====================
  Future<void> setUserId(int id) async {
    final prefs = await _ensurePrefs();
    await prefs.setInt('userId', id);
  }

  int getUserId() => _prefs?.getInt('userId') ?? -1;

  // ===================== ROLE =====================
  Future<void> setRole(String role) async {
    final prefs = await _ensurePrefs();
    await prefs.setString('role', role);
  }

  String getRole() => _prefs?.getString('role') ?? '';

  // ===================== CARETAKER =====================


  // ===================== CLEAR =====================
  Future<void> clear() async {
    final prefs = await _ensurePrefs();
    print('DEBUG SessionService: Clearing all session data');
    await prefs.clear();
  }
}
