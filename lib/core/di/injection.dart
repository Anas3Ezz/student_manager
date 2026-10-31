import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/sessions/data/datasources/sessions_local_data_source.dart';
import '../../features/sessions/data/repos/sessions_repository_impl.dart';
import '../../features/sessions/domain/repos/sessions_repository.dart';
import '../../features/sessions/domain/usecases/add_session_usecase.dart';
import '../../features/sessions/domain/usecases/delete_session_usecase.dart';
import '../../features/sessions/domain/usecases/get_default_session_subject_usecase.dart';
import '../../features/sessions/domain/usecases/get_today_usecase.dart';
import '../../features/sessions/domain/usecases/update_session_usecase.dart';
import '../../features/sessions/domain/usecases/watch_monthly_sessions_usecase.dart';
import '../../features/sessions/domain/usecases/watch_recent_subject_sessions_usecase.dart';
import '../../features/sessions/presentation/bloc/monthly_sessions_cubit.dart';
import '../../features/sessions/presentation/bloc/session_form_cubit.dart';
import '../../features/sessions/presentation/bloc/subject_sessions_cubit.dart';
import '../../features/settings/data/datasources/settings_local_data_source.dart';
import '../../features/settings/data/repos/settings_repository_impl.dart';
import '../../features/settings/domain/repos/settings_repository.dart';
import '../../features/settings/domain/usecases/get_theme_settings_usecase.dart';
import '../../features/settings/domain/usecases/save_theme_settings_usecase.dart';
import '../../features/settings/presentation/bloc/theme_cubit.dart';
import '../../features/students/data/datasources/students_local_data_source.dart';
import '../../features/students/data/repos/students_repository_impl.dart';
import '../../features/students/domain/repos/students_repository.dart';
import '../../features/students/domain/usecases/add_student_usecase.dart';
import '../../features/students/domain/usecases/delete_student_usecase.dart';
import '../../features/students/domain/usecases/update_student_usecase.dart';
import '../../features/students/domain/usecases/watch_student_usecase.dart';
import '../../features/students/domain/usecases/watch_students_by_subject_usecase.dart';
import '../../features/students/domain/usecases/watch_students_usecase.dart';
import '../../features/students/presentation/bloc/student_details_cubit.dart';
import '../../features/students/presentation/bloc/student_form_cubit.dart';
import '../../features/students/presentation/bloc/students_cubit.dart';
import '../../features/students/presentation/bloc/subject_students_cubit.dart';
import '../../features/subjects/data/datasources/subjects_local_data_source.dart';
import '../../features/subjects/data/repos/subjects_repository_impl.dart';
import '../../features/subjects/domain/repos/subjects_repository.dart';
import '../../features/subjects/domain/usecases/add_subject_usecase.dart';
import '../../features/subjects/domain/usecases/assign_subject_usecase.dart';
import '../../features/subjects/domain/usecases/delete_subject_usecase.dart';
import '../../features/subjects/domain/usecases/get_student_subjects_usecase.dart';
import '../../features/subjects/domain/usecases/unassign_subject_usecase.dart';
import '../../features/subjects/domain/usecases/update_subject_usecase.dart';
import '../../features/subjects/domain/usecases/watch_student_subjects_usecase.dart';
import '../../features/subjects/domain/usecases/watch_subjects_usecase.dart';
import '../../features/subjects/presentation/bloc/student_subjects_cubit.dart';
import '../../features/subjects/presentation/bloc/subjects_cubit.dart';
import '../database/app_database.dart';
import '../utils/clock.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Core
  getIt
    ..registerSingleton<SharedPreferences>(
      await SharedPreferences.getInstance(),
    )
    ..registerLazySingleton<AppDatabase>(
      AppDatabase.new,
      dispose: (db) => db.close(),
    )
    ..registerLazySingleton<Clock>(() => const Clock());

  _registerSettings();
  _registerSubjects();
  _registerStudents();
  _registerSessions();
}

void _registerSettings() {
  getIt
    ..registerLazySingleton(() => SettingsLocalDataSource(getIt()))
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => GetThemeSettingsUseCase(getIt()))
    ..registerLazySingleton(() => SaveThemeSettingsUseCase(getIt()))
    // App-wide: one theme for the whole app.
    ..registerLazySingleton(() => ThemeCubit(getIt(), getIt()));
}

void _registerSubjects() {
  getIt
    ..registerLazySingleton(() => SubjectsLocalDataSource(getIt()))
    ..registerLazySingleton<SubjectsRepository>(
      () => SubjectsRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => WatchSubjectsUseCase(getIt()))
    ..registerLazySingleton(() => AddSubjectUseCase(getIt()))
    ..registerLazySingleton(() => UpdateSubjectUseCase(getIt()))
    ..registerLazySingleton(() => DeleteSubjectUseCase(getIt()))
    ..registerLazySingleton(() => WatchStudentSubjectsUseCase(getIt()))
    ..registerLazySingleton(() => GetStudentSubjectsUseCase(getIt()))
    ..registerLazySingleton(() => AssignSubjectUseCase(getIt()))
    ..registerLazySingleton(() => UnassignSubjectUseCase(getIt()))
    ..registerFactory(() => SubjectsCubit(getIt(), getIt(), getIt(), getIt()))
    ..registerFactory(() => StudentSubjectsCubit(getIt(), getIt(), getIt()));
}

void _registerStudents() {
  getIt
    ..registerLazySingleton(() => StudentsLocalDataSource(getIt()))
    ..registerLazySingleton<StudentsRepository>(
      () => StudentsRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => WatchStudentsUseCase(getIt()))
    ..registerLazySingleton(() => WatchStudentUseCase(getIt()))
    ..registerLazySingleton(() => WatchStudentsBySubjectUseCase(getIt()))
    ..registerLazySingleton(() => AddStudentUseCase(getIt()))
    ..registerLazySingleton(() => UpdateStudentUseCase(getIt()))
    ..registerLazySingleton(() => DeleteStudentUseCase(getIt()))
    ..registerFactory(() => StudentsCubit(getIt()))
    ..registerFactory(() => StudentDetailsCubit(getIt(), getIt()))
    ..registerFactory(() => StudentFormCubit(getIt(), getIt()))
    ..registerFactory(() => SubjectStudentsCubit(getIt()));
}

void _registerSessions() {
  getIt
    ..registerLazySingleton(() => SessionsLocalDataSource(getIt()))
    ..registerLazySingleton<SessionsRepository>(
      () => SessionsRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => GetTodayUseCase(getIt()))
    ..registerLazySingleton(() => WatchMonthlySessionsUseCase(getIt()))
    ..registerLazySingleton(() => WatchRecentSubjectSessionsUseCase(getIt()))
    ..registerLazySingleton(() => GetDefaultSessionSubjectUseCase(getIt()))
    ..registerLazySingleton(() => AddSessionUseCase(getIt(), getIt()))
    ..registerLazySingleton(() => UpdateSessionUseCase(getIt(), getIt()))
    ..registerLazySingleton(() => DeleteSessionUseCase(getIt()))
    ..registerFactory(() => MonthlySessionsCubit(getIt(), getIt(), getIt()))
    ..registerFactory(
      () => SessionFormCubit(
        getIt(),
        getIt(),
        getIt(),
        getIt(),
        getIt(),
        getIt(),
        getIt(),
      ),
    )
    ..registerFactory(() => SubjectSessionsCubit(getIt(), getIt()));
}
