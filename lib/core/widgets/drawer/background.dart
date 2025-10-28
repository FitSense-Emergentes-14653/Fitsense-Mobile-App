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
    final content = Container(
      color: Colors.black, // 🎯 Fondo negro sólido
      child: child,
    );

    final safe = useSafeArea ? SafeArea(child: content) : content;

    if (scrollable) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(child: safe),
      );
    }
    return Scaffold(backgroundColor: Colors.black, body: safe);
  }
}
