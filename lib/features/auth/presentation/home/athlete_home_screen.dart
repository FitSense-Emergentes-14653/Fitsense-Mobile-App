import 'package:flutter/material.dart';
import 'package:fitsense/core/widgets/drawer/background.dart';

class AthleteHomeScreen extends StatelessWidget {
  const AthleteHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.fitness_center, color: Colors.white, size: 64),
            SizedBox(height: 12),
            Text(
              'Athlete Home',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
