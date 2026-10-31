import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:teacher_system/core/error/failures.dart';
import 'package:teacher_system/core/result/api_result.dart';
import 'package:teacher_system/features/sessions/domain/entities/session_entity.dart';
import 'package:teacher_system/features/sessions/domain/usecases/delete_session_usecase.dart';
import 'package:teacher_system/features/sessions/domain/usecases/get_today_usecase.dart';
import 'package:teacher_system/features/sessions/domain/usecases/watch_monthly_sessions_usecase.dart';
import 'package:teacher_system/features/sessions/presentation/bloc/monthly_sessions_cubit.dart';
import 'package:teacher_system/features/sessions/presentation/bloc/monthly_sessions_state.dart';

import '../../../helpers/fakes.dart';

class _MockWatch extends Mock implements WatchMonthlySessionsUseCase {}

class _MockDelete extends Mock implements DeleteSessionUseCase {}

void main() {
  late _MockWatch watchSessions;
  late _MockDelete deleteSession;
  final getToday = GetTodayUseCase(FixedClock(DateTime(2026, 10, 31, 9)));

  final session = SessionEntity(
    id: 1,
    studentId: 1,
    studentName: 'Omar',
    subjectId: 2,
    subjectName: 'Math',
    date: DateTime(2026, 10, 3),
    rating: 4,
  );

  setUpAll(() => registerFallbackValue(DateTime(2000)));

  setUp(() {
    watchSessions = _MockWatch();
    deleteSession = _MockDelete();
    when(
      () => watchSessions(
        studentId: any(named: 'studentId'),
        month: any(named: 'month'),
        subjectId: any(named: 'subjectId'),
      ),
    ).thenAnswer((_) => Stream.value(ApiResult.success([session])));
  });

  MonthlySessionsCubit build() =>
      MonthlySessionsCubit(getToday, watchSessions, deleteSession);

  blocTest<MonthlySessionsCubit, MonthlySessionsState>(
    'start opens the current month and loads its sessions',
    build: build,
    act: (cubit) => cubit.start(1),
    expect: () => [
      isA<MonthlySessionsLoading>()
          .having((s) => s.month, 'month', DateTime(2026, 10))
          .having((s) => s.canGoNext, 'canGoNext', false),
      isA<MonthlySessionsLoaded>().having((s) => s.sessions, 'sessions', [
        session,
      ]),
    ],
  );

  blocTest<MonthlySessionsCubit, MonthlySessionsState>(
    'previousMonth moves back one month and allows going forward',
    build: build,
    act: (cubit) async {
      cubit.start(1);
      await Future<void>.delayed(Duration.zero);
      cubit.previousMonth();
    },
    skip: 2,
    expect: () => [
      isA<MonthlySessionsLoading>()
          .having((s) => s.month, 'month', DateTime(2026, 9))
          .having((s) => s.canGoNext, 'canGoNext', true),
      isA<MonthlySessionsLoaded>(),
    ],
  );

  blocTest<MonthlySessionsCubit, MonthlySessionsState>(
    'nextMonth does nothing on the current month',
    build: build,
    act: (cubit) async {
      cubit.start(1);
      await Future<void>.delayed(Duration.zero);
      cubit.nextMonth();
    },
    skip: 2,
    expect: () => <MonthlySessionsState>[],
  );

  blocTest<MonthlySessionsCubit, MonthlySessionsState>(
    'filterBySubject keeps the month and sets the subject',
    build: build,
    act: (cubit) async {
      cubit.start(1);
      await Future<void>.delayed(Duration.zero);
      cubit.filterBySubject(2);
    },
    skip: 2,
    expect: () => [
      isA<MonthlySessionsLoading>()
          .having((s) => s.month, 'month', DateTime(2026, 10))
          .having((s) => s.subjectId, 'subjectId', 2),
      isA<MonthlySessionsLoaded>(),
    ],
  );

  blocTest<MonthlySessionsCubit, MonthlySessionsState>(
    'emits an error state when the stream fails',
    setUp: () =>
        when(
          () => watchSessions(
            studentId: any(named: 'studentId'),
            month: any(named: 'month'),
            subjectId: any(named: 'subjectId'),
          ),
        ).thenAnswer(
          (_) => Stream.value(const ApiResult.failure(DatabaseFailure('x'))),
        ),
    build: build,
    act: (cubit) => cubit.start(1),
    skip: 1,
    expect: () => [
      isA<MonthlySessionsError>().having(
        (s) => s.failure,
        'failure',
        const DatabaseFailure('x'),
      ),
    ],
  );

  blocTest<MonthlySessionsCubit, MonthlySessionsState>(
    'clears the subject filter when that subject is unassigned',
    build: build,
    act: (cubit) async {
      cubit.start(1);
      cubit.filterBySubject(2);
      await Future<void>.delayed(Duration.zero);
      cubit.onAssignedSubjectsChanged([1, 3]);
    },
    skip: 3,
    expect: () => [
      isA<MonthlySessionsLoading>().having(
        (s) => s.subjectId,
        'subjectId',
        null,
      ),
      isA<MonthlySessionsLoaded>(),
    ],
  );

  blocTest<MonthlySessionsCubit, MonthlySessionsState>(
    'keeps the subject filter while it is still assigned',
    build: build,
    act: (cubit) async {
      cubit.start(1);
      cubit.filterBySubject(2);
      await Future<void>.delayed(Duration.zero);
      cubit.onAssignedSubjectsChanged([1, 2]);
    },
    skip: 3,
    expect: () => <MonthlySessionsState>[],
  );
}
