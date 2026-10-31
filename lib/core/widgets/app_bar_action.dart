import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import 'app_icon.dart';

/// Soft circular app-bar button: card surface with a hairline border.
/// [destructive] tints it with the error color (e.g. delete).
class AppBarAction extends StatelessWidget {
  final AppIconData icon;

  /// Flip in RTL (arrows).
  final bool mirrorInRtl;
  final String tooltip;
  final VoidCallback onPressed;
  final bool destructive;

  const AppBarAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.destructive = false,
    this.mirrorInRtl = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = destructive ? scheme.error : scheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: AppIcon(icon, size: 20, mirrorInRtl: mirrorInRtl),
        style: IconButton.styleFrom(
          fixedSize: const Size.square(42),
          foregroundColor: foreground,
          backgroundColor: destructive
              ? scheme.errorContainer.withValues(alpha: 0.45)
              : theme.cardTheme.color,
          side: BorderSide(
            color: destructive
                ? scheme.error.withValues(alpha: 0.25)
                : scheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

/// Back button matching [AppBarAction]; the arrow mirrors in RTL.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: AppBarAction(
      icon: AppIcons.back,
      mirrorInRtl: true,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () => Navigator.of(context).maybePop(),
    ),
  );
}
