import 'package:flutter/material.dart';

class RoutinesTab extends StatefulWidget {
  final int userId;

  const RoutinesTab({super.key, required this.userId});

  @override
  State<RoutinesTab> createState() => _RoutinesTabState();
}

class _RoutinesTabState extends State<RoutinesTab> {
  // TODO: Cargar rutinas desde API
  final List<Map<String, dynamic>> _routines = [
    {
      'name': 'Rutina de Fuerza',
      'exercises': 12,
      'duration': 45,
      'difficulty': 'Intermedio',
      'icon': Icons.fitness_center,
      'color': const Color(0xFFC8B8FF),
    },
    {
      'name': 'Cardio Intenso',
      'exercises': 8,
      'duration': 30,
      'difficulty': 'Avanzado',
      'icon': Icons.directions_run,
      'color': const Color(0xFFCCF24D),
    },
    {
      'name': 'Yoga & Estiramiento',
      'exercises': 15,
      'duration': 60,
      'difficulty': 'Principiante',
      'icon': Icons.self_improvement,
      'color': const Color(0xFFC8B8FF),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis Rutinas',
                style: TextStyle(
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

        // Lista de rutinas
        Expanded(
          child: _routines.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _routines.length,
                  itemBuilder: (context, index) {
                    final routine = _routines[index];
                    return _RoutineCard(
                      name: routine['name'],
                      exercises: routine['exercises'],
                      duration: routine['duration'],
                      difficulty: routine['difficulty'],
                      icon: routine['icon'],
                      color: routine['color'],
                      onTap: () => _openRoutineDetail(routine),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fitness_center, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            'No tienes rutinas aún',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea tu primera rutina',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateRoutineDialog,
            icon: const Icon(Icons.add),
            label: const Text('Crear Rutina'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCCF24D),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateRoutineDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Rutina'),
        content: const Text(
          'Esta funcionalidad estará disponible próximamente.\n\n'
          'Podrás crear rutinas personalizadas con ejercicios específicos.',
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

  void _openRoutineDetail(Map<String, dynamic> routine) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abriendo: ${routine['name']}'),
        duration: const Duration(seconds: 1),
      ),
    );
    // TODO: Navegar a pantalla de detalle de rutina
  }
}

class _RoutineCard extends StatelessWidget {
  final String name;
  final int exercises;
  final int duration;
  final String difficulty;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoutineCard({
    required this.name,
    required this.exercises,
    required this.duration,
    required this.difficulty,
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
                            text: '$duration min',
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        difficulty,
                        style: TextStyle(
                          color: _getDifficultyColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Flecha
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

  Color _getDifficultyColor() {
    switch (difficulty) {
      case 'Principiante':
        return const Color(0xFFCCF24D);
      case 'Intermedio':
        return Colors.orange;
      case 'Avanzado':
        return Colors.red;
      default:
        return Colors.white70;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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

