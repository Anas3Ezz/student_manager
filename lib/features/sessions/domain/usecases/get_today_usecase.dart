import '../../../../core/utils/clock.dart';

/// Today's date (no time part), used as the default session date.
class GetTodayUseCase {
  final Clock _clock;
  GetTodayUseCase(this._clock);

  DateTime call() {
    final now = _clock.now();
    return DateTime(now.year, now.month, now.day);
  }
}
