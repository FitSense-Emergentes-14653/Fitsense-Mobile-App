import 'package:fitsense/infrastructure/services/session_service.dart';
import '../../data/models/athlete_model.dart';
import '../../data/datasources/athlete_remote_data_source.dart';

class AthleteRepository {
  final AthleteRemoteDataSource remoteDataSource;
  final SessionService _session = SessionService();

  AthleteRepository(this.remoteDataSource);

  // ================= GET =================

  Future<AthleteModel> getById(int athleteId) async {
    final token = _session.getToken();
    return remoteDataSource.getAthleteById(
      token: token,
      athleteId: athleteId,
    );
  }

  Future<List<AthleteModel>> getAll() async {
    final token = _session.getToken();
    return remoteDataSource.getAllAthletes(token: token);
  }

  // ================= POST =================

  Future<AthleteModel> createAthlete({
    required int userId,
    required String fullname,
    required String phone,
    required String gender,
    required int age,
    required double weight,
    required double height,
    required String goal,
    required String activityLevel,
    required List<String> equipment,
  }) async {
    final token = _session.getToken();
    final body = {
      'userId': userId,
      'fullname': fullname,
      'phone': phone,
      'gender': gender,
      'age': age,
      'weight': weight,
      'height': height,
      'goal': goal,
      'activityLevel': activityLevel,
      'equipment': equipment,
    };

    return remoteDataSource.createAthlete(token: token, body: body);
  }

  // ================= PUT =================

  Future<AthleteModel> updateAthlete(
      int athleteId, AthleteModel updated) async {
    final token = _session.getToken();
    final body = updated.toJson();
    body.remove('id'); // el ID no se actualiza en el cuerpo
    return remoteDataSource.updateAthlete(
      token: token,
      athleteId: athleteId,
      body: body,
    );
  }

  // ================= DELETE =================

  Future<void> deleteAthlete(int athleteId) async {
    final token = _session.getToken();
    await remoteDataSource.deleteAthlete(
      token: token,
      athleteId: athleteId,
    );
  }
}
