import 'package:fitsense/features/auth/data/services/exercise_summary_service.dart';
import 'package:fitsense/features/auth/data/services/water_intake_service.dart';
import 'package:fitsense/features/auth/data/services/weekly_progress_service.dart';
import 'package:fitsense/features/auth/domain/models/exercise_summary_model.dart';
import 'package:fitsense/features/auth/domain/models/water_intake_model.dart';

/// Servicio que agrega todos los datos necesarios para el Home Tab
class HomeDashboardService {
  final ExerciseSummaryService _exerciseService = ExerciseSummaryService();
  final WaterIntakeService _waterService = WaterIntakeService();
  final WeeklyProgressService _progressService = WeeklyProgressService();

  /// Obtiene todos los datos del dashboard en una sola llamada
  Future<HomeDashboardData> getDashboardData(int userId, int athleteId) async {
    print('🏠 [DASHBOARD] Cargando datos para userId: $userId, athleteId: $athleteId');

    // Ejecutar todas las llamadas en paralelo
    final results = await Future.wait([
      _getExerciseSummary(userId),
      _waterService.getTodayWaterIntake(athleteId),
      _progressService.getWeeklyProgress(userId),
    ]);

    final exerciseSummary = results[0] as ExerciseSummaryModel?;
    final waterIntake = results[1] as WaterIntakeModel?;
    final weeklyProgress = results[2] as WeeklyProgress?;

    print('🏠 [DASHBOARD] Datos cargados:');
    print('   - Ejercicios completados: ${exerciseSummary?.exercisesCompleted ?? 0}');
    print('   - Calorías quemadas: ${exerciseSummary?.totalCaloriesBurned ?? 0}');
    print('   - Hidratación: ${waterIntake?.glasses ?? 0}/${waterIntake?.goalGlasses ?? 8} vasos');
    print('   - Progreso semanal: ${weeklyProgress?.daysCompleted ?? 0}/7 días');

    return HomeDashboardData(
      exerciseSummary: exerciseSummary,
      waterIntake: waterIntake,
      weeklyProgress: weeklyProgress ?? WeeklyProgress.empty(),
    );
  }

  Future<ExerciseSummaryModel?> _getExerciseSummary(int userId) async {
    try {
      final routineId = await _exerciseService.getLatestRoutineId(userId);
      if (routineId == null) return null;

      return await _exerciseService.getExerciseSummary(userId, routineId);
    } catch (e) {
      print('🔴 [DASHBOARD] Error obteniendo resumen de ejercicios: $e');
      return null;
    }
  }
}

/// Modelo que agrupa todos los datos del dashboard
class HomeDashboardData {
  final ExerciseSummaryModel? exerciseSummary;
  final WaterIntakeModel? waterIntake;
  final WeeklyProgress weeklyProgress;

  HomeDashboardData({
    this.exerciseSummary,
    this.waterIntake,
    required this.weeklyProgress,
  });

  // Métricas calculadas
  int get totalCaloriesBurned => exerciseSummary?.totalCaloriesBurned ?? 0;
  int get exercisesCompleted => exerciseSummary?.exercisesCompleted ?? 0;
  int get waterGlasses => waterIntake?.glasses ?? 0;
  int get waterGoal => waterIntake?.goalGlasses ?? 8;
  int get daysCompletedThisWeek => weeklyProgress.daysCompleted;

  double get waterProgressPercentage {
    if (waterGoal == 0) return 0;
    return (waterGlasses / waterGoal * 100).clamp(0, 100);
  }

  bool get hasData {
    return exerciseSummary != null || waterIntake != null;
  }
}

