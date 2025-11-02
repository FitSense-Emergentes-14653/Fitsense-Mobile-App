import 'package:flutter/material.dart';
import 'package:fitsense/core/widgets/drawer/background.dart';
import 'package:fitsense/core/widgets/drawer/user_navbar.dart';

class AthleteHomeScreen extends StatefulWidget {
  const AthleteHomeScreen({super.key});

  @override
  State<AthleteHomeScreen> createState() => _AthleteHomeScreenState();
}

class _AthleteHomeScreenState extends State<AthleteHomeScreen> {
  int _index = 0;

  // Reemplazar por las vistas verdaderas
  final List<Widget> _screens = const [
    _HomeTab(),
    _ChatTab(),
    _StarsTab(),
    _ConfigTab(),
  ];

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
              onTap: (i) => setState(() => _index = i),
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

class _ChatTab extends StatelessWidget {
  const _ChatTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: ValueKey('chat'),
      child: Text(
        'Chat',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}

class _StarsTab extends StatelessWidget {
  const _StarsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: ValueKey('stars'),
      child: Text(
        'Stars / Reviews',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}

class _ConfigTab extends StatelessWidget {
  const _ConfigTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: ValueKey('config'),
      child: Text(
        'Configuración',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}
