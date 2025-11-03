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
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _RoundButton(
              assetPath: 'lib/assets/images/home.png',
              label: ' ',
              selected: selectedIndex == 0,
              onTap: () => onTap?.call(0),
            ),
            _RoundButton(
              assetPath: 'lib/assets/images/chat.png',
              label: ' ',
              selected: selectedIndex == 1,
              onTap: () => onTap?.call(1),
            ),
            _RoundButton(
              assetPath: 'lib/assets/images/stars.png',
              label: ' ',
              selected: selectedIndex == 2,
              onTap: () => onTap?.call(2),
            ),
            _RoundButton(
              assetPath: 'lib/assets/images/config.png',
              label: ' ',
              selected: selectedIndex == 3,
              onTap: () => onTap?.call(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatefulWidget {
  final String assetPath;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _RoundButton({
    required this.assetPath,
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  State<_RoundButton> createState() => _RoundButtonState();
}

class _RoundButtonState extends State<_RoundButton>
    with SingleTickerProviderStateMixin {
  static const purple = UserNavbar._purple;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
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
          child: AnimatedScale(
            scale: _pressed ? 0.88 : 1.0,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutBack,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: purple,
                boxShadow: [
                  BoxShadow(
                    color: purple.withOpacity(0.45),
                    blurRadius: 14,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  widget.assetPath,
                  width: 30,
                  height: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 12,
            color: widget.selected ? purple : Colors.black.withOpacity(0.55),
            fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
