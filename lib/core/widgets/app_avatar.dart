import 'package:flutter/material.dart';

import '../theme/subject_colors.dart';

/// Initials on a soft tint. The color is stable per name.
class AppAvatar extends StatelessWidget {
  final String name;
  final double size;

  const AppAvatar({super.key, required this.name, this.size = 44});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    // ZWNJ keeps Arabic initials as separate letters instead of joining them.
    return parts
        .take(2)
        .map((p) => p.characters.first.toUpperCase())
        .join('\u200C');
  }

  @override
  Widget build(BuildContext context) {
    final color = SubjectColors.forKey(name);
    final brightness = Theme.of(context).brightness;
    // Decorative: the name is always shown next to it.
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        padding: EdgeInsets.all(size * 0.18),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              color.withValues(alpha: 0.22),
              color.withValues(alpha: 0.10),
            ],
          ),
        ),
        // Scales down instead of wrapping at large system text sizes.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _initials,
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              color: SubjectColors.foreground(color, brightness),
              fontWeight: FontWeight.w700,
              fontSize: size * 0.36,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
