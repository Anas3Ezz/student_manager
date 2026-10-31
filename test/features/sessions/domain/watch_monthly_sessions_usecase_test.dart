import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:teacher_system/core/result/api_result.dart';
import 'package:teacher_system/features/sessions/domain/entities/session_entity.dart';
import 'package:teacher_system/features/sessions/domain/repos/sessions_repository.dart';
import 'package:teacher_system/features/sessions/domain/usecases/watch_monthly_sessions_usecase.dart';

class _MockSessionsRepository extends Mock implements SessionsRepository {}

void main() {
  late _MockSessionsRepository repository;
  late WatchMonthlySessionsUseCase useCase;

  setUp(() {
    repository = _MockSessionsRepository();
    useCase = WatchMonthlySessionsUseCase(repository);
    when(
      () => repository.watchStudentSessions(
        studentId: any(named: 'studentId'),
        from: any(named: 'from'),
        to: any(named: 'to'),
        subjectId: any(named: 'subjectId'),
      ),
    ).thenAnswer(
      (_) => Stream.value(const ApiResult<List<SessionEntity>>.success([])),
    );
  });

  setUpAll(() => registerFallbackValue(DateTime(2000)));

  test('queries from the first day of the month to the next month', () {
    useCase(studentId: 1, month: DateTime(2026, 10, 17), subjectId: 3);

    verify(
      () => repository.watchStudentSessions(
        studentId: 1,
        from: DateTime(2026, 10),
        to: DateTime(2026, 11),
        subjectId: 3,
      ),
    ).called(1);
  });

  test('December rolls over into January of the next year', () {
    useCase(studentId: 1, month: DateTime(2026, 12));

    verify(
      () => repository.watchStudentSessions(
        studentId: 1,
        from: DateTime(2026, 12),
        to: DateTime(2027, 1),
        subjectId: null,
      ),
    ).called(1);
  });
}
