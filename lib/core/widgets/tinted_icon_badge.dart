import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import 'app_icon.dart';

/// Rounded square with a soft [color] tint and the icon in that color.
class TintedIconBadge extends StatelessWidget {
  final AppIconData icon;
  final Color color;
  final double size;

  const TintedIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(size * 0.3),
    ),
    child: AppIcon(icon, color: color, size: size * 0.5),
  );
}
