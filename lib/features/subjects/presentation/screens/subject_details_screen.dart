import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/bloc/list_state.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/subject_colors.dart';
import '../../../../core/widgets/app_bar_action.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/gradient_header_card.dart';
import '../../../../core/widgets/list_state_sliver.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/tinted_icon_badge.dart';
import '../../../sessions/domain/entities/session_entity.dart';
import '../../../sessions/presentation/bloc/subject_sessions_cubit.dart';
import '../../../sessions/presentation/widgets/confirm_delete_session.dart';
import '../../../sessions/presentation/widgets/session_form_sheet.dart';
import '../../../sessions/presentation/widgets/session_tile.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../../students/presentation/bloc/subject_students_cubit.dart';
import '../../../students/presentation/widgets/student_card.dart';
import '../../domain/entities/subject_entity.dart';

/// Students enrolled in a subject and its most recent sessions.
class SubjectDetailsScreen extends StatelessWidget {
  final SubjectEntity subject;
  const SubjectDetailsScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const AppBackButton(), leadingWidth: 64),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _SubjectHeader(subject: subject)),
          const SliverToBoxAdapter(
            child: SectionHeader(titleKey: 'subjects.students_section'),
          ),
          const _StudentsSliver(),
          const SliverToBoxAdapter(
            child: SectionHeader(titleKey: 'subjects.recent_sessions'),
          ),
          const _SessionsSliver(),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _SubjectHeader extends StatelessWidget {
  final SubjectEntity subject;
  const _SubjectHeader({required this.subject});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = SubjectColors.resolve(subject.colorValue, theme.colorScheme);
    return GradientHeaderCard(
      colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.06)],
      child: Row(
        children: [
          TintedIconBadge(icon: AppIcons.subjects, color: color, size: 60),
          const SizedBox(width: 16),
          Expanded(
            child: Text(subject.name, style: theme.textTheme.headlineSmall),
          ),
        ],
      ),
    );
  }
}

class _StudentsSliver extends StatelessWidget {
  const _StudentsSliver();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubjectStudentsCubit, ListState<StudentEntity>>(
      builder: (context, state) => ListStateSliver(
        state: state,
        empty: const EmptyView(
          icon: AppIcons.students,
          messageKey: 'subjects.no_students',
          compact: true,
        ),
        builder: (items) => CardSliverList(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final student = items[index];
            return StudentCard(
              student: student,
              onTap: () => context.push(AppRoutes.student(student.id)),
            );
          },
        ),
      ),
    );
  }
}

class _SessionsSliver extends StatelessWidget {
  const _SessionsSliver();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubjectSessionsCubit, ListState<SessionEntity>>(
      builder: (context, state) => ListStateSliver(
        state: state,
        empty: const EmptyView(
          icon: AppIcons.calendar,
          messageKey: 'subjects.no_sessions',
          compact: true,
        ),
        builder: (items) => CardSliverList(
          itemCount: items.length,
          itemBuilder: (context, index) =>
              _SubjectSessionTile(session: items[index]),
        ),
      ),
    );
  }
}

class _SubjectSessionTile extends StatelessWidget {
  final SessionEntity session;
  const _SubjectSessionTile({required this.session});

  @override
  Widget build(BuildContext context) => SessionTile(
    session: session,
    showStudentName: true,
    onTap: () => showSessionFormSheetFor(context, session),
    onDelete: () {
      final cubit = context.read<SubjectSessionsCubit>();
      return confirmAndDeleteSession(
        context,
        () => cubit.deleteSession(session.id),
      );
    },
  );
}
