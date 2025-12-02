import 'package:flutter/material.dart';
import 'package:fitsense/features/auth/data/services/water_intake_service.dart';
import 'package:fitsense/features/auth/data/services/meal_service.dart';
import 'package:fitsense/features/auth/data/services/exercise_summary_service.dart';
import 'package:fitsense/features/auth/domain/models/water_intake_model.dart';
import 'package:fitsense/features/auth/domain/models/meal_model.dart';
import 'package:fitsense/features/auth/domain/models/exercise_summary_model.dart';
import 'package:fitsense/infrastructure/services/session_service.dart';

class MetricsTab extends StatefulWidget {
  final int userId;

  const MetricsTab({super.key, required this.userId});

  @override
  State<MetricsTab> createState() => _MetricsTabState();
}

class _MetricsTabState extends State<MetricsTab> {
  final WaterIntakeService _waterService = WaterIntakeService();
  final MealService _mealService = MealService();
  final ExerciseSummaryService _exerciseService = ExerciseSummaryService();
  final SessionService _session = SessionService();

  WaterIntakeModel? _waterIntake;
  DailyCaloriesSummary? _caloriesSummary;
  ExerciseSummaryModel? _exerciseSummary;
  bool _loading = true;
  bool _waterLoading = false;
  int? _athleteId; // ID del atleta desde la sesión
  int? _routineId; // ID de la rutina actual

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    await _session.init();
    _athleteId = _session.getAthleteId();

    print('📊 [METRICS TAB] ========== INICIALIZACIÓN ==========');
    print('📊 [METRICS TAB] User ID (parámetro): ${widget.userId}');
    print('📊 [METRICS TAB] Athlete ID (sesión): $_athleteId');
    print('📊 [METRICS TAB] ==========================================');

    if (_athleteId != null && _athleteId! > 0) {
      _loadData();
    } else {
      print('❌ [METRICS TAB] No se pudo obtener athleteId de la sesión');
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se pudo cargar el perfil del atleta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadData() async {
    if (_athleteId == null || _athleteId! <= 0) {
      print('❌ [METRICS TAB] athleteId no válido: $_athleteId');
      return;
    }

    print('📊 [METRICS TAB] Iniciando carga de datos...');
    print('📊 [METRICS TAB] Athlete ID: $_athleteId');
    setState(() => _loading = true);

    print('📊 [METRICS TAB] Solicitando datos de hidratación...');
    final water = await _waterService.getTodayWaterIntake(_athleteId!);
    print('📊 [METRICS TAB] Datos de hidratación recibidos: ${water != null ? "✓" : "✗"}');
    if (water != null) {
      print('📊 [METRICS TAB] Vasos consumidos: ${water.glasses} / ${water.goalGlasses}');
    }

    print('📊 [METRICS TAB] Solicitando datos de calorías...');
    final calories = await _mealService.getDailySummary(_athleteId!);
    print('📊 [METRICS TAB] Datos de calorías recibidos: ${calories != null ? "✓" : "✗"}');

    // Obtener resumen de ejercicios (calorías quemadas)
    print('📊 [METRICS TAB] Solicitando resumen de ejercicios...');
    ExerciseSummaryModel? exerciseSummary;

    // Primero obtener el routineId si no lo tenemos
    if (_routineId == null) {
      print('📊 [METRICS TAB] Obteniendo último routineId...');
      _routineId = await _exerciseService.getLatestRoutineId(widget.userId);
      print('📊 [METRICS TAB] Routine ID obtenido: $_routineId');
    }

    // Luego obtener el resumen si tenemos routineId
    if (_routineId != null) {
      exerciseSummary = await _exerciseService.getExerciseSummary(widget.userId, _routineId!);
      print('📊 [METRICS TAB] Resumen de ejercicios recibido: ${exerciseSummary != null ? "✓" : "✗"}');
      if (exerciseSummary != null) {
        print('📊 [METRICS TAB] Calorías quemadas: ${exerciseSummary.totalCaloriesBurned}');
        print('📊 [METRICS TAB] Ejercicios completados: ${exerciseSummary.exercisesCompleted}');
      }
    } else {
      print('⚠️ [METRICS TAB] No se pudo obtener routineId, no hay resumen de ejercicios');
    }

    setState(() {
      _waterIntake = water;
      _caloriesSummary = calories;
      _exerciseSummary = exerciseSummary;
      _loading = false;
    });
    print('📊 [METRICS TAB] Carga de datos completada');
  }

  Future<void> _incrementWater() async {
    if (_athleteId == null || _athleteId! <= 0) {
      print('❌ [METRICS TAB] No se puede incrementar: athleteId no válido');
      return;
    }

    if (_waterLoading) {
      print('⏳ [METRICS TAB] Ya hay una operación en progreso, ignorando...');
      return;
    }

    setState(() => _waterLoading = true);

    print('➕ [METRICS TAB] ========== INCREMENTAR AGUA ==========');
    print('➕ [METRICS TAB] Athlete ID: $_athleteId');
    print('➕ [METRICS TAB] Estado actual: ${_waterIntake?.glasses} / ${_waterIntake?.goalGlasses}');

    final updated = await _waterService.incrementWaterIntake(_athleteId!);

    setState(() => _waterLoading = false);

    print('➕ [METRICS TAB] Respuesta del servicio: ${updated != null ? "✓ Exitoso" : "✗ Error"}');

    if (updated != null) {
      print('➕ [METRICS TAB] Nuevo estado: ${updated.glasses} / ${updated.goalGlasses}');
      setState(() => _waterIntake = updated);
      print('➕ [METRICS TAB] UI actualizada');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Agua agregada: ${updated.glasses} / ${updated.goalGlasses} vasos'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      print('❌ [METRICS TAB] Error al incrementar agua');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al agregar agua. Intenta de nuevo.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
    print('➕ [METRICS TAB] ========================================');
  }

  Future<void> _decrementWater() async {
    if (_athleteId == null || _athleteId! <= 0) {
      print('❌ [METRICS TAB] No se puede decrementar: athleteId no válido');
      return;
    }

    if (_waterLoading) {
      print('⏳ [METRICS TAB] Ya hay una operación en progreso, ignorando...');
      return;
    }

    setState(() => _waterLoading = true);

    print('➖ [METRICS TAB] ========== DECREMENTAR AGUA ==========');
    print('➖ [METRICS TAB] Athlete ID: $_athleteId');
    print('➖ [METRICS TAB] Estado actual: ${_waterIntake?.glasses} / ${_waterIntake?.goalGlasses}');

    final updated = await _waterService.decrementWaterIntake(_athleteId!);

    setState(() => _waterLoading = false);

    print('➖ [METRICS TAB] Respuesta del servicio: ${updated != null ? "✓ Exitoso" : "✗ Error"}');

    if (updated != null) {
      print('➖ [METRICS TAB] Nuevo estado: ${updated.glasses} / ${updated.goalGlasses}');
      setState(() => _waterIntake = updated);
      print('➖ [METRICS TAB] UI actualizada');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Agua reducida: ${updated.glasses} / ${updated.goalGlasses} vasos'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      print('❌ [METRICS TAB] Error al decrementar agua');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al reducir agua. Intenta de nuevo.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
    print('➖ [METRICS TAB] ========================================');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8A5CF6)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF8A5CF6),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Mis Métricas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seguimiento diario',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),

            _buildWaterIntakeCard(),

            const SizedBox(height: 24),

            _buildCaloriesCard(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterIntakeCard() {
    final glasses = _waterIntake?.glasses ?? 0;
    final goal = _waterIntake?.goalGlasses ?? 8;
    final progress = goal > 0 ? (glasses / goal).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4FC3F7).withValues(alpha: 0.2),
            const Color(0xFF29B6F6).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4FC3F7).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: Color(0xFF4FC3F7),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Hidratación',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: _showEditGoalDialog,
                icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 20,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$glasses / $goal vasos',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).toInt()}% completado',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: glasses > 0 ? _decrementWater : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.white,
                    iconSize: 40,
                    disabledColor: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _incrementWater,
                    icon: const Icon(Icons.add_circle),
                    color: const Color(0xFF4FC3F7),
                    iconSize: 40,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateGoal(int newGoal) async {
    if (_athleteId == null || _athleteId! <= 0) {
      print('❌ [METRICS TAB] No se puede actualizar meta: athleteId no válido');
      return;
    }

    final updated = await _waterService.updateGoal(_athleteId!, newGoal);
    if (updated != null) {
      setState(() => _waterIntake = updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meta de hidratación actualizada.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar la meta.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditGoalDialog() {
    final goalController = TextEditingController(text: _waterIntake?.goalGlasses.toString() ?? '8');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Editar Meta de Hidratación', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: goalController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Vasos diarios',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white38),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF8A5CF6)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                final newGoal = int.tryParse(goalController.text);
                if (newGoal != null && newGoal > 0) {
                  _updateGoal(newGoal);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar', style: TextStyle(color: Color(0xFF8A5CF6))),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCaloriesCard() {
    // Si tenemos resumen de ejercicios, mostrarlo
    final exerciseSummary = _exerciseSummary;

    // Meta de calorías quemadas por día (puedes ajustar esto)
    const goalCalories = 500; // Meta diaria de calorías a quemar
    final burnedCalories = exerciseSummary?.totalCaloriesBurned ?? 0;
    final exercisesCompleted = exerciseSummary?.exercisesCompleted ?? 0;

    final progress = goalCalories > 0 ? (burnedCalories / goalCalories).clamp(0.0, 1.0) : 0.0;
    final progressColor = progress >= 1.0
        ? Colors.green
        : progress >= 0.7
            ? Colors.orange
            : const Color(0xFF8A5CF6);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8A5CF6).withValues(alpha: 0.2),
            const Color(0xFF7C3AED).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8A5CF6).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Color(0xFF8A5CF6),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Calorías',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Agregar comidas próximamente'),
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle),
                color: const Color(0xFF8A5CF6),
                iconSize: 32,
              ),
            ],
          ),
          const SizedBox(height: 32),

          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 20,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$burnedCalories',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'de $goalCalories kcal',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'quemadas',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Información de ejercicios
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildExerciseStatItem(
                'Ejercicios',
                '$exercisesCompleted',
                Icons.fitness_center,
                const Color(0xFF8A5CF6),
              ),
              _buildExerciseStatItem(
                'Progreso',
                '${(progress * 100).toInt()}%',
                Icons.trending_up,
                progressColor,
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Divider(color: Colors.white24),

          const SizedBox(height: 16),

          // Última actualización
          if (exerciseSummary != null) ...[
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Última actualización: ${_formatLastUpdated(exerciseSummary.lastUpdated)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay datos de ejercicios',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Completa ejercicios para ver tu progreso',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExerciseStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Ahora mismo';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return 'Hace ${difference.inDays}d';
    }
  }

  Widget _buildMealItem(MealModel meal) {
    final Map<String, String> mealTypeLabels = {
      'breakfast': 'Desayuno',
      'lunch': 'Almuerzo',
      'dinner': 'Cena',
      'snack': 'Snack',
    };

    final Map<String, IconData> mealTypeIcons = {
      'breakfast': Icons.breakfast_dining,
      'lunch': Icons.lunch_dining,
      'dinner': Icons.dinner_dining,
      'snack': Icons.cookie,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF8A5CF6).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              mealTypeIcons[meal.mealType] ?? Icons.fastfood,
              color: const Color(0xFF8A5CF6),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mealTypeLabels[meal.mealType] ?? meal.mealType,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${meal.calories} kcal',
                style: const TextStyle(
                  color: Color(0xFF8A5CF6),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'P:${meal.protein.toInt()}g C:${meal.carbs.toInt()}g F:${meal.fats.toInt()}g',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

