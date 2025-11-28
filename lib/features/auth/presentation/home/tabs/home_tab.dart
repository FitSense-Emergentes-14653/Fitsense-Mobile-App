import 'package:flutter/material.dart';
import 'package:fitsense/infrastructure/services/session_service.dart';
import 'package:fitsense/features/auth/data/datasources/athlete_remote_data_source.dart';
import 'package:fitsense/features/auth/domain/repositories/athlete_repository.dart';
import 'package:fitsense/features/auth/data/models/athlete_model.dart';

import '../../notifications/notifications_page.dart';

class HomeTab extends StatefulWidget {
  final int userId;

  const HomeTab({super.key, required this.userId});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _repo = AthleteRepository(AthleteRemoteDataSource());
  final _session = SessionService();
  AthleteModel? _athlete;
  bool _loading = true;

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

      if (athleteId > 0) {
        print('🏠 [HomeTab] Cargando datos del atleta...');
        final athlete = await _repo.getById(athleteId);
        print('🏠 [HomeTab] Atleta cargado: ${athlete.fullname}');

        if (mounted) {
          setState(() {
            _athlete = athlete;
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
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
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
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.monitor_weight,
            value: '${_athlete!.weight.toStringAsFixed(1)} kg',
            label: 'Peso Actual',
            color: const Color(0xFFC8B8FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.height,
            value: '${_athlete!.height.toInt()} cm',
            label: 'Altura',
            color: const Color(0xFFCCF24D),
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
          const Text(
            'No hay entrenamientos programados',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad próximamente')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear Rutina'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCCF24D),
                foregroundColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress() {
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
              return Column(
                children: [
                  Text(
                    days[index],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 8,
                    height: 40,
                    decoration: BoxDecoration(
                      color: index < 3
                          ? const Color(0xFFCCF24D)
                          : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          const Text(
            '3 de 7 días completados esta semana',
            style: TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
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
