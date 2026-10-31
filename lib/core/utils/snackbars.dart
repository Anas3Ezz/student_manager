import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../error/failure_message.dart';
import '../error/failures.dart';

extension SnackbarX on BuildContext {
  void showMessage(String key) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(tr(key))));
  }

  void showFailure(Failure failure) => showMessage(failure.messageKey);
}
