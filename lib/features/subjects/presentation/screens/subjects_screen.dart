import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/bloc/list_state.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/subject_colors.dart';
import '../../../../core/utils/snackbars.dart';
import '../../../../core/widgets/app_fab.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/list_state_sliver.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/tinted_icon_badge.dart';
import '../../domain/entities/subject_entity.dart';
import '../bloc/subjects_cubit.dart';
import '../widgets/subject_dialog.dart';

enum _SubjectAction { edit, delete }

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  Future<void> _add(BuildContext context) async {
    final cubit = context.read<SubjectsCubit>();
    final result = await showSubjectDialog(context);
    if (result == null) return;
    final failure = await cubit.add(
      name: result.name,
      colorValue: result.colorValue,
    );
    if (failure != null && context.mounted) context.showFailure(failure);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: AppFab(
        onPressed: () => _add(context),
        icon: AppIcons.add,
        label: context.tr('subjects.add'),
      ),
      body: CustomScrollView(
        slivers: [
          const PageHeader(titleKey: 'subjects.title'),
          BlocBuilder<SubjectsCubit, ListState<SubjectEntity>>(
            builder: (context, state) => ListStateSliver(
              state: state,
              fillRemaining: true,
              empty: const EmptyView(
                icon: AppIcons.subjects,
                messageKey: 'subjects.empty',
              ),
              builder: (items) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 112),
                sliver: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 240,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    // Room for the icon row plus a 2-line name at any text size.
                    mainAxisExtent:
                        84 + MediaQuery.textScalerOf(context).scale(48),
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) =>
                      _SubjectCard(subject: items[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final SubjectEntity subject;
  const _SubjectCard({required this.subject});

  Future<void> _onAction(BuildContext context, _SubjectAction action) async {
    final cubit = context.read<SubjectsCubit>();
    switch (action) {
      case _SubjectAction.edit:
        final result = await showSubjectDialog(context, subject: subject);
        if (result == null) return;
        final failure = await cubit.update(
          SubjectEntity(
            id: subject.id,
            name: result.name,
            colorValue: result.colorValue,
          ),
        );
        if (failure != null && context.mounted) context.showFailure(failure);
      case _SubjectAction.delete:
        final confirmed = await ConfirmDialog.show(
          context,
          titleKey: 'subjects.delete_title',
          messageKey: 'subjects.delete_message',
        );
        if (!confirmed) return;
        final failure = await cubit.delete(subject.id);
        if (!context.mounted) return;
        failure == null
            ? context.showMessage('subjects.deleted')
            : context.showFailure(failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = SubjectColors.resolve(subject.colorValue, theme.colorScheme);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            context.push(AppRoutes.subject(subject.id), extra: subject),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                color.withValues(alpha: 0.14),
                color.withValues(alpha: 0.03),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 4, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TintedIconBadge(icon: AppIcons.subjects, color: color),
                    const Spacer(),
                    PopupMenuButton<_SubjectAction>(
                      icon: AppIcon(
                        AppIcons.more,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onSelected: (action) => _onAction(context, action),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: _SubjectAction.edit,
                          child: Text(context.tr('common.edit')),
                        ),
                        PopupMenuItem(
                          value: _SubjectAction.delete,
                          child: Text(context.tr('common.delete')),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  subject.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
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
