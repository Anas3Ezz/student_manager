import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_icon.dart';
import '../bloc/monthly_sessions_cubit.dart';
import '../bloc/monthly_sessions_state.dart';

/// ‹ October 2026 › with the number of sessions in that month.
class MonthNavigator extends StatelessWidget {
  const MonthNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MonthlySessionsCubit>();
    final theme = Theme.of(context);
    return BlocBuilder<MonthlySessionsCubit, MonthlySessionsState>(
      builder: (context, state) {
        final count = switch (state) {
          MonthlySessionsLoaded(:final sessions) => sessions.length,
          _ => null,
        };
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton.filledTonal(
                  tooltip: context.tr('session.previous_month'),
                  onPressed: cubit.previousMonth,
                  icon: const AppIcon(AppIcons.previous, mirrorInRtl: true),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        AppDateFormat.monthYear(state.month, context.locale),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      AnimatedOpacity(
                        // Hidden for an empty month: the empty state below already says so.
                        opacity: (count ?? 0) == 0 ? 0 : 1,
                        duration: const Duration(milliseconds: 150),
                        child: Text(
                          context.plural('session.count', count ?? 0),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: context.tr('session.next_month'),
                  onPressed: state.canGoNext ? cubit.nextMonth : null,
                  icon: const AppIcon(AppIcons.next, mirrorInRtl: true),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
