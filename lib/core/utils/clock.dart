/// Injectable time source so date logic stays deterministic in tests.
class Clock {
  const Clock();

  DateTime now() => DateTime.now();
}
