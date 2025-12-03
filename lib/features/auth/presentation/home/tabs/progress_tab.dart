import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fitsense/features/auth/data/services/exercise_summary_service.dart';
import 'package:fitsense/features/auth/data/services/water_intake_service.dart';
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
  final SessionService _session = SessionService();

  bool _loading = true;
  int? _athleteId;
  ExerciseSummaryModel? _exerciseSummary;
  WaterIntakeModel? _waterIntake;

  // Datos de progreso semanal (simulado por ahora)
  final List<int> _weeklyWorkouts = [2, 3, 4, 3, 5, 4, 3, 2, 4, 3, 5, 4];

  // Historial de workouts (se puede expandir con endpoints reales)
  final Map<DateTime, List<String>> _workouts = {
    DateTime.now().subtract(const Duration(days: 1)): ['Rutina de Fuerza'],
    DateTime.now().subtract(const Duration(days: 3)): ['Cardio'],
    DateTime.now().subtract(const Duration(days: 5)): ['Yoga'],
  };

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

      print('📊 [PROGRESS TAB] Cargando datos para userId: ${widget.userId}, athleteId: $_athleteId');

      if (_athleteId == null || _athleteId == 0) {
        print('⚠️ [PROGRESS TAB] AthleteId no disponible');
        setState(() => _loading = false);
        return;
      }

      // Obtener último routineId
      final routineId = await _exerciseService.getLatestRoutineId(widget.userId);

      if (routineId != null) {
        // Obtener resumen de ejercicios
        _exerciseSummary = await _exerciseService.getExerciseSummary(widget.userId, routineId);
        print('📊 [PROGRESS TAB] Exercise Summary: ${_exerciseSummary?.totalCaloriesBurned ?? 0} calorías');
      }

      // Obtener datos de hidratación
      _waterIntake = await _waterService.getTodayWaterIntake(_athleteId!);
      print('💧 [PROGRESS TAB] Hidratación: ${_waterIntake?.glasses ?? 0} vasos / ${_waterIntake?.goalGlasses ?? 8} vasos');

      setState(() => _loading = false);
    } catch (e) {
      print('❌ [PROGRESS TAB] Error cargando datos: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;
    final maxWidth = isWeb ? 800.0 : screenWidth;

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
                      horizontal: isWeb ? 24.0 : 16.0,
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
                        _buildStatsOverview(isWeb),

                        const SizedBox(height: 16),

                        // Calendario
                        _buildCalendar(isWeb),

                        const SizedBox(height: 16),

                        // Gráfico de progreso
                        _buildProgressChart(isWeb),

                        const SizedBox(height: 16),

                        // Métricas adicionales
                        _buildAdditionalMetrics(isWeb),

                        const SizedBox(height: 16),

                        // Historial reciente
                        _buildRecentHistory(isWeb),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatsOverview(bool isWeb) {
    final calories = _exerciseSummary?.totalCaloriesBurned ?? 0;
    final exercisesCompleted = _exerciseSummary?.exercisesCompleted ?? 0;
    final waterProgress = _waterIntake != null && _waterIntake!.goalGlasses > 0
        ? (_waterIntake!.glasses / _waterIntake!.goalGlasses * 100).toInt()
        : 0;

    if (isWeb) {
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

  Widget _buildCalendar(bool isWeb) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 16 : 12),
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
        eventLoader: (day) {
          return _workouts[day] ?? [];
        },
      ),
    );
  }

  Widget _buildProgressChart(bool isWeb) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 20 : 16),
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
              Icon(Icons.show_chart, color: Colors.yellow, size: 20),
              SizedBox(width: 8),
              Text(
                'Entrenamientos por Semana',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gráfico de barras con datos reales
          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = isWeb ? 30.0 : (constraints.maxWidth / _weeklyWorkouts.length * 0.6);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(_weeklyWorkouts.length, (index) {
                  final workouts = _weeklyWorkouts[index];
                  final height = 30.0 + (workouts * 15.0);
                  final isCurrentWeek = index == (_weeklyWorkouts.length - 1);

                  return Column(
                    children: [
                      // Valor encima de la barra
                      Text(
                        workouts.toString(),
                        style: TextStyle(
                          color: isCurrentWeek ? const Color(0xFFCCF24D) : Colors.white70,
                          fontSize: isWeb ? 12 : 10,
                          fontWeight: isCurrentWeek ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: barWidth.clamp(15.0, 40.0),
                        height: height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isCurrentWeek
                                ? [const Color(0xFFCCF24D), const Color(0xFFCCF24D).withValues(alpha: 0.6)]
                                : [const Color(0xFFCCF24D).withValues(alpha: 0.7), const Color(0xFFC8B8FF).withValues(alpha: 0.5)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'S${index + 1}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isWeb ? 11 : 9,
                        ),
                      ),
                    ],
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Últimas ${_weeklyWorkouts.length} semanas',
              style: TextStyle(
                color: Colors.white70,
                fontSize: isWeb ? 13 : 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalMetrics(bool isWeb) {
    if (_exerciseSummary == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(isWeb ? 20 : 16),
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

  Widget _buildRecentHistory(bool isWeb) {
    final recentWorkouts = [
      {'date': 'Hace 1 día', 'name': 'Rutina de Fuerza', 'duration': '45 min'},
      {'date': 'Hace 3 días', 'name': 'Cardio Intenso', 'duration': '30 min'},
      {'date': 'Hace 5 días', 'name': 'Yoga & Estiramiento', 'duration': '60 min'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Historial Reciente',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: Navegar a historial completo
              },
              icon: const Icon(Icons.history, color: Color(0xFFCCF24D), size: 16),
              label: const Text(
                'Ver todo',
                style: TextStyle(color: Color(0xFFCCF24D), fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...recentWorkouts.map((workout) => _HistoryItem(
          date: workout['date']!,
          name: workout['name']!,
          duration: workout['duration']!,
          isWeb: isWeb,
        )),
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
    final isWeb = screenWidth > 600;

    return Container(
      padding: EdgeInsets.all(isWeb ? 20 : 16),
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
          Icon(icon, size: isWeb ? 32 : 28, color: color),
          SizedBox(height: isWeb ? 12 : 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isWeb ? 28 : 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isWeb ? 12 : 11,
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

class _HistoryItem extends StatelessWidget {
  final String date;
  final String name;
  final String duration;
  final bool isWeb;

  const _HistoryItem({
    required this.date,
    required this.name,
    required this.duration,
    this.isWeb = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(isWeb ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isWeb ? 12 : 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFC8B8FF), Color(0xFFCCF24D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.fitness_center,
              size: isWeb ? 24 : 20,
              color: Colors.black,
            ),
          ),
          SizedBox(width: isWeb ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isWeb ? 15 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            duration,
            style: const TextStyle(
              color: Colors.yellow,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

