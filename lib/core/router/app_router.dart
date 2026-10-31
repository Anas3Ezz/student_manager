import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/screens/home_shell.dart';
import '../../features/sessions/presentation/bloc/monthly_sessions_cubit.dart';
import '../../features/sessions/presentation/bloc/subject_sessions_cubit.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/students/domain/entities/student_entity.dart';
import '../../features/students/presentation/bloc/student_details_cubit.dart';
import '../../features/students/presentation/bloc/student_form_cubit.dart';
import '../../features/students/presentation/bloc/students_cubit.dart';
import '../../features/students/presentation/bloc/subject_students_cubit.dart';
import '../../features/students/presentation/screens/student_details_screen.dart';
import '../../features/students/presentation/screens/student_form_screen.dart';
import '../../features/students/presentation/screens/students_screen.dart';
import '../../features/subjects/domain/entities/subject_entity.dart';
import '../../features/subjects/presentation/bloc/student_subjects_cubit.dart';
import '../../features/subjects/presentation/bloc/subjects_cubit.dart';
import '../../features/subjects/presentation/screens/subject_details_screen.dart';
import '../../features/subjects/presentation/screens/subjects_screen.dart';
import '../di/injection.dart';
import 'routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Detail and form pages open above the bottom navigation.
final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.students,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => HomeShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.students,
              builder: (_, _) => BlocProvider(
                create: (_) => getIt<StudentsCubit>()..watch(),
                child: const StudentsScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'new',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (_, _) => BlocProvider(
                    create: (_) => getIt<StudentFormCubit>(),
                    child: const StudentFormScreen(),
                  ),
                ),
                GoRoute(
                  path: ':id',
                  parentNavigatorKey: _rootNavigatorKey,
                  redirect: (_, state) =>
                      _idParam(state) == null ? AppRoutes.students : null,
                  builder: (_, state) {
                    final id = _idParam(state)!;
                    return MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (_) =>
                              getIt<StudentDetailsCubit>()..watch(id),
                        ),
                        BlocProvider(
                          create: (_) =>
                              getIt<StudentSubjectsCubit>()..watch(id),
                        ),
                        BlocProvider(
                          create: (_) =>
                              getIt<MonthlySessionsCubit>()..start(id),
                        ),
                      ],
                      child: StudentDetailsScreen(studentId: id),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      parentNavigatorKey: _rootNavigatorKey,
                      redirect: (_, state) => state.extra is StudentEntity
                          ? null
                          : AppRoutes.student(_idParam(state)!),
                      builder: (_, state) => BlocProvider(
                        create: (_) => getIt<StudentFormCubit>(),
                        child: StudentFormScreen(
                          student: state.extra! as StudentEntity,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.subjects,
              builder: (_, _) => BlocProvider(
                create: (_) => getIt<SubjectsCubit>()..watch(),
                child: const SubjectsScreen(),
              ),
              routes: [
                GoRoute(
                  path: ':id',
                  parentNavigatorKey: _rootNavigatorKey,
                  redirect: (_, state) =>
                      state.extra is SubjectEntity ? null : AppRoutes.subjects,
                  builder: (_, state) {
                    final subject = state.extra! as SubjectEntity;
                    return MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (_) =>
                              getIt<SubjectStudentsCubit>()..watch(subject.id),
                        ),
                        BlocProvider(
                          create: (_) =>
                              getIt<SubjectSessionsCubit>()..watch(subject.id),
                        ),
                      ],
                      child: SubjectDetailsScreen(subject: subject),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (_, _) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

int? _idParam(GoRouterState state) =>
    int.tryParse(state.pathParameters['id'] ?? '');
