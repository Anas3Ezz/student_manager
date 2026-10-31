import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_icon.dart';

/// Bottom navigation between the three main tabs.
class HomeShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const HomeShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant
                  .withValues(alpha: 0.5),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          destinations: [
            NavigationDestination(
              icon: const AppIcon(AppIcons.students),
              selectedIcon: const AppIcon(AppIcons.students, strokeWidth: 2.3),
              label: context.tr('nav.students'),
            ),
            NavigationDestination(
              icon: const AppIcon(AppIcons.subjects),
              selectedIcon: const AppIcon(AppIcons.subjects, strokeWidth: 2.3),
              label: context.tr('nav.subjects'),
            ),
            NavigationDestination(
              icon: const AppIcon(AppIcons.settings),
              selectedIcon: const AppIcon(AppIcons.settings, strokeWidth: 2.3),
              label: context.tr('nav.settings'),
            ),
          ],
        ),
      ),
    );
  }
}
