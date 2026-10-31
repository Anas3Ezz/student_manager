import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../validation/validators.dart';

/// Shows 1–5 stars. Interactive when [onChanged] is provided.
class StarRating extends StatelessWidget {
  static const Color starColor = Color(0xFFF5A524);

  final int rating;
  final double size;
  final ValueChanged<int>? onChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 18,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final stars = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= Validators.maxRating; i++)
          _Star(
            value: i,
            filled: i <= rating,
            size: size,
            color: i <= rating ? starColor : outline,
            onTap: onChanged == null ? null : () => onChanged!(i),
          ),
      ],
    );
    // Read-only: announce the rating once. Interactive: each star speaks.
    if (onChanged != null) return stars;
    return Semantics(
      label: context.tr('session.rating_value', args: ['$rating']),
      excludeSemantics: true,
      child: stars,
    );
  }
}

class _Star extends StatelessWidget {
  final int value;
  final bool filled;
  final double size;
  final Color color;
  final VoidCallback? onTap;

  const _Star({
    required this.value,
    required this.filled,
    required this.size,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      filled ? Icons.star_rounded : Icons.star_outline_rounded,
      size: size,
      color: color,
    );
    if (onTap == null) return icon;
    return Semantics(
      button: true,
      selected: filled,
      label: context.tr('session.rating_value', args: ['$value']),
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: size * 0.7,
        child: Padding(
          padding: const EdgeInsets.all(4),
          // A small pop when a star becomes selected.
          child: AnimatedScale(
            scale: filled ? 1.0 : 0.88,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            child: icon,
          ),
        ),
      ),
    );
  }
}
