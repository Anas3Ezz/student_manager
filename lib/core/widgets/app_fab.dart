import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import 'app_icon.dart';

/// Extended FAB for the main tabs.
///
/// The bottom-nav shell keeps every tab alive, so several FABs exist at once.
/// With the default hero tag they collide when a page is pushed above the
/// tabs ("multiple heroes share the same tag"), so hero animation is disabled.
class AppFab extends StatelessWidget {
  final AppIconData icon;
  final String label;
  final VoidCallback onPressed;

  const AppFab({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
    heroTag: null,
    onPressed: onPressed,
    icon: AppIcon(icon, size: 22),
    label: Text(label),
  );
}
