import 'package:fitsense/features/auth/presentation/home/athlete_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ExerciseCompletedScreen extends StatefulWidget {
  const ExerciseCompletedScreen({super.key});

  @override
  State<ExerciseCompletedScreen> createState() => _ExerciseCompletedScreenState();
}

class _ExerciseCompletedScreenState extends State<ExerciseCompletedScreen>
    with SingleTickerProviderStateMixin {

  late ConfettiController _confetti;
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    print("🎯 ExerciseCompletedScreen CARGADO");
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _confetti.play();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _bounceAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _confetti.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Stack(
          children: [

            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.12,
                numberOfParticles: 18,
                gravity: 0.25,
                maxBlastForce: 16,
                minBlastForce: 6,
                colors: const [
                  Colors.yellow,
                  Colors.orange,
                  Colors.white,
                  Colors.amber,
                  Colors.deepOrange,
                ],
              ),
            ),

            Align(
              alignment: Alignment(0, -0.2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _bounceAnimation,
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 160,
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "¡Ejercicio completado!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Sigue entrenando",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
