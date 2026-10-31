import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/bloc/list_state.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_fab.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/list_state_sliver.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../sessions/presentation/widgets/session_form_sheet.dart';
import '../../domain/entities/student_entity.dart';
import '../bloc/students_cubit.dart';
import '../widgets/student_card.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: AppFab(
        onPressed: () => context.push(AppRoutes.newStudent),
        icon: AppIcons.addStudent,
        label: context.tr('students.add'),
      ),
      body: CustomScrollView(
        slivers: [
          const PageHeader(titleKey: 'students.title'),
          const SliverToBoxAdapter(child: _SearchField()),
          const _StudentsSliver(),
        ],
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField();

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SearchBar(
        controller: _controller,
        hintText: context.tr('students.search_hint'),
        leading: const AppIcon(AppIcons.search),
        onChanged: context.read<StudentsCubit>().search,
        trailing: [
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const AppIcon(AppIcons.clear),
                    onPressed: () {
                      _controller.clear();
                      context.read<StudentsCubit>().search('');
                    },
                  ),
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
    return BlocBuilder<StudentsCubit, ListState<StudentEntity>>(
      builder: (context, state) => ListStateSliver(
        state: state,
        fillRemaining: true,
        empty: EmptyView(
          icon: AppIcons.students,
          messageKey: context.read<StudentsCubit>().hasQuery
              ? 'students.no_results'
              : 'students.empty',
        ),
        builder: (items) => SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 10),
                child: Text(
                  context.plural('students.count', items.length),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            CardSliverList(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 112),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final student = items[index];
                return StudentCard(
                  student: student,
                  onTap: () => context.push(AppRoutes.student(student.id)),
                  onLogSession: () => showSessionFormSheet(
                    context,
                    studentId: student.id,
                    studentName: student.name,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
