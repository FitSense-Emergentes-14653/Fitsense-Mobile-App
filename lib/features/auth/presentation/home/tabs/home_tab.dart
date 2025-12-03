import 'package:flutter/material.dart';
import 'package:fitsense/infrastructure/services/session_service.dart';
import 'package:fitsense/features/auth/data/datasources/athlete_remote_data_source.dart';
import 'package:fitsense/features/auth/domain/repositories/athlete_repository.dart';
import 'package:fitsense/features/auth/data/models/athlete_model.dart';
import 'package:fitsense/features/auth/data/services/routine_service.dart';
import 'package:fitsense/features/auth/data/services/home_dashboard_service.dart';
import 'package:fitsense/features/auth/data/services/weekly_progress_service.dart';
import 'routine_day_screen.dart';

import '../../notifications/notifications_page.dart';

class HomeTab extends StatefulWidget {
  final int userId;
  final VoidCallback? onOpenChatbot;

  const HomeTab({
    super.key,
    required this.userId,
    this.onOpenChatbot,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _repo = AthleteRepository(AthleteRemoteDataSource());
  final _session = SessionService();
  final _routineService = RoutineService();
  final _dashboardService = HomeDashboardService();

  AthleteModel? _athlete;
  TodayWorkout? _todayWorkout;
  HomeDashboardData? _dashboardData;
  bool _loading = true;
  bool _hasRoutines = false;

  @override
  void initState() {
    super.initState();
    _loadAthleteData();
  }

  Future<void> _loadAthleteData() async {
    try {
      await _session.init();
      final athleteId = _session.getAthleteId();

      print('🏠 [HomeTab] AthleteId de sesión: $athleteId');
      print('🏠 [HomeTab] UserId: ${widget.userId}');

      if (athleteId > 0) {
        print('🏠 [HomeTab] Cargando datos del atleta...');
        final athlete = await _repo.getById(athleteId);
        print('🏠 [HomeTab] Atleta cargado: ${athlete.fullname}');

        // Cargar todos los datos en paralelo para mejor rendimiento
        print('🏠 [HomeTab] Cargando rutina y dashboard...');
        final results = await Future.wait([
          _routineService.getTodayWorkout(widget.userId),
          _routineService.hasRoutines(widget.userId),
          _dashboardService.getDashboardData(widget.userId, athleteId),
        ]);

        final workout = results[0] as TodayWorkout?;
        final hasRoutines = results[1] as bool;
        final dashboardData = results[2] as HomeDashboardData;

        if (workout != null) {
          print('🏠 [HomeTab] Workout del día cargado: ${workout.dayName}');
        } else {
          print('🏠 [HomeTab] No hay workout para hoy');
        }

        print('🏠 [HomeTab] Dashboard cargado: ${dashboardData.daysCompletedThisWeek}/7 días');

        if (mounted) {
          setState(() {
            _athlete = athlete;
            _todayWorkout = workout;
            _hasRoutines = hasRoutines;
            _dashboardData = dashboardData;
            _loading = false;
          });
        }
      } else {
        print('⚠️ [HomeTab] No hay athleteId en sesión');

        if (mounted) {
          setState(() {
            _loading = false;
            _athlete = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, completa tu perfil de atleta primero.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ [HomeTab] Error al cargar datos: $e');

      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: ${e.toString()}'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Reintentar',
              onPressed: _loadAthleteData,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "FitSense",
          style: TextStyle(
            color: Color(0xFFB8B4FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsPage(
                    userId: widget.userId,
                    authToken: _session.getToken(),
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_none,
              color: Color(0xFFB8B4FF),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),

      body: _loading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.yellow),
      )
          : _athlete == null
          ? _buildEmptyState()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            _buildQuickStats(),
            const SizedBox(height: 20),
            _buildTodayWorkout(),
            const SizedBox(height: 20),
            _buildWeeklyProgress(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 80,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            const Text(
              'No se encontró tu perfil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Por favor, completa tu configuración de atleta.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAthleteData,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCCF24D),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFC8B8FF), Color(0xFFCCF24D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, ${_athlete!.fullname.split(' ').first}! 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Meta: ${_athlete!.goal}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.fitness_center, size: 48, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final calories = _dashboardData?.totalCaloriesBurned ?? 0;
    final waterProgress = _dashboardData?.waterProgressPercentage.toInt() ?? 0;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department,
            value: '$calories',
            label: 'Calorías Quemadas',
            color: const Color(0xFFFFA726),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.water_drop,
            value: '$waterProgress%',
            label: 'Hidratación',
            color: const Color(0xFF42A5F5),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayWorkout() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.today, color: Colors.yellow, size: 20),
              SizedBox(width: 8),
              Text(
                'Entrenamiento de Hoy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Si hay entrenamiento del día, mostrarlo
          if (_todayWorkout != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFC8B8FF), Color(0xFFCCF24D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _todayWorkout!.dayName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Semana ${_todayWorkout!.weekNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.fitness_center, size: 16, color: Colors.black87),
                      const SizedBox(width: 4),
                      Text(
                        '${_todayWorkout!.exercisesCount} ejercicios',
                        style: const TextStyle(color: Colors.black87, fontSize: 13),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time, size: 16, color: Colors.black87),
                      const SizedBox(width: 4),
                      Text(
                        '~${_todayWorkout!.estimatedDuration} min',
                        style: const TextStyle(color: Colors.black87, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '🔥 ${_todayWorkout!.warmup}',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _startWorkout(),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar Entrenamiento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCCF24D),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ] else ...[
            // Si no hay entrenamiento, mostrar mensaje y botón para crear
            const Text(
              'No hay entrenamientos programados',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            const Text(
              'Crea una rutina personalizada con nuestro asistente IA',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToChatbot,
                icon: const Icon(Icons.smart_toy),
                label: const Text('Crear Rutina con IA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCCF24D),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToChatbot() {
    print('🤖 [HomeTab] Navegando al chatbot...');

    if (widget.onOpenChatbot != null) {
      widget.onOpenChatbot!();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.smart_toy, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('¡Hola! Pregúntame sobre tu rutina de entrenamiento 💪'),
              ),
            ],
          ),
          backgroundColor: Color(0xFF8A5CF6),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ No se pudo abrir el chatbot'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _startWorkout() async {
    if (_todayWorkout == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ No hay entrenamiento disponible'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    print('🏋️ [HomeTab] Iniciando entrenamiento: ${_todayWorkout!.dayName}');
    print('🏋️ [HomeTab] Ejercicios: ${_todayWorkout!.exercisesCount}');
    print('🏋️ [HomeTab] RoutineId: ${_todayWorkout!.routineId}');

    // Obtener el token
    final token = _session.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ No se pudo obtener el token de autenticación'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Navegar a la pantalla de detalle del día
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RoutineDayScreen(
          dayName: _todayWorkout!.dayName,
          warmup: _todayWorkout!.warmup,
          exercises: _todayWorkout!.exercises,
          cooldown: _todayWorkout!.cooldown,
          userId: widget.userId,
          routineId: _todayWorkout!.routineId,
          authToken: token,
        ),
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    final progress = _dashboardData?.weeklyProgress ?? WeeklyProgress.empty();
    final completedDays = progress.completedDaysList;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
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
                  Icon(Icons.trending_up, color: Colors.yellow, size: 20),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCF24D).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCCF24D)),
                ),
                child: Text(
                  '${progress.daysCompleted}/${progress.totalDays}',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
              final isCompleted = completedDays[index];

              return Column(
                children: [
                  Text(
                    days[index],
                    style: TextStyle(
                      color: isCompleted ? const Color(0xFFCCF24D) : Colors.white70,
                      fontSize: 12,
                      fontWeight: isCompleted ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 10,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: isCompleted
                          ? const LinearGradient(
                              colors: [Color(0xFFCCF24D), Color(0xFFC8B8FF)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : null,
                      color: isCompleted ? null : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: isCompleted
                            ? const Color(0xFFCCF24D).withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: isCompleted
                        ? const Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.black,
                              size: 16,
                            ),
                          )
                        : null,
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 16),
          // Mensaje motivacional
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFC8B8FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFC8B8FF).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: Color(0xFFCCF24D),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    progress.motivationalMessage,
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
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.black54),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
