import 'package:teacher_system/core/utils/clock.dart';

class FixedClock implements Clock {
  final DateTime value;
  const FixedClock(this.value);

  @override
  DateTime now() => value;
}
