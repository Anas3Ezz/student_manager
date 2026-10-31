import 'package:flutter_test/flutter_test.dart';
import 'package:teacher_system/core/database/db_dates.dart';

void main() {
  test('stores a calendar day as UTC midnight', () {
    expect(
      DbDates.toDb(DateTime(2026, 10, 1, 23, 30)),
      DateTime.utc(2026, 10, 1),
    );
  });

  test('reads a stored value back as the same local calendar day', () {
    final stored = DateTime.utc(2026, 10, 1).toLocal();

    expect(DbDates.fromDb(stored), DateTime(2026, 10, 1));
  });
}
