import 'package:flutter/material.dart';

import 'exercise_detail_screen.dart';

class RoutineDayScreen extends StatelessWidget {
  final String dayName;
  final String warmup;
  final List<dynamic> exercises;
  final String cooldown;
  final int userId;
  final int routineId;
  final String authToken;
  const RoutineDayScreen({
    super.key,
    required this.dayName,
    required this.warmup,
    required this.exercises,
    required this.cooldown,
    required this.userId,
    required this.routineId,
    required this.authToken,
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: Text(dayName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle("Warmup"),
          Text(warmup, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),

          _sectionTitle("Ejercicios"),
          ...exercises.map((e) =>
              _exerciseCard(context, e)
          ),

          const SizedBox(height: 20),
          _sectionTitle("Cooldown"),
          Text(cooldown, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _exerciseCard(BuildContext context, dynamic ex) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExerciseDetailScreen(
              exercise: ex,
              userId: userId,
              routineId: routineId,
              authToken: authToken,

            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            // Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ex["image_url"] != null
                  ? Image.network(
                ex["image_url"],
                height: 60,
                width: 60,
                fit: BoxFit.cover,
              )
                  : Container(
                height: 60,
                width: 60,
                color: Colors.grey,
                child: const Icon(Icons.image_not_supported, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ex["name"] ?? "Ejercicio",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Series: ${ex["sets"]}   Reps: ${ex["reps"]}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }
}
