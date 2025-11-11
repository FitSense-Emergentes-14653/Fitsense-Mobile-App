import 'package:flutter/material.dart';

/// Fondo base negro reutilizable para la app.
/// Envuelve tu contenido y respeta los insets seguros.
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;
  final bool scrollable;

  const AppBackground({
    super.key,
    required this.child,
    this.useSafeArea = true,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        Widget content = Container(
          color: Colors.black,
          child: child,
        );

        if (scrollable) {
          content = SingleChildScrollView(
            child: content,
            physics: const ClampingScrollPhysics(),
          );
        }

        if (useSafeArea) {
          content = SafeArea(
            child: content,
            minimum: EdgeInsets.symmetric(
              horizontal: isWide ? 24.0 : 16.0,
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: content,
        );
      },
    );
  }
}
