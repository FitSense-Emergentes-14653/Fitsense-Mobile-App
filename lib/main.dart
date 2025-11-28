import 'package:flutter/material.dart';
import 'package:fitsense/features/auth/presentation/login/login_screen.dart';
import 'package:fitsense/infrastructure/services/session_service.dart';

import 'features/auth/presentation/notifications/notifications_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionService().init();
  await NotificationHandler.init();

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
      home: const LoginScreen(),
    );
  }
}
