import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitsense/infrastructure/config/app_config.dart';
import 'package:fitsense/infrastructure/services/session_service.dart';
import '../../domain/models/exercise_summary_model.dart';

/// Servicio para obtener el resumen de ejercicios y calorías quemadas
///
/// Endpoint: GET /challenges/user/{userId}/routine/{routineId}/summary
class ExerciseSummaryService {
  final SessionService _session = SessionService();

  Future<String?> _getToken() async {
    await _session.init();
    return _session.getToken();
  }

  /// Obtiene el resumen del progreso de ejercicios del usuario
  ///
  /// Retorna las calorías quemadas, ejercicios completados, etc.
  Future<ExerciseSummaryModel?> getExerciseSummary(int userId, int routineId) async {
    try {
      final token = await _getToken();
      print('🔥 [EXERCISE SUMMARY] Token obtenido: ${token != null ? "✓" : "✗"}');
      if (token == null) throw Exception('No token available');

      // Endpoint: GET /challenges/user/{userId}/routine/{routineId}/summary
      final url = '${AppConfig.apiBaseUrl}/challenges/user/$userId/routine/$routineId/summary';

      print('🔥 [EXERCISE SUMMARY] User ID: $userId');
      print('🔥 [EXERCISE SUMMARY] Routine ID: $routineId');
      print('🔥 [EXERCISE SUMMARY] GET Request URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('🔥 [EXERCISE SUMMARY] Response Status: ${response.statusCode}');
      print('🔥 [EXERCISE SUMMARY] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('🔥 [EXERCISE SUMMARY] Datos parseados: $jsonData');

        final summary = ExerciseSummaryModel.fromJson(jsonData);
        print('🔥 [EXERCISE SUMMARY] Calorías quemadas: ${summary.totalCaloriesBurned}');
        print('🔥 [EXERCISE SUMMARY] Ejercicios completados: ${summary.exercisesCompleted}');

        return summary;
      }

      print('🔴 [EXERCISE SUMMARY] Error, status code: ${response.statusCode}');
      return null;
    } catch (e) {
      print('🔴 [EXERCISE SUMMARY] Error obteniendo resumen: $e');
      return null;
    }
  }

  /// Obtiene el último routineId del usuario
  ///
  /// Esto es necesario para obtener el resumen si no tenemos el routineId
  Future<int?> getLatestRoutineId(int userId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token available');

      final url = '${AppConfig.apiBaseUrl}/challenges/user/$userId/latest';

      print('🔥 [EXERCISE SUMMARY] Obteniendo último routineId para userId: $userId');
      print('🔥 [EXERCISE SUMMARY] GET Request URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('🔥 [EXERCISE SUMMARY] Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final routineId = jsonData['id'] as int?;
        print('🔥 [EXERCISE SUMMARY] Último routineId: $routineId');
        return routineId;
      }

      print('🔴 [EXERCISE SUMMARY] Error obteniendo routineId, status: ${response.statusCode}');
      return null;
    } catch (e) {
      print('🔴 [EXERCISE SUMMARY] Error obteniendo routineId: $e');
      return null;
    }
  }
}

