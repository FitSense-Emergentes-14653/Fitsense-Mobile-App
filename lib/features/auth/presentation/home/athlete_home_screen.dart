import 'package:flutter/material.dart';
import 'package:fitsense/core/widgets/drawer/background.dart';
import 'package:fitsense/core/widgets/drawer/user_navbar.dart';
import '../chatbot/athlete_chatbot_screen.dart';
import '../settings/athlete_settings_screen.dart';
import 'tabs/home_tab.dart';
import 'tabs/metrics_tab.dart';
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
    HomeTab(userId: widget.userId, onOpenChatbot: _openChatbot),
    MetricsTab(userId: widget.userId),
    RoutinesTab(userId: widget.userId, onOpenChatbot: _openChatbot),
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
              // Content area con transiciones suaves
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
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeInOutCubic,
                      switchOutCurve: Curves.easeInOutCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.02, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        key: ValueKey(_index),
                        child: _screens[_index],
                      ),
                    ),
                  ),
                ),
              ),

              // Botón de chatbot mejorado con glassmorphism
              SafeArea(
                minimum: EdgeInsets.only(
                  right: isWide ? 32.0 : 20.0,
                  bottom: 16 + UserNavbar.kHeight,
                ),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8A5CF6).withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _openChatbot,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isWide ? 24 : 20,
                            vertical: isWide ? 16 : 14,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF8A5CF6),
                                Color(0xFFA78BFA),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.smart_toy_rounded,
                                  color: Colors.white,
                                  size: isWide ? 22 : 20,
                                ),
                              ),
                              SizedBox(width: isWide ? 12 : 10),
                              Text(
                                isWide ? 'Asistente IA' : 'Chat IA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: isWide ? 16 : 15,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCCF24D),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.black,
                                  size: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Barra de navegación mejorada
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  child: UserNavbar(
                    selectedIndex: _index,
                    onTap: (index) {
                      if (index == 4) {
                        // Configuración con animación
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 350),
                            pageBuilder: (_, __, ___) => AthleteSettingsScreen(userId: widget.userId),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.1, 0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  )),
                                  child: child,
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        setState(() => _index = index);
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


