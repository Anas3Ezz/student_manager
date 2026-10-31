import 'package:flutter/material.dart';

import '../error/failure_message.dart';
import '../error/failures.dart';
import '../theme/app_icons.dart';
import 'empty_view.dart';

class ErrorView extends StatelessWidget {
  final Failure failure;
  const ErrorView({super.key, required this.failure});

  @override
  Widget build(BuildContext context) =>
      EmptyView(icon: AppIcons.error, messageKey: failure.messageKey);
}
