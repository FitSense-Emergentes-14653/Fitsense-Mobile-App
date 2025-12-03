import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitsense/infrastructure/config/app_config.dart';
import 'package:fitsense/infrastructure/services/session_service.dart';

/// Servicio para obtener las rutinas de un usuario
///
/// Endpoints:
/// - GET /challenges/user/{userId} - Obtener todas las rutinas del usuario
/// - GET /challenges/user/{userId}/latest - Obtener la última rutina
class RoutineService {
  final SessionService _session = SessionService();

  Future<String?> _getToken() async {
    await _session.init();
    return _session.getToken();
  }

  /// Obtiene el entrenamiento del primer día de la semana actual
  ///
  /// Retorna null si no hay rutina o si ocurre un error
  Future<TodayWorkout?> getTodayWorkout(int userId) async {
    try {
      final token = await _getToken();
      print('🏋️ [ROUTINE SERVICE] Token obtenido: ${token != null ? "✓" : "✗"}');
      if (token == null) throw Exception('No token available');

      // Obtener todas las rutinas
      final url = '${AppConfig.apiBaseUrl}/challenges/user/$userId';
      print('🏋️ [ROUTINE SERVICE] GET Request URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🏋️ [ROUTINE SERVICE] Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> challenges = json.decode(response.body);

        if (challenges.isEmpty) {
          print('🏋️ [ROUTINE SERVICE] No hay rutinas');
          return null;
        }

        // Tomar la primera rutina (la más reciente)
        final firstChallenge = challenges[0];
        final routineId = firstChallenge['id'] ?? 0;
        final rutina = firstChallenge['rutinaJson'];

        if (rutina == null) {
          print('🏋️ [ROUTINE SERVICE] No hay rutinaJson');
          return null;
        }

        final weeks = rutina['weeks'] as List<dynamic>? ?? [];

        if (weeks.isEmpty) {
          print('🏋️ [ROUTINE SERVICE] No hay semanas en la rutina');
          return null;
        }

        // Obtener la primera semana
        final firstWeek = weeks[0];
        final days = firstWeek['days'] as List<dynamic>? ?? [];

        if (days.isEmpty) {
          print('🏋️ [ROUTINE SERVICE] No hay días en la primera semana');
          return null;
        }

        // Obtener el primer día
        final firstDay = days[0];
        final exercises = firstDay['exercises'] as List<dynamic>? ?? [];

        final workout = TodayWorkout(
          dayName: firstDay['name'] ?? 'Día 1',
          exercisesCount: exercises.length,
          warmup: firstDay['warmup'] ?? '5 min calentamiento',
          cooldown: firstDay['cooldown'] ?? '5 min cooldown',
          exercises: exercises,
          weekNumber: firstWeek['week'] ?? 1,
          routineId: routineId,
        );

        print('🏋️ [ROUTINE SERVICE] Workout del día: ${workout.dayName} - ${workout.exercisesCount} ejercicios (routineId: $routineId)');
        return workout;
      } else if (response.statusCode == 404) {
        print('🏋️ [ROUTINE SERVICE] No se encontraron rutinas (404)');
        return null;
      }

      print('🔴 [ROUTINE SERVICE] Error, status code: ${response.statusCode}');
      return null;
    } catch (e) {
      print('🔴 [ROUTINE SERVICE] Error obteniendo workout: $e');
      return null;
    }
  }

  /// Verifica si el usuario tiene rutinas
  Future<bool> hasRoutines(int userId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final url = '${AppConfig.apiBaseUrl}/challenges/user/$userId/latest';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('🔴 [ROUTINE SERVICE] Error verificando rutinas: $e');
      return false;
    }
  }
}

/// Modelo para representar el entrenamiento del día
class TodayWorkout {
  final String dayName;
  final int exercisesCount;
  final String warmup;
  final String cooldown;
  final List<dynamic> exercises;
  final int weekNumber;
  final int routineId;

  TodayWorkout({
    required this.dayName,
    required this.exercisesCount,
    required this.warmup,
    required this.cooldown,
    required this.exercises,
    required this.weekNumber,
    required this.routineId,
  });

  int get estimatedDuration {
    // Estimación: 5 min warmup + 3 min por ejercicio + 5 min cooldown
    return 5 + (exercisesCount * 3) + 5;
  }
}

