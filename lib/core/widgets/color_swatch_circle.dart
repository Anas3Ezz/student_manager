import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import 'app_icon.dart';

/// A selectable color circle with an animated ring and check mark.
/// Visual only — wrap it in a tappable widget.
class ColorSwatchCircle extends StatelessWidget {
  final Color color;
  final bool selected;
  final double size;

  const ColorSwatchCircle({
    super.key,
    required this.color,
    required this.selected,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 220),
    curve: Curves.easeOut,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: selected ? color : Colors.transparent,
        width: 2.5,
      ),
    ),
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(color, Colors.white, 0.25)!, color],
        ),
      ),
      child: AnimatedScale(
        scale: selected ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: AppIcon(AppIcons.check, color: Colors.white, size: size * 0.55),
      ),
    ),
  );
}
