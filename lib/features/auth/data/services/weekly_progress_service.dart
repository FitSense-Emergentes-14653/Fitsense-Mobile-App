import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitsense/infrastructure/config/app_config.dart';
import 'package:fitsense/infrastructure/services/session_service.dart';

/// Servicio para obtener el progreso semanal del usuario
///
/// Este servicio consulta el resumen de ejercicios para determinar
/// qué días de la semana el usuario ha completado entrenamientos
class WeeklyProgressService {
  final SessionService _session = SessionService();

  Future<String?> _getToken() async {
    await _session.init();
    return _session.getToken();
  }

  /// Obtiene el progreso semanal del usuario
  ///
  /// Retorna un mapa con los días de la semana y si están completados
  Future<WeeklyProgress?> getWeeklyProgress(int userId) async {
    try {
      final token = await _getToken();
      print('📅 [WEEKLY PROGRESS] Token obtenido: ${token != null ? "✓" : "✗"}');
      if (token == null) throw Exception('No token available');

      // Primero obtener el routineId
      final routineId = await _getLatestRoutineId(userId);
      if (routineId == null) {
        print('📅 [WEEKLY PROGRESS] No hay rutina, progreso = 0');
        return WeeklyProgress.empty();
      }

      // Obtener el resumen de ejercicios
      final url = '${AppConfig.apiBaseUrl}/challenges/user/$userId/routine/$routineId/summary';
      print('📅 [WEEKLY PROGRESS] GET Request URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('📅 [WEEKLY PROGRESS] Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('📅 [WEEKLY PROGRESS] Datos: $jsonData');

        // Extraer el objeto 'data' de la respuesta
        final data = jsonData['data'] ?? jsonData;

        // Manejar exercisesCompleted que puede venir como int o double
        int exercisesCompleted = 0;
        if (data['exercisesCompleted'] != null) {
          if (data['exercisesCompleted'] is double) {
            exercisesCompleted = (data['exercisesCompleted'] as double).toInt();
          } else if (data['exercisesCompleted'] is int) {
            exercisesCompleted = data['exercisesCompleted'] as int;
          } else {
            exercisesCompleted = int.tryParse(data['exercisesCompleted'].toString()) ?? 0;
          }
        }

        final lastUpdated = data['lastUpdated'] != null
            ? DateTime.parse(data['lastUpdated'])
            : DateTime.now();

        // Calcular días completados basado en ejercicios completados
        // Asumiendo que cada día tiene aproximadamente 3 ejercicios
        final daysCompleted = (exercisesCompleted / 3).floor();

        print('📅 [WEEKLY PROGRESS] Ejercicios completados: $exercisesCompleted');
        print('📅 [WEEKLY PROGRESS] Días completados calculados: $daysCompleted');

        return WeeklyProgress(
          daysCompleted: daysCompleted.clamp(0, 7),
          totalDays: 7,
          lastWorkoutDate: lastUpdated,
        );
      }

      print('📅 [WEEKLY PROGRESS] No se pudo obtener el resumen');
      return WeeklyProgress.empty();
    } catch (e) {
      print('🔴 [WEEKLY PROGRESS] Error: $e');
      return WeeklyProgress.empty();
    }
  }

  Future<int?> _getLatestRoutineId(int userId) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final url = '${AppConfig.apiBaseUrl}/challenges/user/$userId/latest';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['id'] as int?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

/// Modelo para representar el progreso semanal
class WeeklyProgress {
  final int daysCompleted;
  final int totalDays;
  final DateTime? lastWorkoutDate;

  WeeklyProgress({
    required this.daysCompleted,
    required this.totalDays,
    this.lastWorkoutDate,
  });

  factory WeeklyProgress.empty() {
    return WeeklyProgress(
      daysCompleted: 0,
      totalDays: 7,
      lastWorkoutDate: null,
    );
  }

  /// Obtiene una lista de booleanos indicando qué días están completados
  /// Por ejemplo, si daysCompleted = 3, retorna [true, true, true, false, false, false, false]
  List<bool> get completedDaysList {
    return List.generate(totalDays, (index) => index < daysCompleted);
  }

  /// Porcentaje de días completados
  double get completionPercentage {
    return (daysCompleted / totalDays * 100);
  }

  /// Mensaje de motivación basado en el progreso
  String get motivationalMessage {
    if (daysCompleted == 0) {
      return '¡Comienza tu primera sesión de esta semana! 💪';
    } else if (daysCompleted < 3) {
      return '¡Buen comienzo! Sigue así 🔥';
    } else if (daysCompleted < 5) {
      return '¡Vas muy bien! Ya casi llegas 🚀';
    } else if (daysCompleted < 7) {
      return '¡Increíble progreso! Solo falta un poco 🌟';
    } else {
      return '¡Semana completada! Eres increíble 🏆';
    }
  }
}

