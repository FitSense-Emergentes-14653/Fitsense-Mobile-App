import 'package:flutter/material.dart';

class UserNavbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onTap;

  const UserNavbar({
    super.key,
    this.selectedIndex = 0,
    this.onTap,
  });

  static const _purple = Color(0xFF8A5CF6);
  static const double kHeight = 120;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final maxWidth =
            constraints.maxWidth > 1200 ? 1200.0 : constraints.maxWidth;

        return SafeArea(
          top: false,
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              margin: EdgeInsets.symmetric(
                horizontal: isWide ? 32.0 : 16.0,
                vertical: isWide ? 16.0 : 12.0,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 24.0 : 12.0,
                vertical: isWide ? 16.0 : 12.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _RoundButton(
                      assetPath: 'lib/assets/images/home.png',
                      label: 'Inicio',
                      selected: selectedIndex == 0,
                      onTap: () => onTap?.call(0),
                      isWide: isWide,
                    ),
                  ),
                  SizedBox(width: isWide ? 12.0 : 6.0),
                  Expanded(
                    child: _RoundButton(
                      icon: Icons.assessment_rounded,
                      label: 'Métricas',
                      selected: selectedIndex == 1,
                      onTap: () => onTap?.call(1),
                      isWide: isWide,
                    ),
                  ),
                  SizedBox(width: isWide ? 12.0 : 6.0),
                  Expanded(
                    child: _RoundButton(
                      assetPath: 'lib/assets/images/chat.png',
                      label: 'Rutinas',
                      selected: selectedIndex == 2,
                      onTap: () => onTap?.call(2),
                      isWide: isWide,
                    ),
                  ),
                  SizedBox(width: isWide ? 12.0 : 6.0),
                  Expanded(
                    child: _RoundButton(
                      assetPath: 'lib/assets/images/stars.png',
                      label: 'Progreso',
                      selected: selectedIndex == 3,
                      onTap: () => onTap?.call(3),
                      isWide: isWide,
                    ),
                  ),
                  SizedBox(width: isWide ? 12.0 : 6.0),
                  Expanded(
                    child: _RoundButton(
                      assetPath: 'lib/assets/images/config.png',
                      label: 'Config',
                      selected: selectedIndex == 4,
                      onTap: () => onTap?.call(4),
                      isWide: isWide,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RoundButton extends StatefulWidget {
  final String? assetPath;
  final IconData? icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool isWide;

  const _RoundButton({
    this.assetPath,
    this.icon,
    required this.label,
    required this.selected,
    this.onTap,
    this.isWide = false,
  }) : assert(assetPath != null || icon != null, 'Either assetPath or icon must be provided');

  @override
  State<_RoundButton> createState() => _RoundButtonState();
}

class _RoundButtonState extends State<_RoundButton>
    with SingleTickerProviderStateMixin {
  static const purple = UserNavbar._purple;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.selected;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) async {
            await Future.delayed(const Duration(milliseconds: 80));
            setState(() => _pressed = false);
            widget.onTap?.call();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Indicador de selección (anillo exterior)
                if (isSelected)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFCCF24D),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCCF24D).withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),

                // Botón principal
                AnimatedScale(
                  scale: _pressed ? 0.85 : 1.0,
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOutBack,
                  child: Container(
                    width: widget.isWide ? 58 : 56,
                    height: widget.isWide ? 58 : 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF8A5CF6),
                                Color(0xFFA78BFA),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [
                                purple.withValues(alpha: 0.7),
                                purple.withValues(alpha: 0.5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? purple.withValues(alpha: 0.5)
                              : purple.withValues(alpha: 0.25),
                          blurRadius: isSelected ? 16 : 10,
                          spreadRadius: isSelected ? 2 : 0,
                          offset: Offset(0, isSelected ? 6 : 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: widget.assetPath != null
                          ? Image.asset(
                              widget.assetPath!,
                              width: isSelected ? 32 : 28,
                              height: isSelected ? 32 : 28,
                              color: Colors.white,
                            )
                          : Icon(
                              widget.icon!,
                              size: isSelected ? 32 : 28,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),

                // Punto indicador superior (cuando está seleccionado)
                if (isSelected)
                  Positioned(
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFCCF24D),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFCCF24D).withValues(alpha: 0.6),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(
            fontSize: widget.isWide ? 13 : 11,
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.6),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: 0.3,
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
