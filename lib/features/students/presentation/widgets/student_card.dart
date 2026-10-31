import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../domain/entities/student_entity.dart';

class StudentCard extends StatelessWidget {
  final StudentEntity student;
  final VoidCallback onTap;

  /// Shows the quick "log session" button when provided.
  final VoidCallback? onLogSession;

  const StudentCard({
    super.key,
    required this.student,
    required this.onTap,
    this.onLogSession,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phone = student.phone;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 12, 14),
          child: Row(
            children: [
              AppAvatar(name: student.name, size: 48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (phone != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '\u200E$phone',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onLogSession != null)
                FilledButton.tonalIcon(
                  onPressed: onLogSession,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const AppIcon(AppIcons.add, size: 20),
                  label: Text(context.tr('session.log_short')),
                )
              else
                AppIcon(
                  AppIcons.next,
                  mirrorInRtl: true,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
