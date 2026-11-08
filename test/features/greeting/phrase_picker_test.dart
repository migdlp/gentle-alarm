import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/src/features/greeting/domain/phrase_picker.dart';

void main() {
  test('nunca repite el último índice y siempre está en 1-12', () {
    final rng = Random(42);
    var last = -1;
    for (var i = 0; i < 1000; i++) {
      final n = pickPhraseIndex(rng, last);
      expect(n, inInclusiveRange(1, 12));
      expect(n, isNot(last));
      last = n;
    }
  });
}
