import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/subject_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../../../core/widgets/tinted_chip.dart';
import '../../domain/entities/session_entity.dart';

/// One session card. Tap to edit, swipe to delete.
class SessionTile extends StatelessWidget {
  final SessionEntity session;

  /// Shows the student's name instead of the subject (used on subject pages).
  final bool showStudentName;
  final VoidCallback onTap;
  final Future<bool> Function() onDelete;

  const SessionTile({
    super.key,
    required this.session,
    required this.onTap,
    required this.onDelete,
    this.showStudentName = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final notes = session.notes;
    final accent = SubjectColors.resolve(session.subjectColorValue, scheme);
    return Dismissible(
      key: ValueKey('session-${session.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => onDelete(),
      background: const _DeleteBackground(),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DateBadge(date: session.date, color: accent),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: showStudentName
                                  ? Text(
                                      session.studentName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall,
                                    )
                                  : TintedChip(
                                      label: session.subjectName,
                                      color: accent,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          StarRating(rating: session.rating, size: 16),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notes ?? context.tr('session.no_notes'),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final DateTime date;
  final Color color;

  const _DateBadge({required this.date, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final locale = context.locale;
    final foreground = SubjectColors.foreground(color, theme.brightness);
    // Scales down rather than wrapping: Arabic weekdays are full names.
    Widget fit(Widget child) => FittedBox(fit: BoxFit.scaleDown, child: child);
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          fit(
            Text(
              AppDateFormat.dayNumber(date, locale),
              maxLines: 1,
              style: text.titleLarge?.copyWith(color: foreground, height: 1.1),
            ),
          ),
          fit(
            Text(
              AppDateFormat.weekdayShort(date, locale),
              maxLines: 1,
              style: text.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsetsDirectional.only(end: 24),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: AppIcon(AppIcons.delete, color: scheme.onErrorContainer),
    );
  }
}
