import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:teacher_system/core/error/failures.dart';
import 'package:teacher_system/core/result/api_result.dart';
import 'package:teacher_system/features/sessions/domain/entities/session_input.dart';
import 'package:teacher_system/features/sessions/domain/repos/sessions_repository.dart';
import 'package:teacher_system/features/sessions/domain/usecases/add_session_usecase.dart';

import '../../../helpers/fakes.dart';

class _MockSessionsRepository extends Mock implements SessionsRepository {}

void main() {
  late _MockSessionsRepository repository;
  late AddSessionUseCase useCase;
  final today = DateTime(2026, 10, 31, 15, 30);

  SessionInput input({DateTime? date, int rating = 4, String? notes}) =>
      SessionInput(
        studentId: 1,
        subjectId: 2,
        date: date ?? today,
        rating: rating,
        notes: notes,
      );

  setUpAll(() => registerFallbackValue(input()));

  setUp(() {
    repository = _MockSessionsRepository();
    useCase = AddSessionUseCase(repository, FixedClock(today));
    when(() => repository.addSession(any()))
        .thenAnswer((_) async => const ApiResult.success(7));
  });

  test('rejects a rating below 1', () async {
    final result = await useCase(input(rating: 0));

    expect(
      result,
      const ApiFailure<int>(ValidationFailure(ValidationReason.invalidRating)),
    );
    verifyNever(() => repository.addSession(any()));
  });

  test('rejects a rating above 5', () async {
    final result = await useCase(input(rating: 6));

    expect(
      result,
      const ApiFailure<int>(ValidationFailure(ValidationReason.invalidRating)),
    );
  });

  test('rejects a date after today', () async {
    final result = await useCase(input(date: DateTime(2026, 11, 1)));

    expect(
      result,
      const ApiFailure<int>(ValidationFailure(ValidationReason.futureDate)),
    );
  });

  test('accepts today even when the time is later than now', () async {
    final result = await useCase(input(date: DateTime(2026, 10, 31, 23, 59)));

    expect(result, const ApiSuccess(7));
  });

  test('stores the date without time and blank notes as null', () async {
    await useCase(input(date: DateTime(2026, 10, 30, 18, 45), notes: '   '));

    final saved =
        verify(() => repository.addSession(captureAny())).captured.single
            as SessionInput;
    expect(saved.date, DateTime(2026, 10, 30));
    expect(saved.notes, isNull);
  });
}
