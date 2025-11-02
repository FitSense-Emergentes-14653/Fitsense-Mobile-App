import 'package:flutter/material.dart';
import 'package:fitsense/core/widgets/drawer/background.dart';
import 'package:fitsense/core/widgets/drawer/user_navbar.dart';

import 'package:fitsense/features/auth/presentation/settings/athlete_settings_screen.dart';

class AthleteHomeScreen extends StatefulWidget {
  const AthleteHomeScreen({super.key});

  @override
  State<AthleteHomeScreen> createState() => _AthleteHomeScreenState();
}

class _AthleteHomeScreenState extends State<AthleteHomeScreen> {
  int _index = 0;

  final List<Widget> _screens = const [
    _HomeTab()
  ];

  void _onTapNavbar(int i) {
    // Navegación al chat
    if (i == 1) {
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, __, ___) => const AthleteSettingsScreen(),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
        ),
      );
      return;
    }
    // Navegación a los favoritos
    if (i == 2) {
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, __, ___) => const AthleteSettingsScreen(),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
        ),
      );
      return;
    }
    // Navegación a la configuración
    if (i == 3) {
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, __, ___) => const AthleteSettingsScreen(),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
        ),
      );
      return;
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      useSafeArea: false,
      child: Stack(
        children: [
          // Contenido principal
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _screens[_index],
            ),
          ),

          // Navbar inferior
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: UserNavbar(
              selectedIndex: _index,
              onTap: _onTapNavbar,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('home'),
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
    );
  }
}
