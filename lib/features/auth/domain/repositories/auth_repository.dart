import 'package:fitsense/features/auth/data/datasources/auth_remote_data_source.dart';
import '../../../../infrastructure/services/session_service.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SessionService _session = SessionService();

  AuthRepository(this.remoteDataSource);

  // ---------------------------
  // AUTH
  // ---------------------------
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }

  Future<Map<String, dynamic>?> signInUser({
    required String email,
    required String password,
  }) async {
    return await remoteDataSource.signInUser(
      email: email,
      password: password,
    );
  }

  Future<bool> registerUser({
    required String email,
    required String password,
    required String role,
  }) async {
    return await remoteDataSource.registerUser(
      email: email,
      password: password,
      role: role,
    );
  }

  // ---------- reset password ----------
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) =>
      remoteDataSource.resetPassword(email: email, newPassword: newPassword);

  // ---------------------------
  // USER & PROFILE
  // ---------------------------
  Future<Map<String, dynamic>> getUserData(int userId) async {
    final token = _session.getToken();
    return await remoteDataSource.getUserData(token, userId);
  }

  Future<Map<String, dynamic>> getProfileByRole(String role) async {
    final token = _session.getToken();
    return await remoteDataSource.getProfileByRole(token, role);
  }

  // ---------------------------
  // BY ROLE (ID)
  // ---------------------------
  Future<Map<String, dynamic>> getAthleteById(int caretakerId) async {
    final token = _session.getToken();
    return await remoteDataSource.getAthletesById(token, caretakerId);
  }

  // ---------------------------
  // OPTIONAL: Unified helper
  // ---------------------------
  Future<Map<String, dynamic>> getProfileByRoleAndId(
      String role, int id) async {
    final token = _session.getToken();
    switch (role.toUpperCase()) {
      case 'ATHLETE':
        return await remoteDataSource.getAthletesById(token, id);
      default:
        throw Exception('Rol desconocido: $role');
    }
  }
}
