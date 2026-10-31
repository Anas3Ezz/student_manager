import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Compact pinned page title for the main tabs.
class PageHeader extends StatelessWidget {
  final String titleKey;
  const PageHeader({super.key, required this.titleKey});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      toolbarHeight: 64,
      titleSpacing: 20,
      title: Text(
        context.tr(titleKey),
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
