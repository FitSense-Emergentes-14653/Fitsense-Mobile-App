import 'dart:convert';
import 'package:fitsense/features/auth/presentation/home/tabs/routine_day_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fitsense/infrastructure/services/session_service.dart';
import 'package:fitsense/infrastructure/config/app_config.dart';
import 'package:fitsense/features/auth/data/datasources/athlete_remote_data_source.dart';
import 'package:fitsense/features/auth/domain/repositories/athlete_repository.dart';
import 'package:fitsense/features/auth/data/models/athlete_model.dart';

class RoutinesTab extends StatefulWidget {
  final int userId;
  final VoidCallback? onOpenChatbot;

  const RoutinesTab({
    super.key,
    required this.userId,
    this.onOpenChatbot,
  });

  @override
  State<RoutinesTab> createState() => _RoutinesTabState();
}

class _RoutinesTabState extends State<RoutinesTab> {
  final _session = SessionService();
  final _athleteRepo = AthleteRepository(AthleteRemoteDataSource());
  int? _lastRoutineId;

  bool _loading = true;
  AthleteModel? _athlete;

  Map<int, List<_RoutineDay>> _groupedDays = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _session.init();
      await _fetchLatestRoutineId();
      final token = _session.getToken();
      final athleteId = _session.getAthleteId();


      print("🧪 [RoutinesTab] userId recibido: ${widget.userId}");
      print("🧪 [RoutinesTab] athleteId de sesión: $athleteId");

      if (athleteId > 0) {
        _athlete = await _athleteRepo.getById(athleteId);
        print("🏋 [RoutinesTab] Atleta cargado: ${_athlete?.fullname}");
      }

      final url = Uri.parse(
        "${AppConfig.apiBaseUrl}/challenges/user/${widget.userId}",
      );

      print("📡 [RoutinesTab] GET → $url");

      final res = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("📥 [RoutinesTab] Status: ${res.statusCode}");
      print("📥 [RoutinesTab] Body: ${res.body}");

      if (res.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(res.body);
        _parseRoutineDays(jsonList);

        if (mounted) {
          setState(() => _loading = false);
        }
      } else if (res.statusCode == 401) {
        throw Exception("No autorizado (401): revisa token o login.");
      } else {
        throw Exception("Error ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      print("Error cargando rutinas: $e");
      if (mounted) setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar rutinas: $e")),
      );
    }
  }

  Future<void> _fetchLatestRoutineId() async {
    final token = _session.getToken();

    final url = Uri.parse(
      "${AppConfig.apiBaseUrl}/challenges/user/${widget.userId}/latest",
    );

    print("📡 [RoutinesTab] GET latest → $url");

    final res = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      _lastRoutineId = json["id"];
      print("🏆 Último routineId: $_lastRoutineId");
    } else {
      print("Error obteniendo routineId latest: ${res.body}");
    }
  }


  /// Agrupa por semana
  void _parseRoutineDays(List<dynamic> challenges) {
    final Map<int, List<_RoutineDay>> grouped = {};

    for (final ch in challenges) {
      final rutina = ch['rutinaJson'];
      if (rutina == null) continue;

      final weeks = rutina['weeks'] as List<dynamic>? ?? [];

      for (final w in weeks) {
        final int weekNumber = (w['week'] ?? 0) as int;
        final List<dynamic> wDays = w['days'] ?? [];

        for (final d in wDays) {
          final String name = d['name'] ?? 'Día';
          final List<dynamic> exercises = d['exercises'] ?? [];
          final String warmup = d['warmup'] ?? "5 min calentamiento";
          final String cooldown = d['cooldown'] ?? "5 min cooldown";


          const int estimatedDuration = 45;

          final day = _RoutineDay(
            title: name,
            week: weekNumber,
            exercisesCount: exercises.length,
            duration: estimatedDuration,
            warmup: warmup,
            cooldown: cooldown,
            exercisesList: exercises,
          );


          grouped.putIfAbsent(weekNumber, () => []);
          grouped[weekNumber]!.add(day);
        }
      }
    }

    print("📊 [RoutinesTab] Semanas detectadas: ${grouped.length}");
    setState(() => _groupedDays = grouped);
  }

  void _showCreateRoutineDialog() {
    print('🤖 [RoutinesTab] Abriendo chatbot para crear rutina...');

    if (widget.onOpenChatbot != null) {
      widget.onOpenChatbot!();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.smart_toy, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('¡Hola! Cuéntame sobre tus objetivos y crearé tu rutina 💪'),
              ),
            ],
          ),
          backgroundColor: Color(0xFF8A5CF6),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      // Fallback si no hay callback
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Crear Rutina'),
          content: const Text(
            'Usa el botón de Chat flotante para crear tu rutina personalizada con nuestro asistente IA.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.yellow),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _athlete != null
                    ? 'Mis Rutinas de ${_athlete!.fullname.split(' ').first}'
                    : 'Mis Rutinas',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                onPressed: _showCreateRoutineDialog,
                icon: const Icon(Icons.add_circle, color: Colors.yellow, size: 32),
              ),
            ],
          ),
        ),

        Expanded(
          child: _groupedDays.isEmpty
              ? _buildEmptyState()
              : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _groupedDays.entries.map((entry) {
              final week = entry.key;
              final days = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  /// Encabezado de la semana
                  Text(
                    "Semana $week",
                    style: const TextStyle(
                      color: Color(0xFFCCF24D),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  ...days.map((d) {
                    return _RoutineCard(
                      name: d.title,
                      exercises: d.exercisesCount,
                      duration: d.duration,
                      icon: Icons.fitness_center,
                      color: const Color(0xFFC8B8FF),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RoutineDayScreen(
                              dayName: d.title,
                              warmup: d.warmup,
                              exercises: d.exercisesList,
                              cooldown: d.cooldown,
                              userId: widget.userId,
                              routineId: _lastRoutineId!,
                              authToken: _session.getToken(),
                            ),
                          ),
                        );
                      }
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 80,
                color: Color(0xFFCCF24D),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No tienes rutinas aún',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Crea tu primera rutina personalizada\ncon nuestro asistente IA',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showCreateRoutineDialog,
              icon: const Icon(Icons.smart_toy, size: 24),
              label: const Text(
                'Crear Rutina con IA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCCF24D),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF8A5CF6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF8A5CF6).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Color(0xFF8A5CF6),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'El chatbot te ayudará a crear una rutina\nadaptada a tus objetivos',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _RoutineDay {
  final String title;
  final int week;
  final int exercisesCount;
  final int duration;

  final String warmup;
  final String cooldown;
  final List<dynamic> exercisesList;

  _RoutineDay({
    required this.title,
    required this.week,
    required this.exercisesCount,
    required this.duration,
    required this.warmup,
    required this.cooldown,
    required this.exercisesList,
  });
}


class _RoutineCard extends StatelessWidget {
  final String name;
  final int exercises;
  final int duration;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoutineCard({
    required this.name,
    required this.exercises,
    required this.duration,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                // Icono
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 32, color: Colors.black),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.fitness_center,
                            text: '$exercises ejercicios',
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.timer,
                            text: '$duration min aprox.',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white54,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
