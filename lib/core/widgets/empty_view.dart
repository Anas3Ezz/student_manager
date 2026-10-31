import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import 'app_icon.dart';

class EmptyView extends StatelessWidget {
  final AppIconData icon;
  final String messageKey;
  final String? actionKey;
  final VoidCallback? onAction;

  /// Smaller variant for use inside a section rather than a whole page.
  final bool compact;

  const EmptyView({
    super.key,
    required this.icon,
    required this.messageKey,
    this.actionKey,
    this.onAction,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final badge = compact ? 56.0 : 88.0;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 20 : 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: badge,
              height: badge,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primaryContainer.withValues(alpha: 0.6),
              ),
              child: Center(
                child: AppIcon(icon, size: badge * 0.42, color: scheme.primary),
              ),
            ),
            SizedBox(height: compact ? 12 : 20),
            Text(
              context.tr(messageKey),
              textAlign: TextAlign.center,
              style:
                  (compact
                          ? theme.textTheme.bodyMedium
                          : theme.textTheme.bodyLarge)
                      ?.copyWith(color: scheme.onSurfaceVariant, height: 1.5),
            ),
            if (actionKey != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(context.tr(actionKey!)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
