import 'package:flutter/material.dart';
import 'package:fitsense/core/widgets/drawer/background.dart';
import 'package:fitsense/core/widgets/drawer/user_navbar.dart';
import '../chatbot/athlete_chatbot_screen.dart';
import '../settings/athlete_settings_screen.dart';
import 'tabs/home_tab.dart';
import 'tabs/routines_tab.dart';
import 'tabs/progress_tab.dart';

class AthleteHomeScreen extends StatefulWidget {
  final int userId;

  const AthleteHomeScreen({super.key, required this.userId});

  @override
  State<AthleteHomeScreen> createState() => _AthleteHomeScreenState();
}

class _AthleteHomeScreenState extends State<AthleteHomeScreen> {
  int _index = 0;

  List<Widget> get _screens => [
    HomeTab(userId: widget.userId),
    RoutinesTab(userId: widget.userId),
    ProgressTab(userId: widget.userId),
  ];

  void _openChatbot() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => AthleteChatbotScreen(userId: widget.userId),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      useSafeArea: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          final maxContentWidth = constraints.maxWidth > 1200 ? 1200.0 : constraints.maxWidth;

          return Stack(
            children: [
              // Contenido principal
              Positioned.fill(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: maxContentWidth,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 24.0 : 16.0,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _screens[_index],
                    ),
                  ),
                ),
              ),
              // Botón de chat
              SafeArea(
                minimum: EdgeInsets.only(
                  right: isWide ? 32.0 : 20.0,
                  bottom: 12 + UserNavbar.kHeight,
                ),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton.extended(
                    heroTag: 'athlete_chatbot',
                    onPressed: _openChatbot,
                    backgroundColor: const Color(0xFF8A5CF6),
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text(
                      'Chat',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              // Barra de navegación
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: UserNavbar(
                  selectedIndex: _index,
                  onTap: (index) {
                    if (index == 3) {
                      // Configuración
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 300),
                          pageBuilder: (_, __, ___) => AthleteSettingsScreen(userId: widget.userId),
                          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                        ),
                      );
                    } else {
                      setState(() => _index = index);
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


