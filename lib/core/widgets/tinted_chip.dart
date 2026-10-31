import 'package:flutter/material.dart';

import '../theme/subject_colors.dart';
import 'color_dot.dart';

/// A small read-only pill tinted with [color], e.g. a subject tag.
class TintedChip extends StatelessWidget {
  final String label;
  final Color color;

  const TintedChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorDot(color: color, size: 7),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: SubjectColors.foreground(color, brightness),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
