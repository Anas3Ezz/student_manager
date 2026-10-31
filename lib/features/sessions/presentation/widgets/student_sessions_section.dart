import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/list_state.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/list_state_sliver.dart';
import '../../../subjects/domain/entities/subject_entity.dart';
import '../../../subjects/presentation/bloc/student_subjects_cubit.dart';
import '../../domain/entities/session_entity.dart';
import '../bloc/monthly_sessions_cubit.dart';
import '../bloc/monthly_sessions_state.dart';
import 'confirm_delete_session.dart';
import 'month_navigator.dart';
import 'session_form_sheet.dart';
import 'session_tile.dart';

/// Sliver: month navigator, subject filter and that month's sessions.
class StudentSessionsSection extends StatelessWidget {
  const StudentSessionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<StudentSubjectsCubit, ListState<SubjectEntity>>(
      listener: (context, state) {
        if (state is ListLoaded<SubjectEntity>) {
          context.read<MonthlySessionsCubit>().onAssignedSubjectsChanged(
            state.items.map((s) => s.id).toList(),
          );
        }
      },
      child: SliverMainAxisGroup(
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: MonthNavigator()),
          ),
          const SliverToBoxAdapter(child: _SubjectFilter()),
          BlocBuilder<MonthlySessionsCubit, MonthlySessionsState>(
            builder: (context, state) => switch (state) {
              // Local queries are near-instant; a blank gap avoids a spinner flash.
              MonthlySessionsLoading() => const SliverToBoxAdapter(
                child: SizedBox(height: 160),
              ),
              MonthlySessionsError(:final failure) => SliverToBoxAdapter(
                child: ErrorView(failure: failure),
              ),
              MonthlySessionsLoaded(sessions: []) => const SliverToBoxAdapter(
                child: EmptyView(
                  icon: AppIcons.calendar,
                  messageKey: 'session.empty_month',
                  compact: true,
                ),
              ),
              MonthlySessionsLoaded(:final sessions) => CardSliverList(
                itemCount: sessions.length,
                itemBuilder: (context, index) =>
                    _StudentSessionTile(session: sessions[index]),
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _StudentSessionTile extends StatelessWidget {
  final SessionEntity session;
  const _StudentSessionTile({required this.session});

  @override
  Widget build(BuildContext context) => SessionTile(
    session: session,
    onTap: () => showSessionFormSheetFor(context, session),
    onDelete: () {
      final cubit = context.read<MonthlySessionsCubit>();
      return confirmAndDeleteSession(
        context,
        () => cubit.deleteSession(session.id),
      );
    },
  );
}

/// Subject filter chips, shown only when the student has 2+ subjects.
class _SubjectFilter extends StatelessWidget {
  const _SubjectFilter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentSubjectsCubit, ListState<SubjectEntity>>(
      builder: (context, subjectsState) {
        final subjects = switch (subjectsState) {
          ListLoaded(:final items) => items,
          _ => const <SubjectEntity>[],
        };
        if (subjects.length < 2) return const SizedBox(height: 12);
        return BlocSelector<MonthlySessionsCubit, MonthlySessionsState, int?>(
          selector: (state) => state.subjectId,
          builder: (context, selectedId) {
            final cubit = context.read<MonthlySessionsCubit>();
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(context.tr('common.all')),
                    selected: selectedId == null,
                    onSelected: (_) => cubit.filterBySubject(null),
                  ),
                  for (final subject in subjects)
                    ChoiceChip(
                      label: Text(subject.name),
                      selected: selectedId == subject.id,
                      onSelected: (_) => cubit.filterBySubject(subject.id),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
