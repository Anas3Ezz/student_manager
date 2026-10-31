import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/utils/snackbars.dart';
import '../../../../core/widgets/app_bar_action.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../sessions/presentation/widgets/session_form_sheet.dart';
import '../../../sessions/presentation/widgets/student_sessions_section.dart';
import '../../../subjects/presentation/widgets/student_subjects_section.dart';
import '../bloc/student_details_cubit.dart';
import '../bloc/student_details_state.dart';
import '../widgets/student_header.dart';

class StudentDetailsScreen extends StatelessWidget {
  final int studentId;
  const StudentDetailsScreen({super.key, required this.studentId});

  Future<void> _delete(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      titleKey: 'students.delete_title',
      messageKey: 'students.delete_message',
    );
    if (!confirmed || !context.mounted) return;
    final failure = await context.read<StudentDetailsCubit>().delete();
    if (!context.mounted) return;
    if (failure != null) return context.showFailure(failure);
    context.showMessage('students.deleted');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentDetailsCubit, StudentDetailsState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType ||
          current is StudentDetailsLoaded,
      builder: (context, state) => switch (state) {
        StudentDetailsLoading() => const Scaffold(body: LoadingView()),
        StudentDetailsError(:final failure) => Scaffold(
          appBar: AppBar(leading: const AppBackButton(), leadingWidth: 64),
          body: ErrorView(failure: failure),
        ),
        StudentDetailsLoaded(:final student) => Scaffold(
          appBar: AppBar(
            leading: const AppBackButton(),
            leadingWidth: 64,
            actions: [
              AppBarAction(
                icon: AppIcons.edit,
                tooltip: context.tr('common.edit'),
                onPressed: () => context.push(
                  AppRoutes.editStudent(student.id),
                  extra: student,
                ),
              ),
              AppBarAction(
                icon: AppIcons.delete,
                tooltip: context.tr('common.delete'),
                destructive: true,
                onPressed: () => _delete(context),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: StudentHeader(student: student)),
              const SliverToBoxAdapter(child: StudentSubjectsSection()),
              const SliverToBoxAdapter(
                child: SectionHeader(titleKey: 'session.history'),
              ),
              const StudentSessionsSection(),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
          bottomNavigationBar: _BottomBar(studentId: student.id),
        ),
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int studentId;
  const _BottomBar({required this.studentId});

  @override
  Widget build(BuildContext context) => BottomActionBar(
    // Always enabled: with no subjects, the sheet lets the teacher
    // assign or create one first.
    child: FilledButton.icon(
      onPressed: () => showSessionFormSheet(context, studentId: studentId),
      icon: const AppIcon(AppIcons.logSession),
      label: Text(context.tr('session.log')),
    ),
  );
}
