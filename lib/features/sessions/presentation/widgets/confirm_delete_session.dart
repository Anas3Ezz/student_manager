import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/snackbars.dart';
import '../../../../core/widgets/confirm_dialog.dart';

/// Asks for confirmation, runs [delete], and reports the outcome.
///
/// Always returns false for `Dismissible.confirmDismiss`: the list stream
/// removes the tile itself, so Dismissible must not remove it too.
Future<bool> confirmAndDeleteSession(
  BuildContext context,
  Future<Failure?> Function() delete,
) async {
  final confirmed = await ConfirmDialog.show(
    context,
    titleKey: 'session.delete_title',
    messageKey: 'session.delete_message',
  );
  if (!confirmed) return false;
  final failure = await delete();
  if (context.mounted) {
    failure == null
        ? context.showMessage('session.deleted')
        : context.showFailure(failure);
  }
  return false;
}
