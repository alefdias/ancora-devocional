import 'package:flutter_test/flutter_test.dart';

import 'package:ancora_devocional/data/devotionals.dart';

void main() {
  test('devocional do dia existe', () {
    final d = devotionalForDate(DateTime(2026, 1, 15));
    expect(d.verse.isNotEmpty, true);
    expect(d.title.isNotEmpty, true);
  });
}
