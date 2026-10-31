import 'package:flutter/material.dart';

/// Large rounded gradient card at the top of a details page.
class GradientHeaderCard extends StatelessWidget {
  final List<Color> colors;
  final Widget child;

  const GradientHeaderCard({
    super.key,
    required this.colors,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: colors,
        ),
      ),
      child: child,
    ),
  );
}
