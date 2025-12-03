import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:table_calendar/table_calendar.dart';
import 'package:fitsense/features/auth/data/services/exercise_summary_service.dart';
import 'package:fitsense/features/auth/data/services/water_intake_service.dart';
import 'package:fitsense/features/auth/data/services/weekly_progress_service.dart';
import 'package:fitsense/features/auth/domain/models/exercise_summary_model.dart';
import 'package:fitsense/features/auth/domain/models/water_intake_model.dart';
import 'package:fitsense/infrastructure/services/session_service.dart';

class ProgressTab extends StatefulWidget {
  final int userId;

  const ProgressTab({super.key, required this.userId});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  final ExerciseSummaryService _exerciseService = ExerciseSummaryService();
  final WaterIntakeService _waterService = WaterIntakeService();
  final WeeklyProgressService _progressService = WeeklyProgressService();
  final SessionService _session = SessionService();

  bool _loading = true;
  int? _athleteId;
  ExerciseSummaryModel? _exerciseSummary;
  WaterIntakeModel? _waterIntake;
  WeeklyProgress? _weeklyProgress;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    try {
      setState(() => _loading = true);

      await _session.init();
      _athleteId = _session.getAthleteId();

      // Detectar plataforma
      final platform = Theme.of(context).platform;
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 [PROGRESS TAB] INICIO DE CARGA DE DATOS');
      print('📊 [PROGRESS TAB] Plataforma: $platform');
      print('📊 [PROGRESS TAB] userId: ${widget.userId}');
      print('📊 [PROGRESS TAB] athleteId: $_athleteId');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (_athleteId == null || _athleteId == 0) {
        print('⚠️ [PROGRESS TAB] AthleteId no disponible');
        setState(() => _loading = false);
        return;
      }

      // Cargar todos los datos en paralelo
      print('📊 [PROGRESS TAB] Iniciando carga paralela de servicios...');
      final results = await Future.wait([
        _loadExerciseSummary(),
        _waterService.getTodayWaterIntake(_athleteId!),
        _progressService.getWeeklyProgress(widget.userId),
      ]);

      _exerciseSummary = results[0] as ExerciseSummaryModel?;
      _waterIntake = results[1] as WaterIntakeModel?;
      _weeklyProgress = results[2] as WeeklyProgress?;

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 [PROGRESS TAB] RESULTADO DE CARGA:');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 [PROGRESS TAB] Exercise Summary:');
      if (_exerciseSummary != null) {
        print('   ✅ Cargado correctamente');
        print('   - totalCaloriesBurned: ${_exerciseSummary!.totalCaloriesBurned}');
        print('   - exercisesCompleted: ${_exerciseSummary!.exercisesCompleted}');
        print('   - routineId: ${_exerciseSummary!.routineId}');
        print('   - lastUpdated: ${_exerciseSummary!.lastUpdated}');
      } else {
        print('   ❌ NULL - No se pudo cargar');
      }

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 [PROGRESS TAB] Water Intake:');
      if (_waterIntake != null) {
        print('   ✅ Cargado correctamente');
        print('   - glasses: ${_waterIntake!.glasses}');
        print('   - goalGlasses: ${_waterIntake!.goalGlasses}');
        print('   - athleteId: ${_waterIntake!.athleteId}');
        print('   - date: ${_waterIntake!.date}');
      } else {
        print('   ❌ NULL - No se pudo cargar');
      }

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 [PROGRESS TAB] Weekly Progress:');
      if (_weeklyProgress != null) {
        print('   ✅ Cargado correctamente');
        print('   - daysCompleted: ${_weeklyProgress!.daysCompleted}');
        print('   - totalDays: ${_weeklyProgress!.totalDays}');
        print('   - completionPercentage: ${_weeklyProgress!.completionPercentage}%');
        print('   - lastWorkoutDate: ${_weeklyProgress!.lastWorkoutDate}');
        print('   - motivationalMessage: ${_weeklyProgress!.motivationalMessage}');
      } else {
        print('   ❌ NULL - No se pudo cargar');
      }
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 [PROGRESS TAB] CARGA COMPLETADA - Actualizando UI');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      setState(() => _loading = false);
    } catch (e, stackTrace) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ [PROGRESS TAB] ERROR CRÍTICO:');
      print('   Error: $e');
      print('   Stack trace: $stackTrace');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      setState(() => _loading = false);
    }
  }

  Future<ExerciseSummaryModel?> _loadExerciseSummary() async {
    try {
      print('🔄 [PROGRESS TAB] Obteniendo último routineId para userId: ${widget.userId}');
      final routineId = await _exerciseService.getLatestRoutineId(widget.userId);

      if (routineId == null) {
        print('⚠️ [PROGRESS TAB] No se encontró routineId - El usuario no tiene rutinas');
        return null;
      }

      print('✅ [PROGRESS TAB] routineId obtenido: $routineId');
      print('🔄 [PROGRESS TAB] Obteniendo resumen de ejercicios...');

      final summary = await _exerciseService.getExerciseSummary(widget.userId, routineId);

      if (summary != null) {
        print('✅ [PROGRESS TAB] Resumen obtenido exitosamente');
      } else {
        print('⚠️ [PROGRESS TAB] Resumen es NULL');
      }

      return summary;
    } catch (e, stackTrace) {
      print('❌ [PROGRESS TAB] Error cargando resumen de ejercicios:');
      print('   Error: $e');
      print('   Stack: $stackTrace');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Usar la plataforma real (kIsWeb) Y el ancho de pantalla para UI responsive
    final isLargeScreen = screenWidth > 600;
    final maxWidth = isLargeScreen ? 800.0 : screenWidth;

    // Log para debugging
    if (!_loading) {
      print('🖥️ [PROGRESS TAB] BUILD:');
      print('   - Platform: ${kIsWeb ? "WEB" : "MOBILE"}');
      print('   - Screen width: $screenWidth');
      print('   - Using large screen layout: $isLargeScreen');
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: _loading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(
                    color: Color(0xFFCCF24D),
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadProgressData,
                color: const Color(0xFFCCF24D),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 24.0 : 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Mi Progreso',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.white),
                              onPressed: _loadProgressData,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Resumen de estadísticas
                        _buildStatsOverview(isLargeScreen),

                        const SizedBox(height: 16),

                        // Calendario
                        _buildCalendar(isLargeScreen),

                        const SizedBox(height: 16),

                        // Gráfico de progreso
                        _buildProgressChart(isLargeScreen),

                        const SizedBox(height: 16),

                        // Métricas adicionales
                        _buildAdditionalMetrics(isLargeScreen),

                        const SizedBox(height: 16),

                        // Historial reciente
                        _buildRecentHistory(isLargeScreen),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatsOverview(bool isLargeScreen) {
    final calories = _exerciseSummary?.totalCaloriesBurned ?? 0;
    final exercisesCompleted = _exerciseSummary?.exercisesCompleted ?? 0;
    final waterProgress = _waterIntake != null && _waterIntake!.goalGlasses > 0
        ? (_waterIntake!.glasses / _waterIntake!.goalGlasses * 100).toInt()
        : 0;

    if (isLargeScreen) {
      return Row(
        children: [
          Expanded(
            child: _StatsCard(
              icon: Icons.local_fire_department,
              value: calories.toString(),
              label: 'Calorías quemadas',
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatsCard(
              icon: Icons.fitness_center,
              value: exercisesCompleted.toString(),
              label: 'Ejercicios completados',
              color: const Color(0xFFCCF24D),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatsCard(
              icon: Icons.water_drop,
              value: '$waterProgress%',
              label: 'Hidratación del día',
              color: Colors.blue,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatsCard(
                icon: Icons.local_fire_department,
                value: calories.toString(),
                label: 'Calorías quemadas',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatsCard(
                icon: Icons.fitness_center,
                value: exercisesCompleted.toString(),
                label: 'Ejercicios completados',
                color: const Color(0xFFCCF24D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _StatsCard(
          icon: Icons.water_drop,
          value: '${(_waterIntake?.glasses ?? 0) * 250}ml / ${(_waterIntake?.goalGlasses ?? 8) * 250}ml',
          label: 'Hidratación del día',
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildCalendar(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2025, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: const Color(0xFFCCF24D),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Color(0xFFC8B8FF),
            shape: BoxShape.circle,
          ),
          defaultTextStyle: const TextStyle(color: Colors.white),
          weekendTextStyle: const TextStyle(color: Colors.white70),
          outsideTextStyle: const TextStyle(color: Colors.white24),
          markerDecoration: const BoxDecoration(
            color: Colors.yellow,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.white70),
          weekendStyle: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildProgressChart(bool isLargeScreen) {
    final daysCompleted = _weeklyProgress?.daysCompleted ?? 0;
    final totalDays = _weeklyProgress?.totalDays ?? 7;
    final completionPercentage = _weeklyProgress?.completionPercentage ?? 0;

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.show_chart, color: Colors.yellow, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Progreso Semanal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFCCF24D).withValues(alpha: 0.3),
                      const Color(0xFFC8B8FF).withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCCF24D)),
                ),
                child: Text(
                  '${completionPercentage.toInt()}%',
                  style: const TextStyle(
                    color: Color(0xFFCCF24D),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (daysCompleted > 0) ...[
            // Barra de progreso visual
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$daysCompleted de $totalDays días completados',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(
                      Icons.emoji_events,
                      color: Color(0xFFCCF24D),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: completionPercentage / 100,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFCCF24D)),
                    minHeight: 12,
                  ),
                ),
                const SizedBox(height: 16),
                // Días de la semana con checkmarks
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (index) {
                    final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                    final isCompleted = index < daysCompleted;

                    return Column(
                      children: [
                        Container(
                          width: isLargeScreen ? 36 : 32,
                          height: isLargeScreen ? 36 : 32,
                          decoration: BoxDecoration(
                            gradient: isCompleted
                                ? const LinearGradient(
                                    colors: [Color(0xFFCCF24D), Color(0xFFC8B8FF)],
                                  )
                                : null,
                            color: isCompleted ? null : Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted
                                  ? const Color(0xFFCCF24D)
                                  : Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check, color: Colors.black, size: 18)
                                : Text(
                                    days[index],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        if (!isCompleted) ...[
                          const SizedBox(height: 4),
                          Text(
                            days[index],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    );
                  }),
                ),
              ],
            ),
          ] else ...[
            // Estado vacío
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: isLargeScreen ? 60 : 50,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aún no has empezado',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Completa tu primer entrenamiento\npara comenzar a ver tu progreso',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          // Mensaje motivacional
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8A5CF6).withValues(alpha: 0.2),
                  const Color(0xFFCCF24D).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF8A5CF6).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFFCCF24D),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _weeklyProgress?.motivationalMessage ?? '¡Comienza tu viaje fitness hoy! 💪',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalMetrics(bool isLargeScreen) {
    if (_exerciseSummary == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.insights, color: Color(0xFFC8B8FF), size: 20),
              SizedBox(width: 8),
              Text(
                'Resumen de Actividad',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _MetricRow(
            label: 'Última actualización',
            value: _formatDate(_exerciseSummary!.lastUpdated),
            icon: Icons.schedule,
          ),
          const SizedBox(height: 12),
          _MetricRow(
            label: 'Rutina actual',
            value: 'ID: ${_exerciseSummary!.routineId}',
            icon: Icons.assignment,
          ),
          const SizedBox(height: 12),
          _MetricRow(
            label: 'Promedio de calorías/ejercicio',
            value: _exerciseSummary!.exercisesCompleted > 0
                ? '${(_exerciseSummary!.totalCaloriesBurned / _exerciseSummary!.exercisesCompleted).toStringAsFixed(1)} kcal'
                : '0 kcal',
            icon: Icons.trending_up,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildRecentHistory(bool isLargeScreen) {
    final hasData = _exerciseSummary != null && _exerciseSummary!.exercisesCompleted > 0;

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.history, color: Color(0xFFCCF24D), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Actividad Reciente',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (hasData)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCF24D).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCCF24D)),
                  ),
                  child: Text(
                    '${_exerciseSummary!.exercisesCompleted}',
                    style: const TextStyle(
                      color: Color(0xFFCCF24D),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (hasData) ...[
            // Mostrar resumen de la actividad
            _buildActivitySummary(isLargeScreen),
          ] else ...[
            // Estado vacío - No hay actividad
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center_outlined,
                      size: isLargeScreen ? 60 : 50,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aún no has empezado',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Completa tu primer entrenamiento\npara ver tu historial aquí',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
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

  Widget _buildActivitySummary(bool isLargeScreen) {
    return Column(
      children: [
        // Resumen de ejercicios completados
        Container(
          padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFCCF24D).withValues(alpha: 0.1),
                const Color(0xFFC8B8FF).withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFCCF24D).withValues(alpha: 0.3),
            ),
          ),
          child: isLargeScreen
              ? _buildActivityRow()
              : _buildActivityColumn(),
        ),
        SizedBox(height: isLargeScreen ? 12 : 10),
        // Última actualización
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.access_time,
              color: Colors.white70,
              size: 16,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Última actividad: ${_formatDate(_exerciseSummary!.lastUpdated)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFCCF24D), Color(0xFFC8B8FF)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.fitness_center,
            color: Colors.black,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ejercicios Completados',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_exerciseSummary!.exercisesCompleted} ejercicios',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${_exerciseSummary!.totalCaloriesBurned}',
              style: const TextStyle(
                color: Color(0xFFCCF24D),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Text(
              'kcal',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityColumn() {
    return Column(
      children: [
        // Fila superior: Icono + Texto
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFCCF24D), Color(0xFFC8B8FF)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: Colors.black,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ejercicios Completados',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_exerciseSummary!.exercisesCompleted} ejercicios',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Divisor
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                const Color(0xFFCCF24D).withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Fila inferior: Calorías
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFCCF24D).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_fire_department,
                color: Color(0xFFCCF24D),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Text(
                  '${_exerciseSummary!.totalCaloriesBurned}',
                  style: const TextStyle(
                    color: Color(0xFFCCF24D),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'kcal quemadas',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatsCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: isLargeScreen ? 32 : 28, color: color),
          SizedBox(height: isLargeScreen ? 12 : 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isLargeScreen ? 28 : 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isLargeScreen ? 12 : 11,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFCCF24D)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}




