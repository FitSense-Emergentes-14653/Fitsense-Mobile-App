import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'exercise_completed_screen.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final int userId;
  final int routineId;
  final String authToken;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    required this.userId,
    required this.routineId,
    required this.authToken,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late String baseUrl;
  int frameIndex = 0;
  Timer? _timer;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    String fullUrl = widget.exercise["image_url"];
    baseUrl = fullUrl.replaceAll("0.jpg", "");

    _startAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() {
        frameIndex = frameIndex == 0 ? 1 : 0;
      });
    });
  }

  Future<void> completeExercise() async {
    setState(() => isLoading = true);

    final url = Uri.parse(
      "http://10.0.2.2:8080/api/v1/challenges/complete"
          "?userId=${widget.userId}"
          "&routineId=${widget.routineId}"
          "&exerciseName=${widget.exercise["name"]}",
    );

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer ${widget.authToken}",
          "Accept": "application/json",
        },
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ExerciseCompletedScreen(),
          ),
        );
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error del servidor: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error de conexión: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final imageUrl = "$baseUrl$frameIndex.jpg";

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: Text(widget.exercise["name"]),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              imageUrl,
              height: 260,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 20),

          Text("Series: ${widget.exercise["sets"]}",
              style: const TextStyle(color: Colors.white, fontSize: 18)),
          Text("Reps: ${widget.exercise["reps"]}",
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Text("Descanso: ${widget.exercise["rest_sec"]} segundos",
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Text("Calorías estimadas: ${widget.exercise["calories_total"]}",
              style: const TextStyle(color: Colors.white70, fontSize: 16)),

          const SizedBox(height: 90),
        ],
      ),


        bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.greenAccent.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: isLoading ? null : completeExercise,
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
            "Marcar como completado",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
