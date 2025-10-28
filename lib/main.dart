import 'package:flutter/material.dart';

import 'features/auth/presentation/welcome/welcome_page.dart';

void main() {
  runApp(const FitSenseApp());
}

class FitSenseApp extends StatelessWidget {
  const FitSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitSense',
      theme: ThemeData(fontFamily: 'Inter'),
      home: const WelcomePage(),
    );
  }
}