import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme/app_icons.dart';

/// Renders an [AppIcons] glyph. Color and size follow the surrounding
/// [IconTheme] (so buttons, nav bars and disabled states just work).
class AppIcon extends StatelessWidget {
  static const double defaultStrokeWidth = 1.8;

  final AppIconData icon;
  final double? size;
  final Color? color;
  final double strokeWidth;

  /// Flip horizontally in RTL — for arrows and chevrons.
  final bool mirrorInRtl;

  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.strokeWidth = defaultStrokeWidth,
    this.mirrorInRtl = false,
  });

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? IconTheme.of(context).size ?? 22;
    // Like Icon: keep the glyph at its size even when the slot imposes a
    // larger minimum (e.g. 48px text-field icon slots), instead of stretching.
    final glyph = SizedBox.square(
      dimension: dimension,
      child: Center(
        child: HugeIcon(
          icon: icon,
          size: dimension,
          color: color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return mirrorInRtl && rtl
        ? Transform.flip(flipX: true, child: glyph)
        : glyph;
  }
}
