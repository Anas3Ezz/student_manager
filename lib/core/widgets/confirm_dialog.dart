import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

abstract final class ConfirmDialog {
  /// Returns true only when the user confirms.
  static Future<bool> show(
    BuildContext context, {
    required String titleKey,
    required String messageKey,
    String confirmKey = 'common.delete',
    bool destructive = true,
  }) async {
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.tr(titleKey)),
        content: Text(dialogContext.tr(messageKey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.tr('common.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: destructive
                ? TextButton.styleFrom(foregroundColor: scheme.error)
                : null,
            child: Text(dialogContext.tr(confirmKey)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
