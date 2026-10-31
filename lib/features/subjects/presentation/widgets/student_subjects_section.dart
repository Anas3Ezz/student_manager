import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/bloc/list_state.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/subject_colors.dart';
import '../../../../core/utils/snackbars.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/tinted_chip.dart';
import '../../domain/entities/subject_entity.dart';
import '../bloc/student_subjects_cubit.dart';
import '../bloc/subjects_cubit.dart';

/// The student's subjects as chips, with a "Manage" sheet to change them.
class StudentSubjectsSection extends StatelessWidget {
  const StudentSubjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          titleKey: 'subjects.student_subjects',
          trailing: TextButton.icon(
            onPressed: () => _showManageSheet(context),
            icon: const AppIcon(AppIcons.manage, size: 18),
            label: Text(context.tr('subjects.manage')),
          ),
        ),
        BlocBuilder<StudentSubjectsCubit, ListState<SubjectEntity>>(
          builder: (context, state) => switch (state) {
            ListLoading() => const SizedBox(height: 40),
            ListError(:final failure) => ErrorView(failure: failure),
            ListLoaded(items: []) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                context.tr('subjects.no_student_subjects'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ListLoaded(:final items) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [for (final s in items) _SubjectChip(subject: s)],
              ),
            ),
          },
        ),
      ],
    );
  }

  void _showManageSheet(BuildContext context) {
    final studentSubjects = context.read<StudentSubjectsCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: studentSubjects),
          BlocProvider(create: (_) => getIt<SubjectsCubit>()..watch()),
        ],
        child: const _ManageSubjectsSheet(),
      ),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  final SubjectEntity subject;
  const _SubjectChip({required this.subject});

  @override
  Widget build(BuildContext context) => TintedChip(
    label: subject.name,
    color: SubjectColors.resolve(
      subject.colorValue,
      Theme.of(context).colorScheme,
    ),
  );
}

class _ManageSubjectsSheet extends StatelessWidget {
  const _ManageSubjectsSheet();

  Future<void> _toggle(BuildContext context, int subjectId, bool assign) async {
    final cubit = context.read<StudentSubjectsCubit>();
    final failure = assign
        ? await cubit.assign(subjectId)
        : await cubit.unassign(subjectId);
    if (failure != null && context.mounted) context.showFailure(failure);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr('subjects.pick_title'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: BlocBuilder<SubjectsCubit, ListState<SubjectEntity>>(
                builder: (context, allState) => switch (allState) {
                  ListLoading() => const LoadingView(),
                  ListError(:final failure) => ErrorView(failure: failure),
                  ListLoaded(items: []) => EmptyView(
                    icon: AppIcons.subjects,
                    messageKey: 'subjects.none_created',
                    actionKey: 'subjects.go_to_subjects',
                    onAction: () {
                      Navigator.of(context).pop();
                      context.go(AppRoutes.subjects);
                    },
                  ),
                  ListLoaded(items: final all) =>
                    BlocSelector<
                      StudentSubjectsCubit,
                      ListState<SubjectEntity>,
                      Set<int>
                    >(
                      selector: (state) => switch (state) {
                        ListLoaded(:final items) => {
                          for (final s in items) s.id,
                        },
                        _ => const {},
                      },
                      builder: (context, assignedIds) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final subject in all)
                            FilterChip(
                              label: Text(subject.name),
                              selected: assignedIds.contains(subject.id),
                              onSelected: (selected) =>
                                  _toggle(context, subject.id, selected),
                            ),
                        ],
                      ),
                    ),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
